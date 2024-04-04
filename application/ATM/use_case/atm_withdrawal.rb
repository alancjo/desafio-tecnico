module Application
  module ATM
    module UseCase
      class AtmWithdrawal

        def initialize(cash_machine:)
          @cash_machine = cash_machine
        end

        def self.build(cash_machine:)
          new(
            cash_machine: cash_machine
          )
        end

        def execute(withdrawal:)
          begin
            @cash_machine.withdraw(withdraw_hash: withdrawal)
          rescue Application::ATM::Exceptions::NonExistentAtmException => e
            return { "caixa" => {}, "erros" => [e.message] }
          rescue Application::ATM::Exceptions::AtmUnavailableForWithdrawalException => e
            return @cash_machine.render_error_json(e.message)
          rescue Application::ATM::Exceptions::WithdrawalAmountUnavailableAtmException => e
            return @cash_machine.render_error_json(e.message)
          rescue Application::ATM::Exceptions::DoubleWithdrawalException => e
            return @cash_machine.render_error_json(e.message).merge({ "ultimos_saques" => @cash_machine.withdrawal_record })
          rescue => e
            return { "erros" => [e.message] }
          end
        end

      end
    end
  end
end
