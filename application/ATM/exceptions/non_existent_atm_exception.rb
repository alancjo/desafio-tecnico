module Application
  module ATM
    module Exceptions
      class NonExistentAtmException < StandardError

        def initialize(message = nil)
          message ||= "caixa-inexistente"
          super(message)
        end

      end
    end
  end
end
