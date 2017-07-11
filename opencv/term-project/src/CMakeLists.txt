cmake_minimum_required (VERSION 2.8)

set (opencv_include_dir D:/project/lib/opencv/build/include	D:/project/lib/opencv/build/include/opencv2)
set (opencv_lib_dir D:/project/lib/opencv/build/x64/vc11/lib)
set (opencv_lib opencv_core2411 opencv_highgui2411 opencv_ml2411 opencv_contrib2411 opencv_imgproc2411 opencv_flann2411 opencv_calib3d2411)
set (opencv_libd opencv_core2411d opencv_highgui2411d opencv_ml2411d opencv_contrib2411d opencv_imgproc2411d opencv_flann2411d opencv_calib3d2411d)

set (src main.cpp
		term_util.cpp
		term_util.hpp
)

project (term)

include_directories (${opencv_include_dir})
link_directories (${opencv_lib_dir})
add_executable (term ${src})
set(EXECUTABLE_OUTPUT_PATH "../bin")

target_link_libraries (term ${opencv_lib})