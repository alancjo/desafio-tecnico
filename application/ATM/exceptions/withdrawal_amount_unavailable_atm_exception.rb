module Application
  module ATM
    module Exceptions
      class WithdrawalAmountUnavailableAtmException < StandardError

        def initialize(message = nil)
          message ||= "valor-indisponivel"
          super(message)
        end

      end
    end
  end
end
