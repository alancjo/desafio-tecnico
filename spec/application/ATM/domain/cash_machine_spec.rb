require "./config/application.rb"

RSpec.describe Application::ATM::Domain::CashMachine do

  let(:cash_note_class) { Application::ATM::Domain::CashNote }

  describe ".add_notes" do
    subject(:atm) { described_class.new(id: 1) }
    let(:cash_notes) do
      [
        cash_note_class.new(value: 10, quantity: 3),
        cash_note_class.new(value: 20, quantity: 0),
        cash_note_class.new(value: 50, quantity: 1),
        cash_note_class.new(value: 100, quantity: 0)
      ]
    end

    context "when the cash machine refill operation fails" do

      context "when try to refill without getting a note" do
        let(:expected_error_message) { "Não é possível abastecer o caixa eletrônico sem notas" }

        it {
          expect {
            atm.add_notes
          }.to raise_error(Application::ATM::Exceptions::AddEmptyNotesinAtmException, expected_error_message)
        }
      end

      context "when the cash machine is available for withdrawal and there is a second refill" do
        let(:fail_add_note_result) do
          {
            "caixa" => {
              "caixaDisponivel" => true,
              "notas" => {
                "notasDez" => 3,
                "notasVinte" => 0,
                "notasCinquenta" => 1,
                "notasCem" => 0
              }
            },
            "erros" => ["caixa-em-uso"]
          }
        end

        before do
          atm.update_availability(true)
          atm.add_notes(new_cash_notes: cash_notes)
        end

        it "returns a hash with refill operation[caixa-em-uso] error" do
          result = atm.add_notes(new_cash_notes: cash_notes)

          expect(result).to be_instance_of(Hash)
          expect(result).to eq(fail_add_note_result)
        end

      end

    end

    context "when the cash machine refill operation success" do
      let(:success_result) do
        {
          "caixa" => {
            "caixaDisponivel" => false,
            "notas" => {
              "notasDez" => 3,
              "notasVinte" => 0,
              "notasCinquenta" => 1,
              "notasCem" => 0
            }
          },
          "erros" => []
        }
      end

      context "when refill operation occurs the first time" do
        it "returns a success hash with new cash notes" do
          result = atm.add_notes(new_cash_notes: cash_notes)

          expect(result).to eq(success_result)
        end

        it "checks atm notes quantity without refill operation" do
          notes_quantity_expected = { 10 => 0, 20  => 0, 50 => 0, 100 => 0 }

          expect(atm.notes_quantity).to eq(notes_quantity_expected)
          expect(atm.total_value).to be_zero
        end

        it "checks atm notes after first refill operation" do
          notes_quantity_expected = { 10 => 3, 20  => 0, 50 => 1, 100 => 0 }

          atm.add_notes(new_cash_notes: cash_notes)

          expect(atm.notes_quantity).to eq(notes_quantity_expected)
          expect(atm.total_value).to eq(80)
        end

      end

      context "when refill operation occurs the second time with atm withdrawal unavailable" do
        before do
          atm.update_availability(false)
          atm.add_notes(new_cash_notes: cash_notes)
        end

        it "returns a success_hash with new cash notes" do
          result = atm.add_notes(new_cash_notes: cash_notes)

          expect(result).to eq(success_result)
        end

        it "adds new cash notes in atm with notes" do
          new_notes_quantity_expected = { 10 => 6, 20  => 0, 50 => 2, 100 => 0 }

          atm.add_notes(new_cash_notes: cash_notes)

          expect(atm.notes_quantity).to eq(new_notes_quantity_expected)
          expect(atm.total_value).to eq(160)
        end

        it "adds new cash notes twice after first refill operation" do
          new_notes_quantity_expected = { 10 => 9, 20  => 0, 50 => 3, 100 => 0 }

          atm.add_notes(new_cash_notes: cash_notes)
          atm.add_notes(new_cash_notes: cash_notes)

          expect(atm.notes_quantity).to eq(new_notes_quantity_expected)
          expect(atm.total_value).to eq(240)
        end

      end
    end
  end

  describe ".withdraw" do

  end

end
