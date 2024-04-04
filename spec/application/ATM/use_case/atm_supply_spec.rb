
RSpec.describe Application::ATM::UseCase::AtmSupply do

  describe ".execute" do
    let(:klass_cash_note) { Application::ATM::Domain::CashNote }

    let(:note_10)    { klass_cash_note.new(value: 10, quantity: 1) }
    let(:note_20)    { klass_cash_note.new(value: 20, quantity: 1) }
    let(:note_50)    { klass_cash_note.new(value: 50, quantity: 1) }
    let(:note_100)   { klass_cash_note.new(value: 100, quantity: 3) }
    let(:cash_notes) { [note_10, note_20, note_50, note_100] }

    let(:cash_machine) { Application::ATM::Domain::CashMachine.new }
    subject(:use_case) { described_class.build(cash_machine: cash_machine) }

    context "when the atm supply is success" do
      let(:expected_result) do
        {
          "caixa" => {
            "caixaDisponivel" => false,
            "notas" => {
              "notasDez" => 1,
              "notasVinte" => 1,
              "notasCinquenta" => 1,
              "notasCem" => 3
            }
          },
          "erros" => []
        }
      end

      it "adds notes in atm" do
        result = use_case.execute(new_cash_notes: cash_notes, available: false)

        expect(result).to eq(expected_result)
        expect(cash_machine.total_value).to eq(380)
      end
    end

    context "when the atm supply fails" do
      let(:expected_result) do
        {
          erros: ["Não é possível abastecer o caixa eletrônico sem notas"]
        }
      end

      it "returns a empty notes  message" do
        result = use_case.execute(new_cash_notes: [], available: false)

        expect(result).to eq(expected_result)
        expect(cash_machine.total_value).to eq(0)
      end

      context "when try atm supply second time being available with withdrawal" do
        let(:cash_machine) { Application::ATM::Domain::CashMachine.new(available: false) }
        subject(:use_case) { described_class.build(cash_machine: cash_machine) }

        before do
          use_case.execute(new_cash_notes: cash_notes, available: true)
        end

        let(:expected_result) do
          {
            "caixa" => {
              "caixaDisponivel" => true,
              "notas" => {
                "notasDez" => 1,
                "notasVinte" => 1,
                "notasCinquenta" => 1,
                "notasCem" => 3
              }
            },
            "erros" => ["caixa-em-uso"]
          }
        end

        it "nots success operation and return atm in use" do
          result = use_case.execute(new_cash_notes: cash_notes, available: false)

          expect(result).to eq(expected_result)
          expect(cash_machine.total_value).to eq(380)
        end

      end
    end

  end
end
