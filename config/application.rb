require "pry"

# require "./application/ATM/exceptions/add_empty_notes_in_atm_exception"

Dir.glob(File.join(__dir__,  '../application/ATM/exceptions/*.rb')).each do |file|
  require file
end

require "./application/ATM/domain/cash_machine.rb"
require "./application/ATM/domain/cash_note.rb"
