$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'dnet'
require 'spec'
require 'spec/autorun'

include Dnet

p ARGV

NET_DEV = ENV['DNET_TEST_INTERFACE']

Spec::Runner.configure do |config|

end
