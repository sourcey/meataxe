set_default :symple_prefix, "/home/#{user}"
set_default :symple_path, "#{symple_prefix}/symple"
set_default :symple_shared_path, "#{symple_path}/shared"
set_default :symple_shared_dirs, ["config", "log", "pids"]
set_default :symple_port, 4800
set_default :symple_allow_anon, false
set_default :symple_ssl_enabled, false
set_default :symple_ssl_key_path, ""
set_default :symple_ssl_cert_path, ""

# Depends on nodejs

namespace :symple do
  desc "Install the latest release of symple"
  task :install, roles: :app do
    set_default_password :redis_password, "Enter redis password: "

    update_repo("https://sourcey@bitbucket.org/sourcey/symple.git", symple_path)
        
    dirs = [symple_shared_path]
    dirs += symple_shared_dirs.map { |d| File.join(symple_shared_path, d) }
    run "mkdir -p #{dirs.join(' ')} && chmod g+w #{dirs.join(' ')}"
        
    template "symple_config", "#{symple_shared_path}/config/config.json"
    template "symple_monit", "#{symple_shared_path}/config/monit.conf"
    template "symple_upstart", "#{symple_shared_path}/config/upstart.conf"
    
    sudo "cp -f #{symple_shared_path}/config/config.json #{symple_path}/server/config.json"
    sudo "cp -f #{symple_shared_path}/config/monit.conf /etc/monit/conf.d/symple-node"
    sudo "cp -f #{symple_shared_path}/config/upstart.conf /etc/init/symple-node.conf"
        
    #run "mkdir -p #{symple_path} && cd #{symple_path}"
    #run "git clone https://sourcey@bitbucket.org/sourcey/symple.git"  
    #template "symple_config", "#{symple_path}/server/config.json"
    #template "symple_monit", "/etc/monit/conf.d/symple-node"
    #template "symple_upstart", "/etc/init/symple-node.conf"
    
    sudo "initctl reload-configuration"
    start
  end
  after "deploy:install", "symple:install"

  %w[start stop restart].each do |command|
    desc "#{command} symple-node"
    task command, roles: :web do
      sudo "service symple-node #{command}"
    end
  end
end
