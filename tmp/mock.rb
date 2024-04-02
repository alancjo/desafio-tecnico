# mock

require_relative "domain/cash_note.rb"
require_relative "domain/cash_machine.rb"

cash_notes = [Application::ATM::CashNote.new(id: 1, value: 10, quantity: 2), Application::ATM::CashNote.new(id: 2, value: 20, quantity: 4),
Application::ATM::CashNote.new(id: 3, value: 50, quantity: 5), Application::ATM::CashNote.new(id: 4, value: 100, quantity: 1)]

cash_machine = Application::ATM::CashMachine.new(id: 1)

cash_machine.add_notes(cash_notes)

cash_notes2 = [Application::ATM::CashNote.new(id: 5, value: 10, quantity: 5), Application::ATM::CashNote.new(id: 6, value: 20, quantity: 0),
             Application::ATM::CashNote.new(id: 7, value: 50, quantity: 0), Application::ATM::CashNote.new(id: 8, value: 100, quantity: 2)]

cash_machine.add_notes(cash_notes2)
