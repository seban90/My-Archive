#include <stdio.h>
#include <stdlib.h>
#include <malloc.h>


#define CONV_NO_PAD      (0x0)
#define CONV_ENABLE_PAD  (0x1<<0)
#define CONV_ZERO_PAD    (0x1<<1)
#define CONV_VALUE_PAD   (0x1<<2)


#define __DEBUG__
#define __SUB_DEBUG__


//TODO:: debug function conv2d, make sobel edge filter

typedef unsigned char       uchar;
typedef unsigned int        uint;
typedef          int        PIXEL;
typedef unsigned long long  DPI_PIXEL;

typedef struct _mat {
	PIXEL* p;
	uint   rows;
	uint   cols;
	uint   padding;
} Mat;

int conv2d (Mat* src, Mat* dst, Mat* kernel, uint flags) {
	size_t i, j, k, p;

	uint is_padding  ;
	uint pad_val     ;
	uint pad = src->padding;

	if ((src == NULL) || (dst == NULL)) 
		return 0; 

	if (flags % 2 == 0) is_padding = 0;
	else                is_padding = 1;

	if      (flags ==  CONV_ZERO_PAD | CONV_ENABLE_PAD) pad_val = 0;
	else if (flags == CONV_VALUE_PAD | CONV_ENABLE_PAD) pad_val = src->p[0];

	if (is_padding) {
		for (i=0;i<src->rows;i++) {
			for (j=0;j<src->cols;j++) {
				PIXEL tmp = 0;
				for (k=0;k<kernel->rows;k++) {
					for (p=0;p<kernel->cols;p++) {
						int kernel_idx = (kernel->rows-k-1)*kernel->cols+(kernel->cols-p-1);
						int row_idx = i-pad+k;
						int col_idx = j-pad+p;
						if (((row_idx >= 0) && (row_idx < src->rows)) && (col_idx >= 0 && col_idx < src->cols))
							tmp += src->p[row_idx*src->cols+col_idx]*kernel->p[kernel_idx];
						else 
							tmp += pad_val*kernel->p[kernel_idx];
					}
				}
				dst->p[i*src->cols+j] = tmp;
			}
		}
	} else {
		for (i=pad;i<src->rows-pad;i++) {
			for (j=pad;j<src->cols-pad;j++) {
				PIXEL tmp = 0;
				for (k=0;k<kernel->rows;k++)
					for (p=0;p<kernel->cols;p++){
						int kernel_idx = (kernel->rows-k-1)*kernel->cols+(kernel->cols-p-1);
						int row_idx = i-pad+k;
						int col_idx = j-pad+p;
						tmp += src->p[row_idx*src->cols+col_idx]*kernel->p[kernel_idx];
					}
				dst->p[i*src->cols+j] = tmp;
			}
		}
	}

	return 1;
}

int corr2d(Mat* src, Mat* dst, Mat* kernel, uint flags) {
	size_t i,j,k,p;
	uint is_pad, pad_val, pad = src->padding;

	if ((src == NULL) || (dst == NULL)) return 0;

	if (flags % 2 == 0) is_pad = 0;
	else                is_pad = 1;
	if      (flags ==  CONV_ZERO_PAD | CONV_ENABLE_PAD) pad_val = 0;
	else if (flags == CONV_VALUE_PAD | CONV_ENABLE_PAD) pad_val = src->p[0];

	if (is_pad) {
		for (i=0;i<src->rows;i++) {
			for (j=0;j<src->cols;j++) {
				PIXEL tmp = 0;
				for (k=0;k<kernel->rows;k++) {
					for (p=0;p<kernel->cols;p++) {
						int kernel_idx = k*kernel->cols+p;
						int row_idx = i-pad+k;
						int col_idx = j-pad+p;
						if (((row_idx >= 0) && (row_idx < src->rows)) && (col_idx >= 0 && col_idx < src->cols))
							tmp += src->p[row_idx*src->cols+col_idx]*kernel->p[kernel_idx];
						else 
							tmp += pad_val*kernel->p[kernel_idx];

						printf("[DEBUG] kernel index :%d\n", kernel_idx);

					}
				dst->p[i*src->cols+j] = tmp;
				}
			}
		}
	} else {
		for (i=pad;i<src->rows-pad;i++) {
			for (j=pad;j<src->cols-pad;j++) {
				PIXEL tmp = 0;
				for (k=0;k<kernel->rows;k++)
					for (p=0;p<kernel->cols;p++){
						int kernel_idx = k*kernel->cols+p;
						int row_idx = i-pad+k;
						int col_idx = j-pad+p;
						tmp += src->p[row_idx*src->cols+col_idx]*kernel->p[kernel_idx];
					}
				dst->p[i*src->cols+j] = tmp;
			}
		}

	}


}

