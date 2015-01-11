set_default :redis_install_monit, true

namespace :redis do
  desc "Install the latest release of Redis"
  task :install, roles: :app do
    sudo "add-apt-repository ppa:chris-lea/redis-server", :pty => true do |ch, stream, data|
      press_enter(ch, stream, data)
    end
    sudo "apt-get -y update"
    sudo "apt-get -y install redis-server"
  end
  after "deploy:install", "redis:install"

  task :configure, roles: :app do       
    opt = Capistrano::CLI.ui.ask "Daemonize? [yes|no]:"        
    sudo "sed -i 's/daemonize no/daemonize #{opt}/' /etc/redis.conf" if (opt == 'yes' || opt == 'no')  
       
    # TODO: password and other options    
    
    #raise RuntimeError.new('db:setup aborted!') unless
    #val Capistrano::CLI.ui.ask(
    #  "About to `rake db:setup`. Are you sure to wipe the entire database (anything other than 'yes' aborts):") == 'yes'    
    # ["sudo sed -i 's/daemonize no/daemonize yes/' /etc/redis.conf",
    # "sudo sed -i 's/^pidfile \/var\/run\/redis.pid/pidfile \/tmp\/redis.pid/' /etc/redis.conf"].each {|cmd| run cmd} 
        
    # install monit script
    if redis_install_monit
      run "mkdir -p /home/#{user}/tmp"
      template "redis_monit", "/home/#{user}/tmp/redis-monit.conf"  
      sudo "cp -f /home/#{user}/tmp/monit.conf /etc/monit/conf.d/redis"
    end
  end
  
  %w[start stop restart].each do |command|
    desc "#{command} redis"
    task command, roles: :web do
      sudo "service redis-server #{command}"
    end
  end
end