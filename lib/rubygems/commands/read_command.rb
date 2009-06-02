# ReadCommand will open a gem's rdoc
class Gem::Commands::ReadCommand < Gem::Command
  include OpenGem::CommonOptions
  include Gem::VersionOption
  
  def initialize
    super 'read', "Opens the gem's documentation", 
      :command => 'open', 
      :version=>  Gem::Requirement.default,
      :latest=>   false
    
    add_command_option "Application to read rdoc with"
    add_latest_version_option
    add_version_option
  end
  
  def arguments # :nodoc:
    "GEMNAME       gem to read"
  end

  def execute
    name = get_one_gem_name
    spec = get_spec name
    if spec
      path = get_path(spec)
      if File.exists? path
        read_gem path
      else
        say "The rdoc seems to be missing, TODO: generate"
      end
    end
  end
  
  def get_path(spec)
    File.join(spec.installation_path, "doc", spec.full_name, 'rdoc','index.html')
  end
  
  def get_spec(name)
    dep = Gem::Dependency.new name, options[:version]
    specs = Gem.source_index.search(dep).select{|spec| spec.has_rdoc?}
    
    if specs.length == 0
      say "Could not find docs for '#{name}'"
      return nil
      
    elsif specs.length == 1 || options[:latest]
      return specs.last
      
    else
      choices = specs.map{|s|"#{s.name} #{s.version}"}
      c,i = choose_from_list "Open which gem?", choices
      return specs[i] if i
      
    end
  end

  def read_gem(path)
    editor = options[:command]
    command_parts = Shellwords.shellwords(editor)
    command_parts << path
    success = system(*command_parts)
    if !success 
      raise Gem::CommandLineError, "Could not run '#{editor} #{path}', exit code: #{$?.exitstatus}"
    end
  end
  
end