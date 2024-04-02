module Application
  module ATM
    module Exceptions
      class AddEmptyNotesinAtmException < StandardError

        def initialize(message = nil)
          message ||= "Não é possível abastecer o caixa eletrônico sem notas"
          super(message)
        end

      end
    end
  end
end
