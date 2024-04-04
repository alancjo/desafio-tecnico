
RSpec.describe Application::ATM::UseCase::AtmWithdrawal do

  let(:cash_note_class) { Application::ATM::Domain::CashNote }
  let(:cash_machine_class) { Application::ATM::Domain::CashMachine }

  describe ".execute" do
    let(:cash_notes) do
      [
        cash_note_class.new(value: 10, quantity: 2),
        cash_note_class.new(value: 20, quantity: 4),
        cash_note_class.new(value: 50, quantity: 5),
        cash_note_class.new(value: 100, quantity: 1)
      ]
    end
    let(:cash_machine) { cash_machine_class.new(available: true) }
    subject(:use_case) { described_class.build(cash_machine: cash_machine) }

    context "when the withdrawal operation fails" do

      context "when atm non-existent" do
        let(:withdraw_hash) do
          {
            "saque" => {
              "valor" => 100,
              "horario" => "2019-02-13T11:01:01.000Z"
            }
          }
        end
        let(:expected_result) do
          {
            "caixa" => {},
            "erros" => ["caixa-inexistente"]
          }
        end

        it "returns non-existent atm message error" do
          result = use_case.execute(withdrawal: withdraw_hash)

          expect(result).to eq(expected_result)
        end
      end

      context "when the atm unavailable for withdrawal" do
        before do
          cash_machine.add_notes(new_cash_notes: cash_notes)
          cash_machine.update_availability(false)
        end

        let(:withdraw_hash) do
          {
            "saque" => {
              "valor" => 100,
              "horario" => "2019-02-13T11:01:01.000Z"
            }
          }
        end
        let(:expected_fail_result) do
          {
            "caixa" => {
              "caixaDisponivel" => false,
              "notas" => {
                "notasDez" => 2,
                "notasVinte" => 4,
                "notasCinquenta" => 5,
                "notasCem" => 1
              }
            },
            "erros" => ["caixa-indisponível"]
          }
        end

        it "returns an unavailable for withdrawal message" do
          result = use_case.execute(withdrawal: withdraw_hash)

          expect(result).to eq(expected_fail_result)
        end
      end

      context "when the value to withdraw than more atm value[R$ 450.00]" do
        before do
          cash_machine.add_notes(new_cash_notes: cash_notes)
        end

        let(:withdraw_hash) do
          {
            "saque" => {
              "valor" => 500,
              "horario" => "2019-02-13T11:01:01.000Z"
            }
          }
        end
        let(:expected_fail_result) do
          {
            "caixa" => {
              "caixaDisponivel" => true,
              "notas" => {
                "notasDez" => 2,
                "notasVinte" => 4,
                "notasCinquenta" => 5,
                "notasCem" => 1
              }
            },
            "erros" => ["valor-indisponível"]
          }
        end

        it "returns an amount unavailable atm message" do
          result = use_case.execute(withdrawal: withdraw_hash)

          expect(result).to eq(expected_fail_result)
        end
      end

      context "when the same amount tries to be withdrawn in an interval of less than 10 minutes" do
        before do
          cash_machine.add_notes(new_cash_notes: cash_notes)
          use_case.execute(withdrawal: { "saque" => { "valor" => 50, "horario" => "2019-02-13T11:10:00.000Z" } })
          use_case.execute(withdrawal: { "saque" => { "valor" => 70, "horario" => "2019-02-13T11:11:00.000Z" } })
        end

        let(:withdraw_hash) do
          {
            "saque" => {
              "valor" => 70,
              "horario" => "2019-02-13T11:15:00.000Z"
            }
          }
        end
        let(:expected_fail_result) do
          {
            "caixa" => {
              "caixaDisponivel" => true,
              "notas" => {
                "notasDez" => 2,
                "notasVinte" => 3,
                "notasCinquenta" => 3,
                "notasCem" => 1
              }
            },
            "erros" => ["saque-duplicado"],
            "ultimos_saques" => [
              { "valor" => 50, "horario" => "2019-02-13T11:10:00.000Z" },
              { "valor" => 70, "horario" => "2019-02-13T11:11:00.000Z" }
            ]
          }
        end

        it "returns a double withdrawal message" do
          result = use_case.execute(withdrawal: withdraw_hash)

          expect(result).to eq(expected_fail_result)
        end

      end

      context "when the withdrawal operation was successful" do
        before do
          cash_machine.add_notes(new_cash_notes: cash_notes)
        end

        let(:withdraw_hash) do
          {
            "saque" => {
              "valor" => 80,
              "horario" => "2024-02-13T11:01:01.000Z"
            }
          }
        end
        let(:atm_result_expected) do
          {
            "caixa" => {
              "caixaDisponivel" => true,
              "notas" => {
                "notasDez" => 1,
                "notasVinte" => 3,
                "notasCinquenta" => 4,
                "notasCem" => 1
              }
            },
            "erros" => []
          }
        end

        it "returns atm withdrawal success message" do
          result = use_case.execute(withdrawal: withdraw_hash)

          expect(result).to eq(atm_result_expected)
        end

      end

    end
  end
end
