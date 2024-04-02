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
                "NotasCinquenta" => 1,
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

    context "when " do

    end

  end

end
