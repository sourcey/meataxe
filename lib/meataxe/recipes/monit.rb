namespace :monit do
  desc "Install the latest release of Monit"
  task :install, roles: :app do
    sudo "apt-get -y install monit"
  end
  after "deploy:install", "monit:install"

  desc "Print current Monit status"
  task :status, roles: :app do
    sudo "#{sudo} monit status"
  end
  
  %w[start stop restart].each do |command|
    desc "#{command} Monit"
    task command, roles: :web do
      sudo "service monit #{command}"
    end
  end
end