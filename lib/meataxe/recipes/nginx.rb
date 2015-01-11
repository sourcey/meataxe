namespace :nginx do
  desc "Install latest stable release of nginx"
  task :install do #, roles: :web
    sudo "add-apt-repository ppa:nginx/stable", :pty => true do |ch, stream, data|
      press_enter(ch, stream, data)
    end
    sudo "apt-get -y update"
    sudo "apt-get -y install nginx"
  end
  after "deploy:install", "nginx:install"

  desc "Setup nginx configuration for this application"
  task :setup, roles: :web do
    # Note: nginx config should now be specified in deploy.rb
    #template "nginx_puma", "/tmp/nginx_conf"
    #run "#{sudo} mv /tmp/nginx_conf /etc/nginx/sites-enabled/#{application}"    
    run "#{sudo} rm -f /etc/nginx/sites-enabled/default"
    # Note: breaks on some setups as symlinks may not have been created
    # Should we create a deploy:restart hook?
    #restart 
  end  
  after "deploy:setup", "nginx:setup" 

  %w[start stop restart reload].each do |command|
    desc "#{command} nginx"
    task command, roles: :web do
      sudo "service nginx #{command}"
    end
  end
end