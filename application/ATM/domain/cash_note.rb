module Application
  module ATM
    module Domain
      class CashNote

        attr_reader :id, :value, :quantity

        def initialize(id: nil, value:, quantity: 0)
          @id = id
          @value = value
          @quantity = quantity
        end

        def name
          {
            10  => "notasDez",
            20  => "notasVinte",
            50  => "NotasCinquenta",
            100 => "notasCem"
          }[value]
        end

        def increase_quantity(quantity)
          @quantity += quantity
        end

        def virtual_note?
          @id.nil?
        end

        def to_hash
          {
            id: @id,
            value: @value,
            quantity: @quantity,
          }
        end

      end
    end
  end
end
