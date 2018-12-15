#include "term_util.hpp"



//#define HIST_VIEW


typedef unsigned int uint;

using namespace cv;
using namespace std;
//for contrast Limiting Adaptive Histrogram Equilization
void Run(char*, double ratio);
void my_CLAHE(Mat &src, double clipLimit);

int main(int argc, char* argv[]){
	
	switch(argc){
	case 2:
		Run(argv[1],0);
		return 0;
	case 3:
		Run(argv[1], atof(argv[2]));
		return 0;
	default:
		cout << "term (filename) : bypass the Brightness Transform" << endl;
		cout << "term (filename) (ratio) : 0 < ratio < 1" << endl;
		return 0;
	}
}
void Run(char* filename, double ratio)
{	
	Mat img, bt, *bt_eq, bt_clahe;
#ifdef HIST_VIEW
	Mat red_bar;
	Mat green_bar;
	Mat blue_bar;
#endif	
	img = imread(filename, CV_LOAD_IMAGE_COLOR);
	if (img.empty()){
		std::cout << "Doesn't exit file\n" << std::endl;
		exit(0);
	}
#ifdef HIST_VIEW
	uchar* red = new uchar[img.cols*img.rows];
	uchar* green = new uchar[img.cols*img.rows];
	uchar* blue = new uchar[img.cols*img.rows];

	double red_hst[256] = {0,};
	double green_hst[256] = {0,};
	double blue_hst[256] = {0,};

	split_rgb_channel(img,red,green,blue);

	Histogram(red_hst,red);
	Histogram(green_hst,green);
	Histogram(blue_hst,blue);

	red_bar = show_histogram(red_hst);
	green_bar = show_histogram(green_hst);
	blue_bar = show_histogram(blue_hst);
	namedWindow("red bar",CV_WINDOW_AUTOSIZE);
	namedWindow("green bar",CV_WINDOW_AUTOSIZE);
	namedWindow("blue bar",CV_WINDOW_AUTOSIZE);
	imshow("red bar", red_bar);
	imshow("green bar", green_bar);
	imshow("blue bar", blue_bar);
#endif
	namedWindow("Original",CV_WINDOW_AUTOSIZE);
	imshow("Original",img);

	bt = Brightness_transform(img,ratio);
	namedWindow("Brighten Transformed image",CV_WINDOW_AUTOSIZE);
	imshow("Brighten Transformed image",bt);
#ifdef HIST_VIEW
	split_rgb_channel(bt,red,green,blue);
	Histogram(red_hst, red);
	Histogram(green_hst,green);
	Histogram(blue_hst,blue);
	red_bar = show_histogram(red_hst);
	green_bar = show_histogram(green_hst);
	blue_bar = show_histogram(blue_hst);
	namedWindow("Brightned red bar",CV_WINDOW_AUTOSIZE);
	namedWindow("Brightned green bar",CV_WINDOW_AUTOSIZE);
	namedWindow("Brightned blue bar",CV_WINDOW_AUTOSIZE);
	imshow("Brightned red bar", red_bar);
	imshow("Brightned green bar", green_bar);
	imshow("Brightned blue bar", blue_bar);
#endif
	/****************************************************************/
	bt_eq = new Mat(img.rows, img.cols,img.type());
	*bt_eq = bt.clone();
	histogram_equalization(*bt_eq);
#ifdef HIST_VIEW
	split_rgb_channel(*bt_eq,red,green,blue);
	Histogram(red_hst, red);
	Histogram(green_hst,green);
	Histogram(blue_hst,blue);
	red_bar = show_histogram(red_hst);
	green_bar = show_histogram(green_hst);
	blue_bar = show_histogram(blue_hst);
	namedWindow("B.T+H.E red bar",CV_WINDOW_AUTOSIZE);
	namedWindow("B.T+H.E green bar",CV_WINDOW_AUTOSIZE);
	namedWindow("B.T+H.E blue bar",CV_WINDOW_AUTOSIZE);
	imshow("B.T+H.E red bar", red_bar);
	imshow("B.T+H.E green bar", green_bar);
	imshow("B.T+H.E blue bar", blue_bar);
	delete red, green, blue;
#endif
	//namedWindow("B.T+H.E image",CV_WINDOW_AUTOSIZE);
	//imshow("B.T+H.E image",*bt_eq);
	delete bt_eq;
	/****************************************************************/
	bt_clahe = bt.clone();
	my_CLAHE(bt_clahe,4);
	namedWindow("Brighten Transformed with CLAHE",CV_WINDOW_AUTOSIZE);
	imshow("Brighten Transformed with CLAHE", bt_clahe);
	

	
	waitKey(0);
	
}
void my_CLAHE(Mat &src, double clipLimit){
	Mat tmp;
	Ptr<CLAHE> clahe = createCLAHE();
	clahe->setClipLimit(clipLimit);
	vector<Mat> ch;
	cvtColor(src, tmp,CV_BGR2YCrCb);
	split(tmp, ch);
	clahe->apply(ch[0],ch[0]);
	merge(ch,tmp);
	cvtColor(tmp,src,CV_YCrCb2BGR);
}

