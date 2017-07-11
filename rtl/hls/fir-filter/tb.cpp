#include "fir.hpp"

int main(){

	int din[4][128] = {0};
	int dout[4][128] = {0};

	for (int i=0;i<4;i++)
		for (int j=0;j<10;j++)
			din[i][j] = rand()%10;


	for (int i=0;i<4;i++)
		fir(din[i], dout[i]);

	for (int j=0;j<4;j++){
		printf("%d-th array\n", j);
		for(int i=0; i<10; i++){
			printf("input data: %d, output data: %d\n", din[j][i], dout[j][i]);
		}
	}
	return 0;
}
