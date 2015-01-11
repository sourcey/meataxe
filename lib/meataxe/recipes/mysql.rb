namespace :mysql do
  desc "Install the latest release of mysql"
  task :install, roles: :app do
    set_default :mysql_server_version, "5.5"
    set_default_password :mysql_root_passwd, "Enter mysql root password: "
    
    template "mysql_preseed", "/tmp/mysql_preseed"
    sudo "debconf-set-selections /tmp/mysql_preseed"
    sudo "rm -f /mysql_preseed"

    sudo "apt-get install -y mysql-client libmysql-ruby libsqlite3-dev libmysqlclient-dev mysql-server-#{fetch :mysql_server_version}"
  end
  after "deploy:install", "mysql:install"

  %w[start stop restart].each do |command|
    desc "#{command} mysql"
    task command, roles: :web do
      sudo "service mysql #{command}"
    end
  end
end
    
    
# install server
#sudo "apt-get -y install mysql-server-#{fetch :mysql_version}" do |ch, stream, data|
#  # prompts for mysql root password (when blue screen appears)
#  channel.send_data("#{mysql_passwd}\n\r") if data =~ /password/      
#  #set_password(ch, stream, data)
#end