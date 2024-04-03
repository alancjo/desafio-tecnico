module InputInterface
  module Controller
    module Atm
      class CashMachineController

        attr_reader :cash_machine, :virtual_cash_machine

        def self.build(first_supply_request: false)
          if first_supply_request
            return new(
              cash_machine: translate_cash_machine(JSON.parse(first_supply_request))
            )
          end

          new(virtual_cash_machine: Application::ATM::Adapter::CashMachineAdapter.virtual_cash_machine)
        end

        def initialize(cash_machine: nil, virtual_cash_machine: nil)
          @cash_machine = cash_machine
          @virtual_cash_machine = virtual_cash_machine
        end

        def supply(request)
          uc = Application::ATM::UseCase::AtmSupply.build(cash_machine: @cash_machine)

          converted_request = JSON.parse(request)
          new_available_atm = converted_request.dig("caixa", "caixaDisponivel")

          cash_notes = translate_cash_notes(converted_request)

          uc.execute(new_cash_notes: cash_notes, available: new_available_atm)
        end

        def withdrawal(request)
          cash_machine = @cash_machine || @virtual_cash_machine

          uc = Application::ATM::UseCase::AtmWithdrawal.build(cash_machine: cash_machine)
          uc.execute(withdrawal: JSON.parse(request))
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

      end
    end
  end
end
