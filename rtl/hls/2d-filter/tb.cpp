#include "filter.hpp"

//#define AXI

int main(){
	soc_uint8_t img[IMG_WIDTH*IMG_HEIGHT];
	soc_uint8_t out[IMG_WIDTH*IMG_HEIGHT];

	if (IMG_HEIGHT > 227 || IMG_WIDTH > 227){
		std::cout << "error, Too big image size\n";
		return -1;
	}

	for(int i=0;i<IMG_HEIGHT*IMG_WIDTH;i++)
		img[i] = (soc_uint8_t)img_data[i];
#ifndef AXI
	for(int i=0;i<IMG_HEIGHT*IMG_WIDTH;i++)
		ConvFilter((img+i), out+i);
#else

#endif
	FILE* f = fopen("output0413.txt", "wt");
	if (f==NULL){
		printf("Error, File wasn't opened!");
		return -1;
	}

	for (int i=0;i<IMG_HEIGHT*IMG_WIDTH;i++)
		fprintf(f, "%d\n",(unsigned int)out[i]);
	fclose(f);
	std::cout << "done" << std::endl;
	return 0;
}
