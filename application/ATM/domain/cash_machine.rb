module Application
  module ATM
    class CashMachine

      attr_reader :available, :cash_notes

      def initialize(id:, available: false, cash_notes: [])
        @id = id
        @available = available
        @cash_notes = cash_notes
      end

      # 1 - abastecimento do caixa eletrônico
      def add_cash_notes(new_cash_notes)
        raise StandardError.new("Para abastecer o caixa é necessário adicionar nota") if new_cash_notes.blank?

        if @cash_notes.blank?
          @cash_notes = new_cash_notes
          return @cash_notes
        end

        @new_cash_notes.each
      end

      def withdraw(remove_cash_notes)

      end

      def total_value

      end

      def notes_quanity
        quantity = {
          10  => 0,
          20  => 0,
          50  => 0,
          100 => 0
        }

        return quantity if @cash_notes.blank?

        @cash_notes.each do |note|
          quantity[note.value] += note.quantity
        end

        quantity
      end

      private

      def update_cash_note()

      end

    end
  end
end