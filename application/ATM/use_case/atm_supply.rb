require "./config/application.rb"

module Application
  module ATM
    module UseCase
      class AtmSupply

        def initialize(cash_machine:)
          @cash_machine = cash_machine
        end

        def self.build(cash_machine:)
          new(
            cash_machine: cash_machine
          )
        end

        def execute(new_cash_notes:, available:)
          begin
            result = @cash_machine.add_notes(new_cash_notes: new_cash_notes)
            @cash_machine.update_availability(available)

            result
          rescue Application::ATM::Exceptions::AddEmptyNotesinAtmException => e
            @cash_machine.update_availability(available)
            return { erros: [e.message] }

          rescue => e
            @cash_machine.update_availability(available)
            return { erros: ["erro-#{e.message}"]}
          end
        end

        private

        def render_response_json
          # to-do
        end

      end
    end
  end
end
