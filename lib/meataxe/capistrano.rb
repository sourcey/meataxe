Dir.glob(File.join(File.dirname(__FILE__), 'capistrano/tasks/*.cap')).each { |r| load r }

# First try and copy the file `config/deploy/#{full_app_name}/#{from}.erb`
# to `shared/config/to`
#
# If the original source path doesn exist then it will search in:
# `config/deploy/shared/#{from}.erb`
# This allows files which are common to all enviros to come from a single
# source while allowing specific ones to be over-ridden.
# If the target file name is the same as the source then the second parameter
# can be left out.
def smart_template(from, to=nil)
  to ||= from
  full_to_path = "#{shared_path}/config/#{to}"
  if from_erb_path = template_file(from)
    from_erb = StringIO.new(ERB.new(File.read(from_erb_path)).result(binding))
    upload! from_erb, full_to_path
    info "copying: #{from_erb} to: #{full_to_path}"
  else
    error "error #{from} not found"
  end
end

def template_file(name)
  # if File.exist?((file = "config/deploy/#{fetch(:full_app_name)}/#{name}.erb"))
  #   return file
  # els
  if File.exist?((file = "config/deploy/templates/#{name}.erb"))
    return file
  elsif File.exist?((file = File.join(File.dirname(__FILE__), "capistrano/templates/#{name}.erb")))
    return file
  end
  return nil
end

# We often want to refer to variables which are defined in subsequent stage
# files. This let's us use the {{var}} to represent fetch(:var) in strings
# which are only evaluated at runtime.
def sub_strings(input_string)
  output_string = input_string
  input_string.scan(/{{(\w*)}}/).each do |var|
    output_string.gsub!("{{#{var[0]}}}", fetch(var[0].to_sym))
  end
  output_string
end

def host_architecture
  capture("uname -m")
end

def update_repo(repo_url, target_path)
  run "if [ -d #{target_path} ]; then (cd #{target_path} && git pull); else git clone #{repo_url} #{target_path}; fi"
  #run "cd #{target_path} && if [ -d #{target_path} ]; then (git pull); else (cd #{target_path} && cd.. && git clone #{repo_url} #{target_path}); fi"
end
