

#include "term_util.hpp"

#include <opencv2/core/core.hpp>
#include <opencv2/highgui/highgui.hpp>
#include <opencv2/imgproc/imgproc.hpp>
#include <iostream>



/*					Kim Seban's own function					*/
typedef unsigned int uint;

double t[256] = {0,};
double J[256] = {0,};
double scatter_beta_rate = 0.0;
bool is_beta_changed = false;


cv::Mat Brightness_transform(cv::Mat src, double scatter_rate);
void Histogram(double *hst, const uchar *src);
cv::Mat show_histogram(double* src);
void split_rgb_channel(cv::Mat src, uchar* red, uchar* green, uchar* blue);
void make_LUT(const uchar j_max);
void calc_transmit_rate(uchar y_max, const double ratio);
void histogram_equalization(cv::Mat &src);
double round(double num);
void image_from_hist(cv::Mat &src, double* hist);


cv::Mat Brightness_transform(cv::Mat src, double scatter_rate){
	/************************************************************/
	cv::Mat ycbcr, result;
	cvtColor(src, ycbcr, CV_BGR2YCrCb);
	cv::Mat tmp, brighten_tmp;
	std::vector <cv::Mat> channels;
	uchar y_max; 
	uchar y_tmp = 0x00;
	
	/************************************************************/
	cv::split(ycbcr,channels); //channels[0] : Y
	
	if (scatter_beta_rate != scatter_rate){
		scatter_beta_rate = scatter_rate;
		is_beta_changed = true;
	}	
	
	if (is_beta_changed){
	
		tmp = channels[0];
		brighten_tmp = tmp.clone();
		/** Finding I_inf in assuming I_inf would be the maximum of I **/
		for(int i=0;i<tmp.cols;i++)
			for (int j=0;j<tmp.rows;j++){
				if (y_tmp <= tmp.at<uchar>(j,i))
					y_tmp = tmp.at<uchar>(j,i);
			}
		y_max = y_tmp;
		/****** Building The Look-Up Table of trasmit rate   ***********/
		/****** and brightness-tranformed Intensity,J        ***********/
		calc_transmit_rate(y_max,scatter_beta_rate);
		make_LUT(y_max);
		/****** Applying J to original image               *************/
		for(int i=0;i<tmp.cols;i++)
			for (int j=0;j<tmp.rows;j++)
				brighten_tmp.at<uchar>(j,i) = J[(int)tmp.at<uchar>(j,i)];
		channels[0] = brighten_tmp;
		cv::merge(channels,ycbcr);
		cv::cvtColor(ycbcr, result,CV_YCrCb2BGR);
		return result;
	}
	else{
		
		for(int i=0;i<tmp.cols;i++)
			for (int j=0;j<tmp.rows;j++)
				brighten_tmp.at<uchar>(j,i) = J[(int)tmp.at<uchar>(j,i)];
		channels[0] = brighten_tmp;
		cv::merge(channels,ycbcr);
		cv::cvtColor(ycbcr, result,CV_YCrCb2BGR);
		return result;
	}
		
	
}
void calc_transmit_rate(uchar y_max, const double ratio){
	double tmp;
	for (uint i = 0;i<=y_max;i++){
		tmp = (1.0-(double)i/(double)y_max);
		t[i] = pow(tmp,ratio);
	}
}
void make_LUT(const uchar y_max){
	double tmp;
	uchar y_tmp = y_max;
	for (uint i=0;i<=(uint)y_tmp;i++){
		tmp = (1.0-(double)i/(double)y_tmp);
		if (tmp)
			J[i]=(double)y_max*(1-tmp/t[i]);
		else
			J[i] = (double)y_max;
	}
}
void split_rgb_channel(cv::Mat src, uchar* red, uchar* green, uchar* blue){
	cv::Mat tmp = src;
	for (int i = 0;i<tmp.cols;i++)
		for (int j=0;j<tmp.rows;j++){
			red[j*tmp.cols+i] = tmp.at<cv::Vec3b>(j,i)[2];
			green[j*tmp.cols+i] = tmp.at<cv::Vec3b>(j,i)[1];
			blue[j*tmp.cols+i] = tmp.at<cv::Vec3b>(j,i)[0];
		}
}
cv::Mat show_histogram(double* src){
	double vmax = -1.0;
	cv::Mat himg(256,256,CV_8U,cv::Scalar(256));

	for (int i=0;i<256;i++)
		vmax = (vmax > src[i]) ? vmax:src[i];
	for (int i=0;i<256;i++){
		cv::Point p1(i,256), p2(i,256-(int)((src[i]/vmax)*(0.8*256)));
		line(himg, p1,p2,cv::Scalar(0));
	}
	return himg;
	
}

void histogram_equalization(cv::Mat &src){
	cv::Mat ycbcr, tmp;
	//double* ahist = (double*)malloc(sizeof(double)*256);
	double* ahist = (double*)calloc(256,sizeof(double));
	double hist[256] = {0,};
	double dst[256] = {0,};
	int index = 0;

	for(int i=0;i<256;i++)
		;//ahist[i] = 0;

	std::vector <cv::Mat> ch;
	cv::cvtColor(src,ycbcr,CV_BGR2YCrCb);
	cv::split(ycbcr,ch);
	for(int i=0;i<ch[0].cols;i++)
		for(int j=0;j<ch[0].rows;j++){
			index = (int)ch[0].at<uchar>(j,i);
			ahist[index]++;
		}
	for(int i=0;i<256;i++)
		hist[i] = ahist[i] /(double)(ch[0].cols*ch[0].rows);
	

	free(ahist);
	

	for (int i=0;i<256;i++)
		for(int j=0;j<=i;j++)
			dst[i] += hist[j] * 255.0;
	for (int i=0;i<256;i++)
		dst[i] = round(dst[i]);
	
	image_from_hist(ch[0],dst);
	
	cv::merge(ch,ycbcr);
	cv::cvtColor(ycbcr,src,CV_YCrCb2BGR);
	
	
}
void image_from_hist(cv::Mat &src, double* hist){
	for (int i=0; i<src.cols;i++)
		for (int j=0;j<src.rows;j++)
			src.at<uchar>(j,i) = (uchar)hist[(int)src.at<uchar>(j,i)];
}
double round(double num){
	return (double)((int)(num+0.5f));
}
void Histogram(double *hst, const uchar *src){
	int array_size = _msize((void*)src)/sizeof(uchar);
	double ahist[256] = {0,};
	int idx = 0;

	for(int i = 0; i<array_size;i++){
		idx = (int)src[i];
		ahist[idx]++;
	}

	for(int i=0;i<256;i++)
		hst[i] = ahist[i]/(double)array_size;
}

