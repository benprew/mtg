require 'flay'

desc 'Check for code duplication'
task 'flay' do
  files = FileList['lib/**/*.rb']
  flayer = Flay.new(16)
  flayer.process(*files)
  flayer.report
end
