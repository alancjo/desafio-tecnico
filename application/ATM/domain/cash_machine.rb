module Application
  module ATM
    module Domain
      class CashMachine

        attr_reader :available, :cash_notes

        def initialize(id:, available: false, cash_notes: [])
          @id = id
          @available = available
          @cash_notes = cash_notes
        end

        def add_notes(new_cash_notes: [])
          raise_add_empty_notes_exception() if new_cash_notes.empty?

          if @cash_notes.empty?
            @cash_notes = new_cash_notes.map(&:clone)

            return render_response_json(cash_notes: new_cash_notes)
          end

          return render_response_json(cash_notes: new_cash_notes, errors: ["caixa-em-uso"]) if @available

          @cash_notes.sort_by!(&:value); new_cash_notes.sort_by!(&:value)

          new_cash_notes.each_with_index { |new_note, index| @cash_notes[index].increase_quantity(new_note.quantity) }

          render_response_json(cash_notes: new_cash_notes)
        end

        def withdraw(withdraw_hash: {})
          value_to_withdraw = withdraw_hash.dig("saque", "valor").to_i
          withdraw_datetime = withdraw_hash.dig("saque", "horario")

          # 3 - Valor indisponível
          raise StandardError.new("Valor indisponível") if value_to_withdraw > total_value()

          reverse_notes_by_value = @cash_notes.sort_by { |cash_note| -cash_note.value }

          # 1 - Saque com sucesso
          reverse_notes_by_value.each do |cash_note|
            break if value_to_withdraw.zero?

            value_to_withdraw = cash_note.withdraw(value_to_withdraw)
          end

          render_response_json(cash_notes: @cash_notes)
        end

        def total_value
          return 0 if cash_notes.empty?

          @cash_notes.map do |note|
            note.value * note.quantity
          end.reduce(:+)
        end

        def notes_quantity
          notes_quantity = {
            10  => 0,
            20  => 0,
            50  => 0,
            100 => 0
          }

          return notes_quantity if @cash_notes.empty?

          @cash_notes.each { |note| notes_quantity[note.value] += note.quantity }

          notes_quantity
        end

        def update_availability(availability)
          @available = availability
        end

        private

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

        def render_withdraw_response_json(value)

        end

        def raise_add_empty_notes_exception
          raise Application::ATM::Exceptions::AddEmptyNotesinAtmException
        end

      end
    end
  end
end
