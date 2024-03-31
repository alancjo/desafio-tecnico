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

        # na primeiro abastecimento não verificar disponibilidade, pois o caixa ainda não foi disponibilizado
        # aqui já é a segunda vez, pois na linha 17 já foi adicionado as notas ao caixa uma primeira vez
        # preciso achamar o update_availability antes do use case que chama este método
        raise StandardError.new("Caixa indisponível para abastecimento") if @available

        new_cash_notes.each { |new_note| @cash_notes[note.value] += new_note.value }

        # estou esperando o recrutador ver com o tech lead sobre minha dúvida
        # aqui eu preciso retornar o que recebi no abastecimento ou a quantidade de notas atual do caixa?
        {
          "caixa" => {
            "caixaDisponivel" => @available,
            "notas" => {
              build_hash_from_all_notes(new_cash_notes)
            }
          }
        }
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

      def update_availability(availability)
        @available = availability
      end

      private

      def update_cash_note()
        # to-do
      end

      def render_response_json(cash_notes)
        # to-do
      end

      def build_hash_from_all_notes(cash_notes)
        notes_result = cash_notes.map { |note| { "#{note.name}" => note.quantity } }

        notes_result.reduce({}, :merge)
      end

    end
  end
end