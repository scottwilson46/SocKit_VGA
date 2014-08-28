// memdjpeg - A super simple example of how to decode a jpeg in memory
// Kenneth Finnegan, 2012
// blog.thelifeofkenneth.com
//
// After installing jpeglib, compile with:
// cc memdjpeg.c -ljpeg -o memdjpeg
//
// Run with:
// ./memdjpeg filename.jpg
//
// Version	   Date		Time		  By
// -------	----------	-----		---------
// 0.01		2012-07-09	11:18		Kenneth Finnegan
//
 
#include <fcntl.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <syslog.h>
#include <sys/stat.h>
#include <sys/mman.h>
#include <sys/types.h>
#include <stdint.h>
 
#include <jpeglib.h>
 
#define PAGE_SIZE 0x600000
#define HPS2FPGA_BRIDGE_BASE 0xC0000000

#define LW_PAGE_SIZE 4096
#define LWHPS2FPGA_BRIDGE_BASE 0xff200000

volatile uint32_t *ddr3_mem;
volatile uint32_t *regs;
void *bridge_map;
void *lw_map;

int main (int argc, char *argv[]) {
	int rc, i, j;
 
	char *syslog_prefix = (char*) malloc(1024);
	sprintf(syslog_prefix, "%s", argv[0]);
	openlog(syslog_prefix, LOG_PERROR | LOG_PID, LOG_USER);
 
	if (argc != 2) {
		fprintf(stderr, "USAGE: %s filename.jpg\n", argv[0]);
		exit(EXIT_FAILURE);
	}

	int fd_ddr3, ret = EXIT_FAILURE;
	off_t ddr3_base = HPS2FPGA_BRIDGE_BASE;
        off_t regs_base = LWHPS2FPGA_BRIDGE_BASE;

	/* open the memory device file */
	fd_ddr3 = open("/dev/mem", O_RDWR|O_SYNC);
	if (fd_ddr3 < 0) {
		perror("open");
		exit(EXIT_FAILURE);
	}

	/* map the HPS2FPGA bridge into process memory */
	bridge_map = mmap(NULL, PAGE_SIZE, PROT_WRITE, MAP_SHARED,
				fd_ddr3, ddr3_base);
	if (bridge_map == MAP_FAILED) {
		perror("mmap");
		goto cleanup;
	}

	/* map the LWHPS2FPGA bridge into process memory */
	lw_map = mmap(NULL, LW_PAGE_SIZE, PROT_WRITE, MAP_SHARED,
	   		fd_ddr3, regs_base);
	if (lw_map == MAP_FAILED) {
		perror("mmap");
		goto cleanup;
	}

        ddr3_mem  = (uint32_t *) (bridge_map); 

	// Variables for the source jpg
	struct stat file_info;
	unsigned long jpg_size;
	unsigned char *jpg_buffer;
 
	// Variables for the decompressor itself
	struct jpeg_decompress_struct cinfo;
	struct jpeg_error_mgr jerr;
 
	// Variables for the output buffer, and how long each row is
	unsigned long bmp_size;
        unsigned char *line_buffer;
	int row_stride, width, height, pixel_size;
 
 
	// Load the jpeg data from a file into a memory buffer for 
	// the purpose of this demonstration.
	// Normally, if it's a file, you'd use jpeg_stdio_src, but just
	// imagine that this was instead being downloaded from the Internet
	// or otherwise not coming from disk
	rc = stat(argv[1], &file_info);
	if (rc) {
		syslog(LOG_ERR, "FAILED to stat source jpg");
		exit(EXIT_FAILURE);
	}
	jpg_size = file_info.st_size;
	jpg_buffer = (unsigned char*) malloc(jpg_size + 100);
 
	int fd = open(argv[1], O_RDONLY);
	i = 0;
	while (i < jpg_size) {
		rc = read(fd, jpg_buffer + i, jpg_size - i);
		syslog(LOG_INFO, "Input: Read %d/%lu bytes", rc, jpg_size-i);
		i += rc;
	}
	close(fd);
 
	syslog(LOG_INFO, "Proc: Create Decompress struct");
	// Allocate a new decompress struct, with the default error handler.
	// The default error handler will exit() on pretty much any issue,
	// so it's likely you'll want to replace it or supplement it with
	// your own.
	cinfo.err = jpeg_std_error(&jerr);	
	jpeg_create_decompress(&cinfo);
 
 
	syslog(LOG_INFO, "Proc: Set memory buffer as source");
	// Configure this decompressor to read its data from a memory 
	// buffer starting at unsigned char *jpg_buffer, which is jpg_size
	// long, and which must contain a complete jpg already.
	//
	// If you need something fancier than this, you must write your 
	// own data source manager, which shouldn't be too hard if you know
	// what it is you need it to do. See jpeg-8d/jdatasrc.c for the 
	// implementation of the standard jpeg_mem_src and jpeg_stdio_src 
	// managers as examples to work from.
	jpeg_mem_src(&cinfo, jpg_buffer, jpg_size);
 
 
	syslog(LOG_INFO, "Proc: Read the JPEG header");
	// Have the decompressor scan the jpeg header. This won't populate
	// the cinfo struct output fields, but will indicate if the
	// jpeg is valid.
	rc = jpeg_read_header(&cinfo, TRUE);
 
	if (rc != 1) {
		syslog(LOG_ERR, "File does not seem to be a normal JPEG");
		exit(EXIT_FAILURE);
	}
 
	syslog(LOG_INFO, "Proc: Initiate JPEG decompression");
	// By calling jpeg_start_decompress, you populate cinfo
	// and can then allocate your output bitmap buffers for
	// each scanline.
	jpeg_start_decompress(&cinfo);
	
	width = cinfo.output_width;
	height = cinfo.output_height;
	pixel_size = cinfo.output_components;
 
	syslog(LOG_INFO, "Proc: Image is %d by %d with %d components", 
			width, height, pixel_size);
 
	bmp_size = width * height * pixel_size;
 	line_buffer = (unsigned char*) malloc(bmp_size);
 
	// The row_stride is the total number of bytes it takes to store an
	// entire scanline (row). 
	row_stride = width * pixel_size;
 
 
	syslog(LOG_INFO, "Proc: Start reading scanlines");
	//
	// Now that you have the decompressor entirely configured, it's time
	// to read out all of the scanlines of the jpeg.
	//
	// By default, scanlines will come out in RGBRGBRGB...  order, 
	// but this can be changed by setting cinfo.out_color_space
	//
	// jpeg_read_scanlines takes an array of buffers, one for each scanline.
	// Even if you give it a complete set of buffers for the whole image,
	// it will only ever decompress a few lines at a time. For best 
	// performance, you should pass it an array with cinfo.rec_outbuf_height
	// scanline buffers. rec_outbuf_height is typically 1, 2, or 4, and 
	// at the default high quality decompression setting is always 1.
	unsigned char *ptr = line_buffer;
        uint32_t ddr3_pos = 0;
        uint32_t ddr3_word_tmp;
        unsigned char *line_buffer_tmp;
        uint32_t first = 1;
	while (cinfo.output_scanline < cinfo.output_height) {
            line_buffer_tmp = line_buffer; 	
	    jpeg_read_scanlines(&cinfo, &ptr, 1);
	    for (i=0; i<width; i++) {
                ddr3_mem[ddr3_pos] = line_buffer_tmp[0] + (line_buffer_tmp[1] << 8) + (line_buffer_tmp[2] << 16);
                if (first && i<10) {
                    syslog(LOG_INFO, "Data at %d = %x %x %x", ddr3_pos, ddr3_mem[ddr3_pos], line_buffer_tmp[0], line_buffer[0]);
                }
	        line_buffer_tmp+=3;
	        ddr3_pos++;
            }
            first = 0; 
        }

        for (i=0; i<100; i++) {
          syslog(LOG_INFO, "Data at loc %d = %x", i, ddr3_mem[i]);
        }


	syslog(LOG_INFO, "Proc: Done reading scanlines");

        regs = (uint32_t *) (lw_map + 0);
        *regs = 0;
        regs = (uint32_t *) (lw_map + 8);
        *regs = 1;
 
	// Once done reading *all* scanlines, release all internal buffers,
	// etc by calling jpeg_finish_decompress. This lets you go back and
	// reuse the same cinfo object with the same settings, if you
	// want to decompress several jpegs in a row.
	//
	// If you didn't read all the scanlines, but want to stop early,
	// you instead need to call jpeg_abort_decompress(&cinfo)
	jpeg_finish_decompress(&cinfo);
 
	// At this point, optionally go back and either load a new jpg into
	// the jpg_buffer, or define a new jpeg_mem_src, and then start 
	// another decompress operation.
	
	// Once you're really really done, destroy the object to free everything
	jpeg_destroy_decompress(&cinfo);
	// And free the input buffer
	free(jpg_buffer);
 
	syslog(LOG_INFO, "End of decompression");
	return EXIT_SUCCESS;

cleanup:
	close(fd_ddr3);
	return ret;

}
