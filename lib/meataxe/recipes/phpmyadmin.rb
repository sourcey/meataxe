namespace :phpmyadmin do
  desc "Install the latest release of phpmyadmin"
  task :install, roles: :app do
    set_default :phpmyadmin_cfg_dbconfig_common, false  # boolean
    set_default :phpmyadmin_cfg_webserver, ''           # multiselect: [apache2|lighttpd]
    set_default_password :mysql_root_passwd, "Enter mysql root password: "
    
    template "phpmyadmin_preseed", "/tmp/phpmyadmin_preseed"
    sudo "debconf-set-selections /tmp/phpmyadmin_preseed"
    sudo "rm -f /phpmyadmin_preseed"
    
    sudo "apt-get install -y php5-cgi php5-mysql phpmyadmin"   
    
    # PHP FastCGI initializer (TODO: Separate PHP installation)
    template "templates/fastcgi_init", "/etc/init.d/php-fastcgi"
    sudo "chmod +x /etc/init.d/php-fastcgi"
    sudo "service php-fastcgi start"
    sudo "update-rc.d php-fastcgi defaults"
    
    # Nginx phpMyAdmin config file
    template "templates/phpmyadmin_nginx", "/etc/nginx/sites-available/phpmyadmin"
    sudo "ln -nfs /etc/nginx/sites-available/phpmyadmin /etc/nginx/sites-enabled/phpmyadmin"
  end
  after "deploy:install", "phpmyadmin:install"

  %w[start stop restart].each do |command|
    desc "#{command} phpmyadmin"
    task command, roles: :web do
      sudo "service phpmyadmin #{command}"
    end
  end
end

    
    # Next we make the script executable and make it auto-startup by default.
    # You will see the following questions:
    # Web server to reconfigure automatically: <-- select none (because only apache2 and lighttpd are available as options)
    # Configure database for phpmyadmin with dbconfig-common? <-- No