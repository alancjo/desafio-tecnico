module Application
  module ATM
    module Adapter
      class CashMachineAdapter

        def initialize(cash_machine_domain:)
          @cash_machine_domain = cash_machine_domain
        end

        def self.build
          new(
            cash_machine_domain: Application::ATM::Domain::CashMachine
          )
        end

        def translate!(input_supply_json)
          cash_machine = input_supply_json.dig("caixa")
          cash_machine.delete("notas")

          @cash_machine_domain.new(available: cash_machine["caixaDisponivel"])
        end

        def self.virtual_cash_machine
          Application::ATM::Domain::CashMachine.new
        end

      end
    end
  end
end
