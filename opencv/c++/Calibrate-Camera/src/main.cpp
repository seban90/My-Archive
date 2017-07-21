#include <opencv2/calib3d/calib3d.hpp>
#include <opencv2/highgui/highgui.hpp>
#include <opencv2/core/core.hpp>
#include <opencv2/imgproc/imgproc.hpp>
#include <iostream>
#include <stdio.h>


typedef struct _chessboard {
	int width;
	int column;
} ChessBoard;

using namespace std;
using namespace cv;

//This program is to callibrate the Camera lenz embedded in SmartPhone such as iPhone and Galexy.

void ShowImage(Mat, char*, bool);
bool Calibration(vector<Mat> *);

int main(){
	vector<Mat> src;
	for (int i=1;i<9;i++){
		char tmp[50];
		Mat img;
		sprintf(tmp,"../../fig%d.jpg",i);
		img = imread(tmp, CV_LOAD_IMAGE_COLOR);
		src.push_back(img);
	}
	
	if(!Calibration(&src)){
		cout << "Error" << endl;
		return -1;
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
bool Calibration(vector<Mat> *src){

	ChessBoard constraint; constraint.width=9; constraint.column=6;
	float actuall_length = 22;

	vector<Mat> grayVector;
	Mat gray;
	vector<Point2f> chessboard_corner;
	Size s(constraint.width, constraint.column);
	vector<vector<Point2f>> imagePoints;
	vector<vector<Point3f>> objectPoints;

	Mat cameraMatrix(3,3,CV_64F);
	Mat distCoe(8,1,CV_64F);

	FILE* f;

	for (int i=0;i<src->size();i++){
		char output[50];
		sprintf(output, "./output_%d.jpg",i);

		Mat imgTmp = (src->at(i)).clone();

		cvtColor(imgTmp, gray, CV_RGB2GRAY);
		if (!findChessboardCorners(gray, s, chessboard_corner, CV_CALIB_CB_ADAPTIVE_THRESH | CV_CALIB_CB_FILTER_QUADS)){
			std::cout << "Cannot find chessboard!" << endl;
			return 0;
		}
		cornerSubPix(gray,chessboard_corner, Size(11,11), Size(-1,-1), TermCriteria(CV_TERMCRIT_EPS | CV_TERMCRIT_ITER, 30, 0.1));	
		drawChessboardCorners(imgTmp, s, chessboard_corner, true);

		imwrite(output, imgTmp);
		grayVector.push_back(gray);

		vector<Point2f> imgPoint;
		vector<Point3f> objPoint;

		for (int i=0;i<chessboard_corner.size();i++){
			Point2f imgtmp;
			Point3f objtmp;
			imgtmp.x = chessboard_corner[i].x;
			imgtmp.y = chessboard_corner[i].y;
			objtmp.x = i % s.width * actuall_length;
			objtmp.y = i / s.width * actuall_length;
			objtmp.z = 0;

			imgPoint.push_back(imgtmp);
			objPoint.push_back(objtmp);
		}
		imagePoints.push_back(imgPoint);
		objectPoints.push_back(objPoint);
	}
	vector<Mat> rvecs, tvecs;
	calibrateCamera(objectPoints,imagePoints, Size(gray.cols,gray.rows), cameraMatrix, distCoe,rvecs,tvecs);

	f = fopen("./output.txt", "wt");
	fprintf(f,"Calibration Results\nCamera Matrix:\n");
	fprintf(f, "---------------------------------------\n");
	for (int i=0;i<3;i++){
		fprintf(f,"%7.3f %7.3f %7.3f\n", cameraMatrix.at<double>(i,0),cameraMatrix.at<double>(i,1),cameraMatrix.at<double>(i,2));
	}
	fprintf(f, "Radial Distortion:\n");
	fprintf(f, "---------------------------------------\n");
	fprintf(f,"%5.3f %5.3f %5.3f %5.3f %5.3f %5.3f\n",distCoe.at<double>(0,0),distCoe.at<double>(1,0),
														distCoe.at<double>(4,0),distCoe.at<double>(5,0),
														distCoe.at<double>(6,0),distCoe.at<double>(7,0));
	fprintf(f, "Tangential Distortion:\n");
	fprintf(f, "---------------------------------------\n");
	fprintf(f,"(%5.3f, %5.3f)\n", distCoe.at<double>(2,0), distCoe.at<double>(3,0));
	fprintf(f, "Done\n");

	fclose(f);
	
	return 1;
}
