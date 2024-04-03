require "./config/application.rb"

module Application
  module ATM
    module UseCase
      class AtmSupply

        def initialize(cash_machine:, new_cash_notes:)
          @cash_machine = cash_machine
          @new_cash_notes = []
        end

        def self.build(cash_machine:, new_cash_notes: [])
          new(
            cash_machine: cash_machine,
            new_cash_notes: new_cash_notes
          )
        end

        def execute
          begin
            @cash_machine.add_notes(new_cash_notes: new_cash_notes)
          rescue Application::ATM::Exceptions::AddEmptyNotesinAtmException => e
            return { erros: [e.message] }
          rescue StandardError => e
            return { erros: ["erro-#{e.message}"]}
          end
        end

        private

        def render_response_json

        end

      end
    end
  end
end
