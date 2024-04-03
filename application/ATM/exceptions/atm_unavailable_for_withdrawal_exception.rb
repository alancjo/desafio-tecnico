module Application
  module ATM
    module Exceptions
      class AtmUnavailableForWithdrawalException < StandardError

        def initialize(message = nil)
          message ||= "caixa-indisponível"
          super(message)
        end

      end
    end
  end
end
