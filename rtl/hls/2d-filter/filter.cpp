#include "filter.hpp"

//#define IMG IMG_HEIGHT*IMG_WIDTH
//#define AXI
//#define LINE_BUFFER
#define CIRCLE_BUFFER

using namespace hls;

static fixed88_t weight[KERNEL_SZ][KERNEL_SZ] = {
		{0.1,0.1,0.1},
		{0.1,0.1,0.1},
		{0.1,0.1,0.1}
};
#ifdef LINE_BUFFER
LineBuffer<IMG_WIDTH,1, soc_uint8_t> l1, l2;
#endif
#ifdef CIRCLE_BUFFER
CircleBuffer<IMG_WIDTH, 8, soc_uint8_t> c1, c2;
#else
soc_uint8_t l1[IMG_WIDTH], l2[IMG_WIDTH];
#endif
/*
soc_uint8_t pd1[KERNEL_SZ-1];
soc_uint8_t pd2[KERNEL_SZ-1];
soc_uint8_t pd3[KERNEL_SZ-1];
*/
soc_uint8_t pd1[KERNEL_SZ];
soc_uint8_t pd2[KERNEL_SZ];
soc_uint8_t pd3[KERNEL_SZ];

void ConvFilter(soc_uint8_t* din, soc_uint8_t* dout){

//#pragma HLS INTERFACE m_axi depth=51529 port=din
//#pragma HLS INTERFACE m_axi depth=51529 port=dout

#ifdef AXI
#pragma HLS INTERFACE s_axilite port=din bundle=BUS_A
#pragma HLS INTERFACE s_axilite port=dout bundle=BUS_B
#endif

#pragma HLS ARRAY_PARTITION variable=pd1 complete dim=0
#pragma HLS ARRAY_PARTITION variable=pd2 complete dim=0
#pragma HLS ARRAY_PARTITION variable=pd3 complete dim=0

#ifdef LINE_BUFFER
	l2.shift_pixels_down(0);
	l2.insert_top_row(l1.getval(IMG_WIDTH-1,0),0);
	l1.shift_pixels_down(0);
	l1.insert_top_row(*din, 0);
#endif
#ifndef CIRCLE_BUFFER
#ifdef LINE_BUFFER
	for (int i=IMG_WIDTH-1;i>0;i--){
		l2[i] = l2[i-1];
	}
	l2[0] = l1[IMG_WIDTH-1];
	for (int i=IMG_WIDTH-1;i>0;i--){
#pragma HLS PIPELINE
		l1[i] = l1[i-1];
	}
	l1[0] = *din;
#endif
#endif
#ifndef CIRCLE_BUFFER
	for (int i=KERNEL_SZ-1;i>0;i--){
#pragma HLS PIPELINE
//#pragma HLS UNROLL
		pd1[i] = pd1[i-1];
	}
	pd1[0] = *din;
	for (int i=KERNEL_SZ-1;i>0;i--){
#pragma HLS PIPELINE
//#pragma HLS UNROLL
		pd2[i] = pd2[i-1];
	}

#ifdef LINE_BUFFER
	pd2[0] = l1.getval(IMG_WIDTH-1,0);
#endif
#ifdef CIRCLE_BUFFER

#else
	pd2[0] = l1[IMG_WIDTH-1];
#endif

	for (int i=KERNEL_SZ-1;i>0;i--){
#pragma HLS PIPELINE
//#pragma HLS UNROLL
		pd3[i] = pd3[i-1];
	}

#ifdef LINE_BUFFER
	pd3[0] = l2.getval(IMG_WIDTH-1,0);
#elif CIRCLE_BUFFER

#else
	pd3[0] = l2[IMG_WIDTH-1];
#endif

	fixed88_t acc = 0;
	for (int i=0;i<KERNEL_SZ;i++){
#pragma HLS PIPELINE
		acc += pd3[((KERNEL_SZ-1)-i)] * weight[0][i];
		acc += pd2[((KERNEL_SZ-1)-i)] * weight[1][i];
		acc += pd1[((KERNEL_SZ-1)-i)] * weight[2][i];
	}
	*dout = (soc_uint8_t)acc;
#else
	fixed88_t acc = 0;
	soc_uint8_t tmp0, tmp1, tmp2;

	tmp0 = *din; tmp1 = c1.getData(); tmp2 = c2.getData(); //line buffer
	pd1[0] = *din;
	for(int i=0;i<KERNEL_SZ;i++){
#pragma HLS PIPELINE
		acc += pd3[((KERNEL_SZ)-i)]*weight[0][i];
		acc += pd2[((KERNEL_SZ)-i)]*weight[1][i];
		acc += pd1[((KERNEL_SZ)-i)]*weight[2][i];
	}

	for(int i=KERNEL_SZ-1;i>0;i--){
#pragma HLS PIPELINE
		pd3[i] = pd3[i-1];
		pd2[i] = pd2[i-1];
		pd1[i] = pd1[i-1];
	}
	pd3[0] = tmp2;
	pd2[0] = tmp1;

	c1.feedData(&tmp0);
	c2.feedData(&tmp1);
/*
	// Kernel operation.
	for(int i=0;i<KERNEL_SZ-1;i++){
#pragma HLS PIPELINE
		acc += pd3[(KERNEL_SZ-2)-i] * weight[0][i+1];
		acc += pd2[(KERNEL_SZ-2)-i] * weight[1][i+1];
		acc += pd1[(KERNEL_SZ-2)-i] * weight[2][i+1];
	}
	acc += *din*weight[0][0];
	acc += tmp1*weight[1][0];
	acc += tmp2*weight[2][0];
	//


	for (int i=KERNEL_SZ-2;i>0;i--){
#pragma HLS PIPELINE
		pd3[i] = pd3[i-1];
		pd2[i] = pd2[i-1];
		pd1[i] = pd1[i-1];
	}
	pd3[0] = tmp2;
	pd2[0] = tmp1;
	pd1[0] = *din;
*/
	*dout = (soc_uint8_t)acc;
#endif
}
