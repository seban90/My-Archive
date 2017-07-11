#include <iostream>
#include <opencv2/opencv2.hpp>
#include <opencv2/videoio.hpp>
#include <opencv2/core/core.hpp>
#include <opencv2/highgui/highgui.hpp>
#include <opencv2/imgproc/imgproc.hpp>
#include <opencv2/opencv_modules.hpp>

using namespace std;
using namespace cv;

Mat myCanny(const& Mat);
static void dummy(int,void*);

int main(int argc, char* argv[]){
	VideoCapture cam;
	//cam.open(0);
	int deviceId = 0;
	int apiId = CAP_ANY;
	int thrVal = 10;
	
	cam.open(deviceId + apiId);
	cam.set(CV_CAP_PROP_FRAME_WIDTH, 320);
	cam.set(CV_CAP_PROP_FRAME_HEIGHT, 240);
	if (!cam.isOpened()){
		cout<<"Error! Camera ins't fount" < endl;
		return 0;
	}
	namedWindow("test1", CV_WINDOW_AUTOSIZE);
	namedWindow("test2", CV_WINDOW_AUTOSIZE);
	createTrackbar("Threshold", "test1", &thrVal,90,dummy);
	setTrackbarPos("Threshold", "test1", 10);
	
	while (true){
		Mat frame, gray;
		int pos;
		cam.read(frame);
		pos = getTrackbarPos("Threshold", "test1");
		if (frame.empty())
			break;
		gray = myCanny(frame, pos);
		imshow("test1", frame);
		imshow("test2", gray);
		if(waitKey(10)==27) break;
	}
	cout << "Program Terminated!" << endl;
	return 0;
}
Mat myCanny(const Mat& src, int thres){
	Mat gray;
	//vector<Mat> grays;
	cvtColor(src, gray, CV_RGB2GRAY);
	Canny(gray, gray, thres, thres*3, 3);
	return gray;
	
}
static void dummy(int al, void* dd){}