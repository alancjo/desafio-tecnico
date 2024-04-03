module Application
  module ATM
    module Adapter
      class CashNoteAdapter

        def initialize(cash_note_domain:)
          @cash_note_domain = cash_note_domain
        end

        def self.build
          new(
            cash_note_domain: Application::ATM::Domain::CashNote
          )
        end

        def translate(note:, quantity:)
          value = note_value(note)

          @cash_note_domain.new(value: value, quantity: quantity)
        end

        def translate_collection(input_cash_notes)
          cash_notes = input_cash_notes.dig(:caixa, :notas)

          [].tap do |new_cash_notes|
            cash_notes.each do |note, quantity|
              new_cash_notes << translate(note: note, quantity: quantity)
            end
          end

        end

        private

        def note_value(value)
          {
            notasDez: 10,
            notasVinte: 20,
            notasCinquenta: 50 ,
            notasCem: 100,
          }[value.to_sym]
        end

      end
    end
  end
end
