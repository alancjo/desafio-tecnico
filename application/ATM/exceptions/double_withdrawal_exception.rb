module Application
  module ATM
    module Exceptions
      class DoubleWithdrawalException < StandardError

        def initialize(message = nil)
          message ||= "saque-duplicado"
          super(message)
        end

      end
    end
  end
end
