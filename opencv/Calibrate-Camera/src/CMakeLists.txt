cmake_minimum_required (VERSION 2.8)

set (opencv_include_dir C:/Users/ksb/Desktop/Kim/research/opencv/opencv/build/include	C:/Users/ksb/Desktop/Kim/research/opencv/opencv/build/include/opencv2)
set (opencv_lib_dir C:/Users/ksb/Desktop/Kim/research/opencv/opencv/build/x64/vc11/lib)
set (opencv_lib opencv_core2413 opencv_highgui2413 opencv_ml2413 opencv_contrib2413 opencv_imgproc2413 opencv_flann2413 opencv_calib3d2413)
set (opencv_libd opencv_core2413d opencv_highgui2413d opencv_ml2413d opencv_contrib2413d opencv_imgproc2413d opencv_flann2413d opencv_calib3d2413d)

set (src main.cpp
)

project (hw2)

include_directories (${opencv_include_dir})
link_directories (${opencv_lib_dir})
add_executable (hw2 ${src})
set(EXECUTABLE_OUTPUT_PATH "../bin")

target_link_libraries (hw2 ${opencv_lib})