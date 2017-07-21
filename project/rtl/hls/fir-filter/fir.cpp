#include "fir.hpp"
/*
void fir(int din[SIZE], int dout[SIZE]){

//#pragma HLS INTERFACE s_axilite port=din
//#pragma HLS INTERFACE s_axilite port=dout

	int coe[N] = {13, -2, 9, 11, 26, 18, 95, -43, 6, 74};
	int shift_reg[N]= {0,};

	for (int i=0;i<SIZE;i++){
		int acc = 0;
		//Stage of fetching data into registers,
		for (int j=N-1;j>0;j--){
			#pragma HLS UNROLL
			shift_reg[j] = shift_reg[j-1]; //shifting
		}
		shift_reg[0] = din[i];
		//
		for (int j=0;j<N;j++){
			#pragma HLS UNROLL
			acc+=shift_reg[j]*coe[j];
		}
		dout[i] = acc;
	}
}
*/

void top(int din, int dout){

#pragma HLS INTEFACE s_axilite port=din
#pragma HLS INTEFACE s_axilite port=dout

	int reg[SIZE];
	for (int i=SIZE-1;i>0;i++)
		reg[i] = reg[i-1];
	reg[0] = din;

	//fir filter implemented below..
	//---
	///


}
