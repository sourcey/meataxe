# http://www.capistranorb.com/documentation/getting-started/authentication-and-authorisation/

namespace :users do
  desc "Setup SSH keys for deploy user"
  task :setup_ssh do    
    run "mkdir -p /home/#{user}/.ssh"
    run "chmod 0700 /home/#{user}/.ssh"
    top.upload File.join(ENV["HOME"], ".ssh", "id_rsa"), "/home/#{user}/.ssh/id_rsa"
    top.upload File.join(ENV["HOME"], ".ssh", "id_rsa.pub"), "/home/#{user}/.ssh/id_rsa.pub"
    top.upload File.join(ENV["HOME"], ".ssh", "id_rsa.pub"), "/home/#{user}/.ssh/authorized_keys" # TODO: Use ssh-add here  
    run "chmod 600 /home/#{user}/.ssh/*"        
  end
  before "deploy:setup", "users:setup_ssh"
end
        
    # check https://github.com/sevenscale/sevenscale_deploy/blob/master/recipes/sevenscale_deploy/users.rb

    # deploy SSH keys
    #if setup_ssh
    #end   
        
    # options
    #set_default :setup_ssh_keys, true
    #set_default :grant_deploy_user_sudo, true
    
    #begin     
    #rescue Capistrano::CommandError => e
    #  logger.important "*** Could not create deploy user: #{e}"
    #end 
      #run "chown -R deploy:deploy /home/#{user}/.ssh"  
#_keys  
      #template "shared/known_hosts", "/home/#{user}/.ssh/known_hosts"    
      #ssh-keyscan -t rsa,dsa bitbucket.org 2>&1 | sort -u - /root/.ssh/known_hosts > /root/.ssh/tmp_hosts
      #cat /root/.ssh/tmp_hosts > /root/.ssh/known_hosts

  #def create_user(user, options = {})
  #    # create deploy user      
  #    run "useradd -U -s /bin/bash -m deploy"
        
  #    # set deploy password
  #    run "passwd deploy", :pty => true do |ch, stream, data|
  #      set_password(ch, stream, data)
  #    end  
    
   #   # add to sudoers if required
  #    run "adduser deploy sudo" if grant_deploy_user_sudo
  #end
      
    # root SSH keys
    #if setup_ssh_keys      
    #  puts "*** Setup SSH keys for root user"
    #  run "mkdir -p /root/.ssh"
    #  run "chmod 0700 /root/.ssh"
    #  template "shared/id_rsa", "/root/.ssh/id_rsa"
    #  template "shared/id_rsa.pub", "/root/.ssh/id_rsa.pub"
    #  template "shared/id_rsa.pub", "/root/.ssh/authorized_keys" # TODO: Use ssh-add here
    #  template "shared/known_hosts", "/root/.ssh/known_hosts"  
    #  run "chmod 600 /root/.ssh/*"
    #end 
     
    #begin
    #rescue Capistrano::CommandError => e
    #  logger.important "*** Could not setup root user: #{e}"
    #end 