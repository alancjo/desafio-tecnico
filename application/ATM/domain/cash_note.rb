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
            50  => "notasCinquenta",
            100 => "notasCem"
          }[value]
        end

        def increase_quantity(quantity)
          @quantity += quantity
        end

        def withdraw(value_to_withdraw)
          withdraw_quantity = value_to_withdraw / @value

          return value_to_withdraw if (@quantity <= 0 || withdraw_quantity < 1)

          quantity_to_remove = @quantity < withdraw_quantity ? @quantity : withdraw_quantity

          @quantity -= quantity_to_remove

          value_to_withdraw - (@value * quantity_to_remove)
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
