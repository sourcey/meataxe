# https://ffmpeg.org/trac/ffmpeg/wiki/UbuntuCompilationGuide

set_default(:ffmpeg_source_path, "/home/#{user}/src")
set_default(:ffmpeg_build_path, "/home/#{user}/local")
set_default(:ffmpeg_bin_path, "/home/#{user}/local/bin")
set_default(:ffmpeg_static_build, true)
set_default(:ffmpeg_server_build, true)
set_default(:ffmpeg_enable_yasm, false)
set_default(:ffmpeg_enable_x264, true)
set_default(:ffmpeg_enable_mp3, true)
set_default(:ffmpeg_enable_vpx, true)
set_default(:ffmpeg_enable_aac, true)
set_default(:ffmpeg_enable_ogg, true) # ogg, theora and vorbis
set_default(:ffmpeg_enable_ass, false) # lol
set_default(:ffmpeg_extra_flags, "")

namespace :ffmpeg do
  desc "Install the latest release of ffmpeg"
  task :install do

    # Remove existing ffmpeg packages
    #sudo "apt-get -y remove ffmpeg x264 libav-tools libvpx-dev libx264-dev"

    # Install dependencies for ffmpeg
    deps = "autoconf automake build-essential git libgpac-dev libtool pkg-config texi2html zlib1g-dev"
    deps += " libsdl1.2-dev libva-dev libvdpau-dev libx11-dev libxext-dev libxfixes-dev" unless ffmpeg_server_build
    deps += " libmp3lame-dev" if ffmpeg_enable_mp3
    deps += " libass-dev" if ffmpeg_enable_ass
    sudo "apt-get -y install #{deps}"

    run "mkdir -p #{ffmpeg_source_path}"

    # Build dependencies for ffmpeg
    #install_yasm if ffmpeg_enable_yasm
    #install_libvpx if ffmpeg_enable_vpx
    #install_fdkaac if ffmpeg_enable_aac
    #install_x264 if ffmpeg_enable_x264
    #install_ogg if ffmpeg_enable_ogg
    #install_theora if ffmpeg_enable_ogg
    #install_vorbis if ffmpeg_enable_ogg

    # Default server build
    #./configure --prefix="/home/deploy/ffmpeg_build" --bindir="/home/deploy/bin" \
    #  --extra-cflags="-I/home/deploy/ffmpeg_build/include -static" --extra-ldflags="-L/home/deploy/ffmpeg_build/lib -static" \
    #  --extra-libs="-ldl" --disable-shared --enable-static --enable-gpl --enable-nonfree \
    #  --disable-ffplay --disable-debug --disable-devices --disable-filters --disable-doc --disable-htmlpages --disable-manpages \
    #  --disable-podpages --disable-txtpages --enable-libx264 --enable-libvpx --enable-libfdk-aac \
    #  --enable-libmp3lame --enable-libtheora --enable-libvorbis

    cflags = "-I#{ffmpeg_build_path}/include"
    cflags += " -static" if ffmpeg_static_build
    ldflags = "-L#{ffmpeg_build_path}/lib"
    ldflags += " -static" if ffmpeg_static_build
    config = "--prefix=\"#{ffmpeg_build_path}\" --bindir=\"#{ffmpeg_bin_path}\" \
  --extra-cflags=\"#{cflags}\" --extra-ldflags=\"#{ldflags}\" --extra-libs=\"-ldl\" \
  --enable-gpl --enable-nonfree"
    config += " --enable-libx264" if ffmpeg_enable_x264
    config += " --enable-libmp3lame" if ffmpeg_enable_mp3
    config += " --enable-libvpx" if ffmpeg_enable_vpx
    config += " --enable-libfdk-aac" if ffmpeg_enable_aac
    config += " --enable-libtheora --enable-libvorbis" if ffmpeg_enable_ogg
    config += " --enable-libass" if ffmpeg_enable_ass
    config += " --disable-shared --enable-static" if ffmpeg_static_build
    config += " --disable-ffplay --disable-debug --disable-devices --disable-doc \
  --disable-htmlpages --disable-manpages --disable-podpages --disable-txtpages" if ffmpeg_server_build
    config += " --enable-x11grab" unless ffmpeg_server_build

    # Note: The PKG_CONFIG_PATH path and profile must be exported before
    # building anything with ffmpeg.
    #run "cd #{ffmpeg_source_path}
    #    && rm -rf ffmpeg
    #    && git clone --depth 1 git://source.ffmpeg.org/ffmpeg"
    run "cd #{ffmpeg_source_path}/ffmpeg
        && PKG_CONFIG_PATH=\"#{ffmpeg_build_path}/lib/pkgconfig\"
        && export PKG_CONFIG_PATH
        && . ~/.profile
        && ./configure #{config} #{ffmpeg_extra_flags}
        && make
        && #{sudo} make install
        && hash -r" #x264 ffmpeg ffplay ffprobe

    # Add our bin path to .bashrc
    # TODO: Check if it already exists
    run "echo PATH=\"#{ffmpeg_bin_path}:$PATH\" >> ~/.bashrc"

    # qt-faststart
    # This tool enables us to move the moov atom (lol) to the
    # beginning of h264 encoded mp4 files for resumable streaming.
    run "cd #{ffmpeg_source_path}/ffmpeg
        && make tools/qt-faststart
        && #{sudo} make install"
  end
  after "deploy:install", "ffmpeg:install"

  task :install_yasm do
    run "cd #{ffmpeg_source_path}
        && wget http://www.tortall.net/projects/yasm/releases/yasm-1.2.0.tar.gz
        && rm -rf yasm-1.2.0
        && tar -xzf yasm-1.2.0.tar.gz"
    run "cd #{ffmpeg_source_path}/yasm-1.2.0
        && ./configure --prefix=\"#{ffmpeg_build_path}\" --bindir=\"#{ffmpeg_bin_path}\"
        && make
        && #{sudo} make install
        && make distclean
        && . ~/.profile"
  end

  desc "Install libvpx VP8 video encoder"
  task :install_libvpx do
    config = "--prefix=\"#{ffmpeg_build_path}\" --disable-examples"
    config += " --disable-shared --enable-static" if ffmpeg_static_build

    run "cd #{ffmpeg_source_path}
        && rm -rf libvpx
        && git clone --depth 1 http://git.chromium.org/webm/libvpx.git"
    run "cd #{ffmpeg_source_path}/libvpx
        && . ~/.profile
        && ./configure #{config}
        && make
        && #{sudo} make install
        && make clean"
  end

  desc "Install xvidcore XVID video encoder"
  task :install_xvidcore do
    config = "--prefix=\"#{ffmpeg_build_path}\" --bindir=\"#{ffmpeg_bin_path}\""
    config += " --disable-shared --enable-static" if ffmpeg_static_build

    run "cd #{ffmpeg_source_path}
        && wget http://downloads.xvid.org/downloads/xvidcore-1.3.2.tar.gz
        && rm xvidcore-1.3.2
        && tar -xzf xvidcore-1.3.2.tar.gz"
    run "cd #{ffmpeg_source_path}/xvidcore-1.3.2
        && . ~/.profile
        && ./configure #{config}
        && make
        && #{sudo} make install
        && make distclean"
  end
  
  desc "Install fdk-aac AAC audio encoder"
  task :install_fdkaac do
    config = "--prefix=\"#{ffmpeg_build_path}\" --disable-shared"
    config += " --disable-shared --enable-static" if ffmpeg_static_build

    #    && rm -rf fdk-aac
    run "cd #{ffmpeg_source_path}
        && git clone --depth 1 git://github.com/mstorsjo/fdk-aac.git"
    run "cd #{ffmpeg_source_path}/fdk-aac
        && autoreconf -fiv
        && ./configure #{config}
        && make
        && #{sudo} make install
        && make distclean"
  end

  desc "Install libogg Ogg bitstream library. Required by libtheora and libvorbis."
  task :install_ogg do
    config = "--prefix=\"#{ffmpeg_build_path}\" --disable-shared"
    config += " --disable-shared --enable-static" if ffmpeg_static_build

    # run "cd && git clone --depth 1 git://git.videolan.org/x264"
    #run  "rm -rf x264-snapshot-*"
    run "cd #{ffmpeg_source_path}
        && wget http://downloads.xiph.org/releases/ogg/libogg-1.3.1.tar.gz
        && rm -rf libogg-1.3.1
        && tar -xzf libogg-1.3.1.tar.gz"
    run "cd #{ffmpeg_source_path}/libogg-1.3.1
        && . ~/.profile
        && ./configure #{config}
        && make
        && #{sudo} make install
        && make distclean"
  end

  desc "Install libtheora Theora video encoder. Requires libogg."
  task :install_theora do
    config = "--prefix=\"#{ffmpeg_build_path}\" --with-ogg=\"#{ffmpeg_bin_path}\" --disable-examples --disable-shared --disable-sdltest --disable-vorbistest"
    config += " --disable-shared --enable-static" if ffmpeg_static_build

    run "cd #{ffmpeg_source_path}
        && wget http://downloads.xiph.org/releases/theora/libtheora-1.1.1.tar.gz
        && rm -rf libtheora-1.1.1
        && tar -xzf libtheora-1.1.1.tar.gz"
    run "cd #{ffmpeg_source_path}/libtheora-1.1.1
        && . ~/.profile
        && ./configure #{config}
        && make
        && #{sudo} make install
        && make distclean"
  end

  desc "Install libvorbis Vorbis audio encoder. Requires libogg."
  task :install_vorbis do
    config = "--prefix=\"#{ffmpeg_build_path}\" --with-ogg=\"#{ffmpeg_bin_path}\" --disable-shared"
    config += " --disable-shared --enable-static" if ffmpeg_static_build

    run "cd #{ffmpeg_source_path}
        && wget http://downloads.xiph.org/releases/vorbis/libvorbis-1.3.3.tar.gz
        && rm -rf libvorbis-1.3.3
        && tar -xzf libvorbis-1.3.3.tar.gz"
    run "cd #{ffmpeg_source_path}/libvorbis-1.3.3
        && . ~/.profile
        && ./configure #{config}
        && make
        && #{sudo} make install
        && make distclean"
  end

  desc "Install x264 h.264 encoder"
  task :install_x264 do
    config = "--prefix=\"#{ffmpeg_build_path}\" --bindir=\"#{ffmpeg_bin_path}\""
    config += " --enable-pic --disable-opencl" if host_architecture == "x86_64"
    config += " --disable-shared --enable-static" if ffmpeg_static_build
    
    # run "cd && git clone --depth 1 git://git.videolan.org/x264"
    run "cd #{ffmpeg_source_path} 
        && wget ftp://ftp.videolan.org/pub/x264/snapshots/last_x264.tar.bz2
        && rm -rf x264-snapshot-*
        && tar -jxvf last_x264.tar.bz2"
    run "cd #{ffmpeg_source_path}/x264-snapshot-*
        && . ~/.profile
        && ./configure #{config}
        && make
        && #{sudo} make install
        && make distclean"
  end

  desc "Update ffmpeg"
  task :update do
    # TODO: see UbuntuCompilationGuide
  end

