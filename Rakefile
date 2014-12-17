require 'rubygems'
require 'rake'
require 'echoe'

Echoe.new('graph', '0.1.1') do |p|
  p.description               = 'Implement base functionality to work with graphs'
  p.url                       = 'http://github.com/Arkanain/graph'
  p.author                    = 'Yuri Holubchenko'
  p.email                     = 'arkanainkiller@gmail.com'
  p.ignore_pattern            = ['tmp/*', 'script/*']
  p.development_dependencies  = []
end

Dir["#{File.dirname(__FILE__)}/tasks/*.rake"].sort.each { |ext| load ext }