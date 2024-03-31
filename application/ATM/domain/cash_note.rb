module Application
  module ATM
    class CashNote

      attr_reader :id, :value, :quantity

      def initialize(id:, value:, quantity:)
        @id = id
        @value = value
        @quantity
      end



    end
  end
end