# Dependencies:
# Git
# GCC >= 4.8 (c++11)
# OpenCV >= 2.4.5 (optional)
# FFmpeg >= 10.1 (optional)
# OpenSSL

set_default :libsourcey_repos, ["https://sourcey@bitbucket.org/sourcey/anionu-sdk.git"]
set_default :libsourcey_server_build, true
set_default :libsourcey_path, "/home/#{user}/src/libsourcey"
set_default :libsourcey_install_prefix, libsourcey_server_build ? "/home/#{user}/local" : "/usr/local"
set_default :libsourcey_cmake_opts, " -DBUILD_SHARED_LIBS=OFF -DCMAKE_BUILD_TYPE=RELEASE \
    -DBUILD_MODULES=ON -DBUILD_MODULE_TESTS=OFF -DBUILD_SAMPLES=OFF \
    -DBUILD_DEPENDENCIES=ON -DBUILD_APPLICATIONS=ON"
set_default :libsourcey_cmake_server, " -DWITH_WXWIDGETS=OFF 
    -DBUILD_MODULE_pacman=OFF -DBUILD_MODULE_socketio=OFF -DBUILD_MODULE_symple=OFF \
    -DBUILD_MODULE_sked=OFF -DBUILD_APPLICATION_spotplugins=OFF -DBUILD_MODULE_anionu=OFF"

namespace :libsourcey do
  desc "Install the latest release of LibSourcey"
  task :install, roles: :app do
    sudo "apt-get -y install openssl libssl-dev cmake pkg-config libjack-jackd2-dev"     
    checkout
    build
  end
  after "deploy:install", "libsourcey:install"

  desc "Chechout the latest LibSourcey package"
  task :checkout, roles: :app do    
    update_repo("https://sourcey@bitbucket.org/sourcey/libsourcey.git", "#{libsourcey_path}")
    libsourcey_repos.each do |url|
      update_repo(url, "#{libsourcey_path}/src/#{File.basename(url, ".git")}")
    end
  end

#  desc "Build and Install LibSourcey dependencies"
#  task :build_dependencies, roles: :app do
#    run "mkdir -p #{libsourcey_path}/build
#        && cd #{libsourcey_path}/build
#        && cmake .. #{libsourcey_cmake_opts} #{libsourcey_cmake_deps}
#        && make
#        && #{sudo} make install#"
#  end

#  desc "Build and Install LibSourcey modules"
#  task :build_modules, roles: :app do
#    run "mkdir -p #{libsourcey_path}/build
#        && cd #{libsourcey_path}/build
#        && cmake .. #{libsourcey_cmake_opts} #{libsourcey_cmake_deps} #{libsourcey_cmake_modules}
#        && make
#        && #{sudo} make install#"
#  end

  desc "Build and Install LibSourcey applications"
  task :build_applications, roles: :app do
    options = libsourcey_cmake_opts
    options += " #{libsourcey_cmake_server}"
    run "mkdir -p #{libsourcey_path}/build
        && cd #{libsourcey_path}/build
        && cmake .. #{options}
        && make
        && #{sudo} make install"
  end

  desc "Build and Install the latest release of LibSourcey"
  task :build, roles: :app do
    #build_dependencies
    #build_modules
    build_applications
  end  
end