#  desc "Remove installed ffmpeg and dependencies"
#  task :uninstall do
#    run "rm -rf #{ffmpeg_build_path} #{ffmpeg_source_path} #{ffmpeg_bin_path}/{ffmpeg,ffprobe,ffserver,vsyasm,x264,yasm,ytasm}"
#    sudo "apt-get autoremove autoconf automake build-essential git libass-dev libgpac-dev \
#  libmp3lame-dev libopus-dev libtheora-dev libtool libva-dev libvdpau-dev \
#  libvorbis-dev libvpx-dev libx11-dev libxext-dev libxfixes-dev texi2html zlib1g-dev#"
#    #libsdl1.2-dev
#    run "hash -r"
#  end
end



    #PKG_CONFIG_PATH="/home/deploy/ffmpeg_build/lib/pkgconfig"
    #export PKG_CONFIG_PATH

    #sudo "sh -c 'echo \"#{ffmpeg_build_path}/lib\" > /etc/ld.so.conf.d/opencv.conf'"
    #sudo "ldconfig"

    #sudo sh -c 'echo "/home/deploy/ffmpeg_build/lib" > /etc/ld.so.conf.d/ffmpeg.conf'
    #sudo ldconfig
    #export PATH=/usr/local/cuda/bin:$PATH
    #export LPATH=/usr/lib/nvidia-current:$LPATH
    #export LIBRARY_PATH=/home/deploy/ffmpeg_build/lib:$LIBRARY_PATH
    # export LD_LIBRARY_PATH=/home/deploy/ffmpeg_build/lib:$LD_LIBRARY_PATH


    #run "cd ~/ffmpeg
    #    && ./configure --enable-gpl --enable-libfaac --enable-libfdk-aac --enable-libmp3lame --enable-libopencore-amrnb --enable-libopencore-amrwb --enable-librtmp --enable-libtheora --enable-libvorbis --enable-libvpx --enable-x11grab --enable-libx264 --enable-nonfree --enable-version3

    # install yasm (can use apt-get install yasm for Ubuntu 13.04)
    #run "cd #{ffmpeg_source_path}"
    #run "wget http://www.tortall.net/projects/yasm/releases/yasm-1.2.0.tar.gz"
    #run "tar xzvf yasm-1.2.0.tar.gz"
    #run "cd yasm-1.2.0"
    #run "./configure --prefix=\"#{ffmpeg_build_path}\" --bindir=\"#{ffmpeg_bin_path}\""
    #run "make"
    #run "make install"
    #run "make distclean"
    #run ". ~/.profile"



    # install yasm (can use apt-get install yasm for Ubuntu 13.04)
    #run "cd #{ffmpeg_source_path}"
    #run "wget http://www.tortall.net/projects/yasm/releases/yasm-1.2.0.tar.gz"
    #run "tar xzvf yasm-1.2.0.tar.gz"
    #run "cd yasm-1.2.0"
    #run "./configure --prefix=\"#{ffmpeg_build_path}\" --bindir=\"#{ffmpeg_bin_path}\""
    #run "make"
    #run "make install"
    #run "make distclean"
    #run ". ~/.profile"

    # install x264
    #run "cd #{ffmpeg_source_path}"
    #run "git clone --depth 1 git://git.videolan.org/x264.git"
    #run "cd x264"
    #run "./configure --prefix=\#{ffmpeg_build_path}\" --bindir=\"#{ffmpeg_bin_path}\" --enable-static"
    #run "make"
    #run "make install"
    #run "make distclean"

    # install libvpx (can use apt-get install libvpx-dev for Ubuntu 13.04)
    #run "cd #{ffmpeg_source_path}"
    #run "git clone --depth 1 http://git.chromium.org/webm/libvpx.git"
    #run "cd libvpx"
    #run "./configure --prefix=\"#{ffmpeg_build_path}\" --disable-examples"
    #run "make"
    #run "make install"
    #run "make clean"

    # install ffmpeg
    #run "cd #{ffmpeg_source_path}"
    #run "git clone --depth 1 git://source.ffmpeg.org/ffmpeg"
    #run "cd ffmpeg"

    # server users should remove --enable-x11grab from the following command:
    #command =

    #run "./configure --prefix=\"#{ffmpeg_build_path}\" \
  #--extra-cflags=\"-I#{ffmpeg_build_path}/include\" --extra-ldflags=\"-L#{ffmpeg_build_path}/lib\" \
  #--bindir=\"#{ffmpeg_bin_path}\" --extra-libs=\"-ldl\" --enable-gpl --enable-libass --enable-libfdk-aac \
  #--enable-libmp3lame --enable-libopus --enable-libtheora --enable-libvorbis --enable-libvpx \
  #--enable-libx264 --enable-nonfree --enable-x11grab"
    #run "make"
    #run "make install"
    #run "make distclean"
    #run "hash -r"

    # we could also install ffmpeg from snapshot
    #cd ~/src
    #wget http://ffmpeg.org/releases/ffmpeg-0.11.1.tar.bz2
    #tar xvf ffmpeg-0.11.1.tar.bz2
    #cd ffmpeg-0.11.1
    #./configure --enable-gpl --enable-libfaac --enable-libmp3lame --enable-libopencore-amrnb --enable-libopencore-amrwb --enable-libtheora --enable-libvorbis --enable-libx264 --enable-libxvid --enable-nonfree --enable-postproc --enable-version3 --enable-x11grab
    #make
    #sudo make install

    # export library paths.
    #cat <<'EOF' > /etc/ld.so.conf.d/ffmpeg.conf
    #  /usr/local/lib
    #EOF
    #sudo ldconfig /etc/ld.so.conf


    # remove existing ffmpeg installations
    #sudo "apt-get -y remove ffmpeg x264 libav-tools libvpx-dev libx264-dev"

    # install dependencies for x264 and ffmpeg
    #sudo "apt-get -y install build-essential checkinstall libfaac-dev libjack-jackd2-dev libmp3lame-dev libopencore-amrnb-dev libopencore-amrwb-dev libsdl1.2-dev libtheora-dev libva-dev libvdpau-dev libvorbis-dev libx11-dev libxfixes-dev libxvidcore-dev texi2html yasm zlib1g-dev"