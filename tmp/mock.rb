# mock

require_relative "./domain/cash_note.rb"
require_relative "./domain/cash_machine.rb"

# abastecer caixa

cash_notes = [Application::ATM::Domain::CashNote.new(id: 1, value: 10, quantity: 2), Application::ATM::Domain::CashNote.new(id: 2, value: 20, quantity: 4),
Application::ATM::Domain::CashNote.new(id: 3, value: 50, quantity: 5), Application::ATM::Domain::CashNote.new(id: 4, value: 100, quantity: 1)]

cash_machine = Application::ATM::Domain::CashMachine.new(id: 1)

cash_machine.add_notes(cash_notes)

cash_notes2 = [Application::ATM::Domain::CashNote.new(id: 5, value: 10, quantity: 5), Application::ATM::Domain::CashNote.new(id: 6, value: 20, quantity: 0),
             Application::ATM::Domain::CashNote.new(id: 7, value: 50, quantity: 0), Application::ATM::Domain::CashNote.new(id: 8, value: 100, quantity: 2)]

cash_machine.add_notes(cash_notes2)


# sacar do caixa

require_relative "./domain/cash_note.rb"
require_relative "./domain/cash_machine.rb"

cash_notes = [Application::ATM::Domain::CashNote.new(id: 1, value: 10, quantity: 2), Application::ATM::Domain::CashNote.new(id: 2, value: 20, quantity: 4),
  Application::ATM::Domain::CashNote.new(id: 3, value: 50, quantity: 5), Application::ATM::Domain::CashNote.new(id: 4, value: 100, quantity: 1)]

cash_machine = Application::ATM::Domain::CashMachine.new(id: 1)
cash_machine.total_value
cash_machine.notes_quantity

cash_machine.add_notes(new_cash_notes: cash_notes)
cash_machine.total_value
cash_machine.notes_quantity

withdraw_hash = {
  "saque" => {
    "valor" => 80,
    "horario" => "2019-02-13T11:01:01.000Z"
  }
}

cash_machine.withdraw(withdraw_hash: withdraw_hash)
cash_machine.total_value
cash_machine.notes_quantity

withdraw_hash = {
  "saque" => {
    "valor" => 290,
    "horario" => "2019-02-13T11:01:01.000Z"
  }
}

cash_machine.withdraw(withdraw_hash: withdraw_hash)
cash_machine.total_value
cash_machine.notes_quantity
