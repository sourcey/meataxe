namespace :nodejs do
  desc "Install the latest relase of Node.js"
  task :install, roles: :app do
    sudo "add-apt-repository ppa:chris-lea/node.js", :pty => true do |ch, stream, data|
      press_enter(ch, stream, data)
    end
    sudo "apt-get -y update"
    sudo "apt-get -y install nodejs"
    sudo "ln -nfs /usr/bin/node /usr/local/bin/node"
    sudo "ln -nfs /usr/lib/node /usr/local/lib/node"
    sudo "ln -nfs /usr/bin/npm /usr/local/bin/npm"
  end
  after "deploy:install", "nodejs:install"
end