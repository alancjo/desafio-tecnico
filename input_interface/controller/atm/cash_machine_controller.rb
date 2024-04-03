require "./config/application.rb"

module InputInterface
  module Controller
    module Atm
      class CashMachineController

        def self.build(first_request: nil)
          if first_request
            return new(
              cash_machine: translate_cash_machine(JSON.parse(first_request))
            )
          end

          new(cash_machine: nil)
        end

        def initialize(cash_machine: nil)
          @cash_machine = cash_machine
        end

        def supply(request)
          uc = Application::ATM::UseCase::AtmSupply.build(cash_machine: @cash_machine)

          converted_request = JSON.parse(request)
          new_available_atm = converted_request.dig("caixa", "caixaDisponivel")

          cash_notes = translate_cash_notes(converted_request)

          uc.execute(new_cash_notes: cash_notes, available: new_available_atm)
        end

        def withdrawal(request)
          return JSON.parse(request)
        end

        private

        def self.translate_cash_machine(request)
          adapter = Application::ATM::Adapter::CashMachineAdapter.build
          adapter.translate!(request)
        end

        def translate_cash_notes(request)
          adapter = Application::ATM::Adapter::CashNoteAdapter.build
          adapter.translate_collection!(request)
        end

        def withdrawal_use_case
          Application::ATM::UseCase::AtmSupply.build
        end

      end
    end
  end
end
