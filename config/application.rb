require "time"
require "json"

Dir.glob(File.join(__dir__,  '../application/ATM/**/*.rb')).each do |file|
  require file
end

Dir.glob(File.join(__dir__,  '../input_interface/**/*.rb')).each do |file|
  next if file.include?("home.rb")

  require file
end