#ifdef __SUB_DEBUG__

#define MALLOC_CHECK(n,t) if (n == NULL) {printf(t);return NULL;}

static PIXEL sobel_weights_x[3*3] = {-1, 0, 1, -2, 0, 2, -1, 0, 1};
static PIXEL sobel_weights_y[3*3] = {-1, 2, 1, -2, 0, 2, -1, 0, 1};
static PIXEL min_weights[3*3] = {0x1c,0x1c,0x1c,0x1c,0x1c,0x1c,0x1c,0x1c, 0x1c};

static Mat sobel_kernel_x = {
	 .p       = sobel_weights_x
	,.rows    = 3
	,.cols    = 3
	,.padding = 0
};

static Mat sobel_kernel_y = {
	 .p       = sobel_weights_y
	,.rows    = 3
	,.cols    = 3
	,.padding = 0
};

static Mat min_kernel = {
	 .p       = min_weights 
	,.rows    = 3
	,.cols    = 3
	,.padding = 0
};

Mat* create_mat(uint rows, uint cols, uint padding) {
	Mat* src;
	src    =   (Mat*)malloc(sizeof(Mat));
	src->p = (PIXEL*)malloc(sizeof(PIXEL)*rows*cols);

	MALLOC_CHECK(src, "\nAllocation of Mat failed")
	MALLOC_CHECK(src->p, "\nAllocation of Mat data failed")

	src->padding = padding;
	src->rows    = rows;
	src->cols    = cols;
	return src;
}

void delete_mat(Mat* pM) {
	free(pM->p);
	free(pM);
}
void print_mat(Mat* pM) {
	size_t i,j;
	for (i=0;i<pM->rows;i++) {
		for (j=0;j<pM->cols;j++)
			printf(" %10d", pM->p[i*pM->cols+j]);
		printf("\n");
	}
	return;
}
int blur(Mat* src, Mat* dst,uint flags ) {
	size_t i,j;
	if ((src == NULL) || (dst == NULL))
		return 0;
	if (!conv2d(src, dst, &min_kernel, flags)) {
		printf("\n2-D Convolution Error");
		delete_mat(src);
		delete_mat(dst);
		return -1;
	}

	for (i=0;i<dst->rows;i++)
		for (j=0;j<dst->cols;j++)
			dst->p[i*dst->cols+j] >>= 8;
	
}
int main () {
	Mat* src;
	Mat* dst;
	size_t i,j;
	uint rows = 6, cols = 6, padding = 1;

	src = create_mat(rows,cols,padding);

	for (i=0;i<src->rows;i++)
		for (j=0;j<src->cols;j++)
			src->p[i*src->cols+j] = i*src->cols+j;

	dst = create_mat(rows,cols,padding);
	/*
	if (!blur(src, dst, CONV_NO_PAD)) {
		printf("\n2-D Convolution Error");
		delete_mat(src);
		delete_mat(dst);
		return -1;
	}
	printf("\nSRC Mat\n");
	print_mat(src);
	printf("\nDST Mat\n");
	print_mat(dst);
	*/
	if (!corr2d(src, dst, &min_kernel, CONV_ZERO_PAD | CONV_ENABLE_PAD)) {
		printf("\n2-D Convolution Error");
		delete_mat(src);
		delete_mat(dst);
		return -1;
	}
	printf("\nSRC Mat\n");
	print_mat(src);
	printf("\nDST Mat\n");
	print_mat(dst);

	delete_mat(src);
	delete_mat(dst);
	return 1;
}

#endif
