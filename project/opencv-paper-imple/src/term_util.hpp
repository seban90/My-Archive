

#include <opencv2/core/core.hpp>
#include <opencv2/highgui/highgui.hpp>
#include <opencv2/imgproc/imgproc.hpp>
#include <iostream>


void histogram_equalization(cv::Mat &src);
double round(double num);
cv::Mat Brightness_transform(cv::Mat src, double scatter_rate);
void Histogram(double *hst, const uchar *src);
cv::Mat show_histogram(double* src);
void split_rgb_channel(cv::Mat src, uchar* red, uchar* green, uchar* blue);
void make_LUT(const uchar j_max);
void calc_transmit_rate(uchar y_max, const double ratio);
void image_from_hist(cv::Mat &src, double* hist);