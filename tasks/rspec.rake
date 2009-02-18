begin
  require 'spec'
  require 'spec/rake/spectask'
  
  desc "Run all the specs in spec directory"
  Spec::Rake::SpecTask.new( :spec ) do |t|
    t.spec_opts = [ '--options', "spec/spec.opts" ]
    t.spec_files = FileList[ 'spec/**/*_spec.rb' ]
  end

  namespace :spec do
    begin
      require 'rcov'
      
      desc "Run all specs in spec directory with RCov"
      Spec::Rake::SpecTask.new( :rcov ) do |t|
        t.spec_opts = [ '--options', "spec/spec.opts" ]
        t.spec_files = FileList[ 'spec/**/*_spec.rb' ]
        t.rcov = true
        t.rcov_opts = [ '--exclude', "spec" ]
      end
      
    rescue LoadError
      puts <<-EOS
      To use rcov for testing you must install rcov gem:
        gem install rcov

    EOS
    end
  end
  
rescue LoadError
  puts <<-EOS
  To use rspec for testing you must install rspec gem:
    gem install rspec

EOS
end

