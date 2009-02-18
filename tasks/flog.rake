desc "Run flog over significant files"
task :flog do
  sh "find lib -name \\*.rb | xargs flog"
end