#set_default :libsourcey_cmake_opts, "-DBUILD_SHARED_LIBS=OFF -DCMAKE_BUILD_TYPE=RELEASE \
#    -DBUILD_DEPENDENCIES=ON -DBUILD_MODULES=ON -DBUILD_MODULE_TESTS=OFF -DBUILD_MODULE_SAMPLES=OFF -DBUILD_APPLICATIONS=ON \
#    -DBUILD_MODULE_Anionu=ON -DBUILD_MODULE_Archo=ON -DBUILD_MODULE_Base=ON -DBUILD_MODULE_Crypto=ON \
#    -DBUILD_MODULE_HTTP=ON -DBUILD_MODULE_JSON=ON -DBUILD_MODULE_Media=ON -DBUILD_MODULE_Net=ON \
#    -DBUILD_MODULE_Pacman=OFF -DBUILD_MODULE_Sked=OFF -DBUILD_MODULE_SocketIO=OFF -DBUILD_MODULE_Symple=OFF \
#    -DBUILD_MODULE_Spot=OFF -DBUILD_MODULE_STUN=ON -DBUILD_MODULE_TURN=ON -DBUILD_MODULE_UV=ON -DBUILD_MODULE_Util=ON \
#    -DDISABLE_MODULES_Spot=ON -DDISABLE_APPLICATIONS_Spot=ON -DBUILD_APPLICATION_SpotPlugins=OFF"

    #cmake -DBUILD_DEPENDENCIES=ON -DBUILD_MODULES=ON -DBUILD_APPLICATIONS=OFF -DBUILD_MODULE_Spot=OFF -DCMAKE_BUILD_TYPE=RELEASE ..
    
    # The below command builds only Base and BaseTests to ensure compatability
    #cmake -DBUILD_DEPENDENCIES=ON -DBUILD_MODULES=ON -DBUILD_MODULE_TESTS=ON  -DBUILD_MODULE_SAMPLES=OFF -DBUILD_APPLICATIONS=OFF \
    # -DBUILD_MODULE_Anionu=OFF -DBUILD_MODULE_Archo=OFF -DBUILD_MODULE_Base=ON -DBUILD_MODULE_Crypto=OFF \
    # -DBUILD_MODULE_HTTP=OFF -DBUILD_MODULE_JSON=OFF -DBUILD_MODULE_Media=OFF -DBUILD_MODULE_Net=OFF \
    # -DBUILD_MODULE_Pacman=OFF -DBUILD_MODULE_STUN=OFF -DBUILD_MODULE_Sked=OFF -DBUILD_MODULE_SocketIO=OFF \
    # -DBUILD_MODULE_Spot=OFF -DBUILD_MODULE_Symple=OFF -DBUILD_MODULE_TURN=OFF -DBUILD_MODULE_UV=OFF -DBUILD_MODULE_Util=OFF \
    # -DBUILD_APPLICATION_SpotPlugins=OFF \
    # -DBUILD_SHARED_LIBS=OFF -DCMAKE_BUILD_TYPE=RELEASE ..

    # The below command builds all Spot server applications
    #cmake -DBUILD_DEPENDENCIES=ON -DBUILD_MODULES=ON -DBUILD_MODULE_TESTS=OFF -DBUILD_MODULE_SAMPLES=OFF -DBUILD_APPLICATIONS=ON \
    # -DBUILD_MODULE_Anionu=ON -DBUILD_MODULE_Archo=ON -DBUILD_MODULE_Base=ON -DBUILD_MODULE_Crypto=ON \
    # -DBUILD_MODULE_HTTP=ON -DBUILD_MODULE_JSON=ON -DBUILD_MODULE_Media=ON -DBUILD_MODULE_Net=ON \
    # -DBUILD_MODULE_Pacman=OFF -DBUILD_MODULE_STUN=OFF -DBUILD_MODULE_Sked=OFF -DBUILD_MODULE_SocketIO=OFF \
    # -DBUILD_MODULE_Spot=OFF -DBUILD_MODULE_Symple=OFF -DBUILD_MODULE_TURN=OFF -DBUILD_MODULE_UV=ON -DBUILD_MODULE_Util=ON \
    # -DBUILD_APPLICATION_SpotPlugins=OFF -DBUILD_APPLICATION_Spot=OFF \
    # -DBUILD_SHARED_LIBS=OFF -DCMAKE_BUILD_TYPE=RELEASE ..

    # The below command builds all modules and applications except Spot
    #cmake -DBUILD_DEPENDENCIES=ON -DBUILD_MODULES=ON -DBUILD_MODULE_TESTS=OFF -DBUILD_MODULE_SAMPLES=OFF -DBUILD_APPLICATIONS=OFF \
    # -DBUILD_MODULE_Anionu=ON -DBUILD_MODULE_Archo=ON -DBUILD_MODULE_Base=ON -DBUILD_MODULE_Crypto=ON \
    # -DBUILD_MODULE_HTTP=ON -DBUILD_MODULE_JSON=ON -DBUILD_MODULE_Media=ON -DBUILD_MODULE_Net=ON \
    # -DBUILD_MODULE_Pacman=ON -DBUILD_MODULE_STUN=ON -DBUILD_MODULE_Sked=ON -DBUILD_MODULE_SocketIO=ON \
    # -DBUILD_MODULE_Spot=ON -DBUILD_MODULE_Symple=ON -DBUILD_MODULE_TURN=ON -DBUILD_MODULE_UV=ON -DBUILD_MODULE_Util=ON \
    # -DBUILD_APPLICATION_SpotPlugins=OFF -DBUILD_APPLICATION_Spot=OFF \
    # -DBUILD_SHARED_LIBS=OFF -DCMAKE_BUILD_TYPE=RELEASE ..

    #cmake -DBUILD_DEPENDENCIES=ON -DBUILD_MODULES=ON -DBUILD_MODULE_TESTS=OFF -DBUILD_MODULE_SAMPLES=OFF -DBUILD_APPLICATIONS=OFF \
    # -DBUILD_MODULE_Anionu=ON -DBUILD_MODULE_Archo=ON -DBUILD_MODULE_Base=ON -DBUILD_MODULE_Crypto=ON \
    # -DBUILD_MODULE_HTTP=ON -DBUILD_MODULE_JSON=ON -DBUILD_MODULE_Media=ON -DBUILD_MODULE_Net=ON \
    # -DBUILD_MODULE_Pacman=ON -DBUILD_MODULE_STUN=ON -DBUILD_MODULE_Sked=ON -DBUILD_MODULE_SocketIO=ON \
    # -DBUILD_MODULE_Spot=ON -DBUILD_MODULE_Symple=ON -DBUILD_MODULE_TURN=ON -DBUILD_MODULE_UV=ON -DBUILD_MODULE_Util=ON \
    # -DBUILD_APPLICATION_SpotPlugins=OFF -DBUILD_APPLICATION_Spot=OFF \
    # -DBUILD_SHARED_LIBS=OFF -DCMAKE_BUILD_TYPE=RELEASE ..

    #run "rm -rf #{libsourcey_path}"   
    #update_repo("https://sourcey@bitbucket.org/sourcey/libsourcey.git", "libsourcey", "#{libsourcey_path}")
    #update_repo("https://sourcey@bitbucket.org/sourcey/anionu-sdk.git", "anionu-sdk", "#{libsourcey_path}/src")
    #update_repo("https://sourcey@bitbucket.org/sourcey/anionu-sdk.git", "anionu-sdk", "#{libsourcey_path}/src/anionu-sdk")"libsourcey", 
      #p url.split('/').last 
    # Todo: extra/private modules?
        # Todo: user defined cmake config options
        #cmake -DBUILD_DEPENDENCIES=OFF -DBUILD_MODULES=ON -DBUILD_SPOT_APPLICATIONS=OFF -DBUILD_APPLICATIONS=ON -DCMAKE_BUILD_TYPE=RELEASE ..
        #cmake -DBUILD_DEPENDENCIES=OFF -DBUILD_MODULES=ON -DBUILD_SPOT_APPLICATIONS=OFF -DBUILD_SPOT_MODULES=OFF -DBUILD_APPLICATIONS=ON -DBUILD_MODULE_SAMPLES=ON -DCMAKE_BUILD_TYPE=RELEASE ..
        #cmake -DBUILD_DEPENDENCIES=OFF -DBUILD_MODULES=ON -DBUILD_SPOT_APPLICATIONS=OFF -DBUILD_SPOT_MODULES=OFF -DBUILD_APPLICATIONS=ON -DBUILD_MODULE_SAMPLES=OFF -DCMAKE_BUILD_TYPE=RELEASE ..
  
    # Build in multiple phases
    # 1) third party dependencies
    # 2) libsourcey modules
    # 3) libsourcey applications

       # && cmake .. -DBUILD_DEPENDENCIES=ON -DBUILD_MODULES=OFF -DBUILD_APPLICATIONS=OFF -DCMAKE_BUILD_TYPE=RELEASE #{libsourcey_cmake_opts}
       # && #{sudo} make install 
       # && cmake .. -DBUILD_DEPENDENCIES=ON -DBUILD_MODULES=ON -DBUILD_APPLICATIONS=OFF -DCMAKE_BUILD_TYPE=RELEASE #{libsourcey_cmake_opts} 
       # && run make install 
       # && cmake .. -DBUILD_DEPENDENCIES=ON -DBUILD_MODULES=ON -DBUILD_APPLICATIONS=ON -DCMAKE_BUILD_TYPE=RELEASE #{libsourcey_cmake_opts} 
       # && #{sudo} make install"
    
    #update_repo("https://sourcey@bitbucket.org/sourcey/anionu.git", "anionu", "#{libsourcey_path}/src")
    #run "mkdir -p #{libsourcey_path} 
    #    && cd #{libsourcey_path}
    #    && if [ cd libsourcey ]; then git pull; else git https://sourcey@bitbucket.org/sourcey/libsourcey.git; fi"
        
    #git clone https://sourcey@bitbucket.org/sourcey/libsourcey.git

    # checkout libsourcey modules
    #run "cd #{libsourcey_path}/src
    #    && git clone https://sourcey@bitbucket.org/sourcey/anionu.git
    #    && git clone https://sourcey@bitbucket.org/sourcey/anionu-sdk.git"