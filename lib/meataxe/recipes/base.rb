def set_default(name, *args, &block)
  set(name, *args, &block) unless exists?(name)
end

def set_default_password(name, prompt, &block)
  set(name, Capistrano::CLI.password_prompt(prompt), &block) unless exists?(name)
end

set_default :recipe_mods, []
def using?(mod)
  recipe_mods.include?(mod)
end

# Load the recipes to deploy with such as: [:users, :monit, :nginx]
def install_recipes(mods)
  set :recipe_mods, mods
  Dir.glob(File.expand_path("./*.rb", File.dirname(__FILE__))).sort.each do |f| 
    if using? File.basename(f, ".rb").to_sym then load f; end
  end
end

def template(from, to)
  tmpl = File.read(File.expand_path("./templates/#{from}", File.dirname(__FILE__)))    
  put ERB.new(tmpl, nil, "-").result(binding), to
end

# BUG for "Press [ENTER] to continue or ctrl-c to cancel adding it"
def press_enter(ch, stream, data)
  if data =~ /Press.\[ENTER\].to.continue/
    # prompt, and then send the response to the remote process
    ch.send_data("\n")
  else
    # use the default handler for all other text
    Capistrano::Configuration.default_io_proc.call(ch, stream, data)
  end
end

def set_password(ch, stream, data)
  #if data =~ /Enter new UNIX password:/
  if data =~ /Enter new|New password/
    ch.send_data(Capistrano::CLI.password_prompt("Enter new password: ") + "\n")
  #elsif data =~ /Retype new UNIX password:/
  elsif data =~ /Retype new|Repeat password/
    ch.send_data(Capistrano::CLI.password_prompt("Retype new password: ") + "\n")
  else
    Capistrano::Configuration.default_io_proc.call(ch, stream, data)
  end
end

def change_password(user = "root")
  run "passwd #{user}", :pty => true do |ch, stream, data|
    set_password(ch, stream, data)
  end
end

def host_architecture
  capture("uname -m")
end

def update_repo(repo_url, target_path) # = "~/src"
  run "if [ -d #{target_path} ]; then (cd #{target_path} && git pull); else git clone #{repo_url} #{target_path}; fi"
  #run "cd #{target_path} && if [ -d #{target_path} ]; then (git pull); else (cd #{target_path} && cd.. && git clone #{repo_url} #{target_path}); fi"
end

#def update_repo(repo_url, package_name, base_path = "~/src")
#  run "mkdir -p #{base_path}
#        && cd #{base_path}
#        && if [ -d #{package_name} ]; then (cd #{package_name} && git pull); else git clone #{repo_url} #{package_name}; fi"
#end

namespace :deploy do
  desc "Install everything onto the server"
  task :install do
    sudo "apt-get -y update"
    sudo "apt-get -y upgrade"
    sudo "apt-get -y install build-essential python-software-properties software-properties-common debconf-utils ssh curl git"
  end
end

