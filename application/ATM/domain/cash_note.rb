module Application
  module ATM
    class CashNote

      attr_reader :id, :value, :quantity

      def initialize(id:, value:, quantity:)
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

      def to_hash
        {
          value: @value,
          quantity: @quantity,
        }
      end

    end
  end
end