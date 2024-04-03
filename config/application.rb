require "pry"
require "time"

Dir.glob(File.join(__dir__,  '../application/ATM/**/*.rb')).each do |file|
  require file
end
