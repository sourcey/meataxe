set_default :gcc_version, "4.8"
set_default :gcc_update_alt, true
set_default :gcc_update_alt_priority, 50

namespace :gcc do
  desc "Install the latest release of gcc"
  task :install, roles: :app do
    sudo "add-apt-repository ppa:ubuntu-toolchain-r/test", :pty => true do |ch, stream, data|
      press_enter(ch, stream, data)
    end
    sudo "apt-get -y update"
    sudo "apt-get -y install gcc-#{gcc_version} g++-#{gcc_version}"
    if gcc_update_alt
      sudo "sudo update-alternatives --remove-all gcc"
      sudo "sudo update-alternatives --remove-all g++"
      sudo "update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-#{gcc_version} #{gcc_update_alt_priority}"
      sudo "update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-#{gcc_version} #{gcc_update_alt_priority}"
      #sudo "update-alternatives --install /usr/bin/c++ cpp-bin /usr/bin/cpp-#{gcc_version} #{gcc_update_alt_priority}"
    end
  end
  after "deploy:install", "gcc:install"
end