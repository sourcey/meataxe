# TODO:
# - Check if ffmpeg installed (dependencies)
# - Install python optional, plus other config options

set_default :opencv_version, "2.4.5"
set_default :opencv_root, "/home/#{user}/src"
#set_default(:opencv_examples, 1) # Todo
#set_default(:opencv_python, 1) # Todo
#set_default(:opencv_tbb, 1) # Todo
#set_default(:opencv_num_processors, 4) # Todo: add make ie. make -j4
set_default :opencv_cmake_opts, "-DCMAKE_BUILD_TYPE=RELEASE -DCMAKE_INSTALL_PREFIX=/usr/local \
  -DWITH_TBB=0 -DBUILD_PERF_TESTS=0 -DBUILD_EXAMPLES=0 -DBUILD_TESTS=0 \
  -DBUILD_NEW_PYTHON_SUPPORT=0 -DWITH_V4L=0"
set_default :opencv_extra_dependencies, "libtiff4-dev libjpeg-dev libjasper-dev \
  libgstreamer0.10-dev libgstreamer-plugins-base0.10-dev libv4l-dev \
  libtbb-dev python-dev python-numpy libqt4-dev libgtk2.0-dev"

namespace :opencv do
  desc "Install the latest release of OpenCV"
  task :install, roles: :app do
    # Install dependenices"
    sudo "apt-get -y install cmake pkg-config #{opencv_extra_dependencies}"
  
    # Install stable version hosted on sourceforge
    run "rm -rf opencv-#{opencv_version}"
    run "cd #{opencv_root}
        && wget -O OpenCV-#{opencv_version}.tar.gz http://sourceforge.net/projects/opencvlibrary/files/opencv-unix/#{opencv_version}/opencv-#{opencv_version}.tar.gz/download
        && tar -xf OpenCV-#{opencv_version}.tar.gz"
    run "cd #{opencv_root}/opencv-#{opencv_version}
        && mkdir -p build
        && cd build
        && cmake #{opencv_cmake_opts} ..
        && make
        && #{sudo} make install"
              
    sudo "sh -c 'echo \"/usr/local/lib\" > /etc/ld.so.conf.d/opencv.conf'"
    sudo "ldconfig"
  end
  after "deploy:install", "opencv:install"
end


    #sudo "apt-get -y install libtiff4-dev libjpeg-dev libjasper-dev"
    #sudo "apt-get -y install libgstreamer0.10-dev libgstreamer-plugins-base0.10-dev libv4l-dev"
    #sudo "apt-get -y install python-dev python-numpy"
    #sudo "apt-get -y install libtbb-dev"
    #sudo "apt-get -y install libqt4-dev libgtk2.0-dev"