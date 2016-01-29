libraries_path = File.expand_path('../../libraries', __FILE__)
$LOAD_PATH.unshift(libraries_path) unless $LOAD_PATH.include?(libraries_path)

require 'chefspec'
require 'chefspec/berkshelf'

ChefSpec::Coverage.start!

RSpec.configure do |config|
  config.log_level = :error
end
