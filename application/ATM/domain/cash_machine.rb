module Application
  module ATM
    class CashMachine

      attr_reader :available, :cash_notes

      def initialize(id:, available: false, cash_notes: [])
        @id = id
        @available = available
        @cash_notes = cash_notes
      end

      def add_notes(new_cash_notes)
        raise StandardError.new("Para abastecer o caixa é necessário adicionar nota") if new_cash_notes.empty?

        if @cash_notes.empty?
          @cash_notes = new_cash_notes

          return render_response_json(cash_notes: new_cash_notes)
        end

        return render_response_json(cash_notes: new_cash_notes, errors: ["caixa-em-uso"]) if @available

        @cash_notes.sort_by!(&:value); new_cash_notes.sort_by!(&:value)

        new_cash_notes.each_with_index { |new_note, index| @cash_notes[index].increase_quantity(new_note.quantity) }

        render_response_json(cash_notes: new_cash_notes)
      end

      def withdraw(remove_cash_notes)
        # to-do
      end

      def total_value
        @cash_notes.map do |note|
          note.value * note.quantity
        end.reduce(:+)
      end

      def notes_quantity
        quantity = {
          10  => 0,
          20  => 0,
          50  => 0,
          100 => 0
        }

        return quantity if @cash_notes.empty?

        @cash_notes.each do |note|
          quantity[note.value] += note.quantity
        end

        quantity
      end

      def update_availability(availability)
        @available = availability
      end

      private

      def update_cash_note()
        # to-do
      end

      def build_hash_from_all_notes(cash_notes)
        notes_result = cash_notes.map { |note| { "#{note.name}" => note.quantity } }

        notes_result.reduce({}, :merge)
      end

      def render_response_json(cash_notes:, errors: [])
        {
          "caixa" => {
            "caixaDisponivel" => @available,
            "notas" => build_hash_from_all_notes(cash_notes)
          },
          "erros" => errors
        }
      end

    end
  end
end
