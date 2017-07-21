#include <opencv2/calib3d/calib3d.hpp>
#include <opencv2/features2d/features2d.hpp>
#include <opencv2/nonfree/features2d.hpp>
#include <opencv2/highgui/highgui.hpp>
#include <opencv2/opencv_modules.hpp>
#include <opencv2/core/core.hpp>
#include <opencv2/imgproc/imgproc.hpp>
#include <iostream>
#include <stdio.h>
#include <math.h>
#include <sys/timeb.h>

//#define CV_CHESS_BOARD_DETECT

typedef struct _chessboard {
	int width;
	int column;
	float actual_length;
} ChessBoard;

static void dummy(int, void*){}
using namespace std;
using namespace cv;

//This program is to callibrate the Camera lenz embedded in SmartPhone such as iPhone and Galexy.
Mat s_K, s_H, s_F;
void ShowImage(Mat, char*, bool);
bool myChessboard(Mat& src);
int pos;

int main(int argc, char* argv[]){
	
	VideoCapture cam;
	if (!cam.open(0))
		return 0;
	//cam.set(CV_CAP_PROP_FRAME_WIDTH,640);
    //cam.set(CV_CAP_PROP_FRAME_HEIGHT,480);
	namedWindow("Smile!", CV_WINDOW_AUTOSIZE);
	//createTrackbar("Clip Limit","Smile!",0,4,dummy);
	//setTrackbarPos("Clip Limit", "Smile!",1);
	createTrackbar("Under Threshold", "Smile!", 0,100,dummy);
	setTrackbarPos("Under Threshold", "Smile!",10);
	createTrackbar("Upper Threshold", "Smile!", 0,230,dummy);
	setTrackbarPos("Upper Threshold", "Smile!",100);

	while(true){
		Mat frame,  cc;
		vector <Mat> rgb;
		cam >>frame;

		if (frame.empty()) {
			
			break;
		}
		
#ifdef CV_CHESS_BOARD_DETECT
		if (myChessboard(frame)){
			imshow("Smile!",frame);
		}
		else imshow("Smile!", frame);
		if(waitKey(10) == 27) break;
#else
		Mat gray, edges;
		vector<Mat> grays;
		int under, upper;
		cvtColor(frame, gray,CV_RGB2GRAY);
		under = getTrackbarPos("Under Threshold","Smile!");
		upper = getTrackbarPos("Upper Threshold","Smile!");
		Canny(gray, gray,under,upper,3);
		
		grays.push_back(gray.clone());
		grays.push_back(gray.clone());
		grays.push_back(gray.clone());
		
		merge(grays,cc);
		
		char postring[30];
		sprintf(postring,"upper: %d", upper);
		putText(frame, postring, Point(30, 30), FONT_HERSHEY_PLAIN, 2.0, CV_RGB(255,0,0),2.0);
		sprintf(postring,"under: %d", under);
		putText(frame, postring, Point(30, 80), FONT_HERSHEY_PLAIN, 2.0, CV_RGB(255,0,0),2.0);
		Mat win_mat(Size(2*frame.cols,frame.rows),CV_8UC3);
		frame.copyTo(win_mat(Rect(0,0,frame.cols,frame.rows)));
		cc.copyTo(win_mat(Rect(frame.cols,0,frame.cols,frame.rows)));

		imshow("Smile!", win_mat);
		if(waitKey(10) == 27){
		//	imwrite("output.jpg", win_mat);
			break;
		}

		/*
		split(frame, rgb);
		pos = getTrackbarPos("Clip Limit", "Smile!");
		Ptr<CLAHE> clahe = createCLAHE();
		clahe->setClipLimit(pos);
		clahe->apply(rgb[0], rgb[0]);
		clahe->apply(rgb[1], rgb[1]);
		clahe->apply(rgb[2], rgb[2]);
		merge(rgb, cc);
		char postring[30];
		sprintf(postring,"pos: %d", pos);
		putText(frame, postring, Point(10, 10), FONT_HERSHEY_PLAIN, 1.0, CV_RGB(255,0,0),2.0);
		Mat win_mat(Size(2*frame.cols,frame.rows),CV_8UC3);
		frame.copyTo(win_mat(Rect(0,0,frame.cols,frame.rows)));
		cc.copyTo(win_mat(Rect(frame.cols,0,frame.cols,frame.rows)));
		
		//cvtColor(cc, cc, CV_GRAY2RGB);
		imshow("Smile!", win_mat);

		if(waitKey(10) == 27) {
			imwrite("output.jpg",win_mat);
			break;
		}
		*/
#endif
	}
	
	return 0;
}

void ShowImage (Mat input, char* title=NULL, bool no_wait=false){
	if (title ==NULL)
		title = "Default";

	namedWindow(title, CV_WINDOW_AUTOSIZE);
	imshow(title, input);
	if (no_wait);
	else waitKey(0);
}
bool myChessboard(Mat& src){
	ChessBoard chess; chess.width=9; chess.column=6; chess.actual_length = 22;
	Mat gray;
	Size s(chess.width, chess.column);
	vector<Point2f> chess_corner;
	vector<vector<Point2f>> imgPoints;
	vector<vector<Point2f>> objectPoints;

	Mat K_Matrix(3,3,CV_64F);
	Mat distCoe(8,1,CV_64F);

	cvtColor(src, gray, CV_RGB2GRAY);
	if (!findChessboardCorners(gray, s, chess_corner, CV_CALIB_CB_ADAPTIVE_THRESH | CV_CALIB_CB_FILTER_QUADS))
		return 0;

	cornerSubPix(gray,chess_corner, Size(11,11), Size(-1,-1), TermCriteria(CV_TERMCRIT_EPS | CV_TERMCRIT_ITER, 30, 0.1));	
	drawChessboardCorners(src, s, chess_corner, true);

	return 1;

}
