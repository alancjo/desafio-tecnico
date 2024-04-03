require "./config/application.rb"

RSpec.describe Application::ATM::Domain::CashMachine do

  let(:cash_note_class) { Application::ATM::Domain::CashNote }

  describe ".add_notes" do
    subject(:atm) { described_class.new }
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
    let(:cash_notes) do
      [
        cash_note_class.new(value: 10, quantity: 2),
        cash_note_class.new(value: 20, quantity: 4),
        cash_note_class.new(value: 50, quantity: 5),
        cash_note_class.new(value: 100, quantity: 1)
      ]
    end
    subject(:atm) { described_class.new(cash_notes: cash_notes, available: true) }

    context "when the withdrawal operation fails" do

      context "when atm non-existent" do
        subject(:atm) { described_class.new(available: true) }
        let(:withdraw_hash) do
          {
            "saque" => {
              "valor" => 100,
              "horario" => "2019-02-13T11:01:01.000Z"
            }
          }
        end

        it "raises a non-existent exception" do
          expect {
            atm.withdraw(withdraw_hash: withdraw_hash)
          }.to raise_error(Application::ATM::Exceptions::NonExistentAtmException, "caixa-inexistente")
        end
      end

      context "when the atm unavailable for withdrawal" do
        before do
          atm.update_availability(false)
        end

        let(:withdraw_hash) do
          {
            "saque" => {
              "valor" => 100,
              "horario" => "2019-02-13T11:01:01.000Z"
            }
          }
        end

        it "raises an unavailable for withdrawal exception" do
          expect {
            atm.withdraw(withdraw_hash: withdraw_hash)
          }.to raise_error(Application::ATM::Exceptions::AtmUnavailableForWithdrawalException, "caixa-indisponível")
        end
      end

      context "when the value to withdraw than more atm value[R$ 450.00]" do
        let(:withdraw_hash) do
          {
            "saque" => {
              "valor" => 500,
              "horario" => "2019-02-13T11:01:01.000Z"
            }
          }
        end

        it "raises an amount unavailable atm exception" do
          expect {
            atm.withdraw(withdraw_hash: withdraw_hash)
          }.to raise_error(Application::ATM::Exceptions::WithdrawalAmountUnavailableAtmException, "valor-indisponivel")
        end
      end

      context "when the same amount tries to be withdrawn in an interval of less than 10 minutes" do
        before do
          atm.withdraw(withdraw_hash: { "saque" => { "valor" => 50, "horario" => "2019-02-13T11:10:00.000Z" } })
          atm.withdraw(withdraw_hash: { "saque" => { "valor" => 10, "horario" => "2019-02-13T11:10:40.000Z" } })
          atm.withdraw(withdraw_hash: { "saque" => { "valor" => 70, "horario" => "2019-02-13T11:11:00.000Z" } })
          atm.withdraw(withdraw_hash: { "saque" => { "valor" => 100, "horario" => "2019-02-13T11:12:00.000Z" } })
          atm.withdraw(withdraw_hash: { "saque" => { "valor" => 120, "horario" => "2019-02-13T11:13:00.000Z" } })
        end

        let(:withdraw_hash) do
          {
            "saque" => {
              "valor" => 70,
              "horario" => "2019-02-13T11:15:00.000Z"
            }
          }
        end

        it "raises a double withdrawal exception" do
          expect {
            atm.withdraw(withdraw_hash: withdraw_hash)
          }.to raise_error(Application::ATM::Exceptions::DoubleWithdrawalException, "saque-duplicado")
        end
      end

    end

    context "when the withdrawal operation was successful" do
      let(:withdraw_hash) do
        {
          "saque" => {
            "valor" => 80,
            "horario" => "2024-02-13T11:01:01.000Z"
          }
        }
      end

      context "when the first withdrawal is made" do
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

        it "returns atm without the notes that were taken when withdrawing" do
          atm_result = atm.withdraw(withdraw_hash: withdraw_hash)

          expect(atm_result).to eq(atm_result_expected)
        end
      end

      context "when there are two withdrawals" do
        before do
          atm.withdraw(withdraw_hash: withdraw_hash)
        end

        let(:withdraw_hash2) do
          {
            "saque" => {
              "valor" => 290,
              "horario" => "2024-02-13T13:00:00.000Z"
            }
          }
        end
        let(:atm_result_expected) do
          {
            "caixa" => {
              "caixaDisponivel" => true,
              "notas" => {
                "notasDez" => 1,
                "notasVinte" => 1,
                "notasCinquenta" => 1,
                "notasCem" => 0
              }
            },
            "erros" => []
          }
        end

        it "returns the ATM without the notes that were made on withdrawal 1 and withdrawal 2" do
          atm_result = atm.withdraw(withdraw_hash: withdraw_hash2)

          expect(atm_result).to eq(atm_result_expected)
        end
      end

    end

  end

  describe ".total_value" do

    context "when the atm not refill" do
      subject(:atm) { described_class.new(cash_notes: []) }

      it "returns total value 0" do
        expect(atm.total_value).to be_zero
      end
    end

    context "when the atm has notes" do
      let(:cash_notes) do
        [
          cash_note_class.new(value: 10, quantity: 3),
          cash_note_class.new(value: 20, quantity: 1),
          cash_note_class.new(value: 50, quantity: 2),
          cash_note_class.new(value: 100, quantity: 3)
        ]
      end
      subject(:atm) { described_class.new(cash_notes: cash_notes) }

      it "returns sum of all cash notes in atm" do
        total_value_expected = 450

        expect(atm.total_value).to eq(450)
      end
    end

  end

  describe ".notes_quantity" do

    context "when the atm is empty" do
      subject(:atm) { described_class.new(cash_notes: []) }

      it "returns zero for each note quantity" do
        notes_quantity_expected = { 10 => 0, 20  => 0, 50 => 0, 100 => 0 }

        expect(atm.notes_quantity).to eq(notes_quantity_expected)
      end
    end

    context "when the atm has notes" do
      let(:cash_notes) do
        [
          cash_note_class.new(value: 10, quantity: 3),
          cash_note_class.new(value: 20, quantity: 1),
          cash_note_class.new(value: 50, quantity: 2),
          cash_note_class.new(value: 100, quantity: 3)
        ]
      end
      subject(:atm) { described_class.new(cash_notes: cash_notes) }

      context "when atm already note" do
        let(:notes_quantity_expected) { { 10 => 3, 20 => 1, 50 => 2, 100 => 3 } }

        it "returns quantity from each note" do
          expect(atm.notes_quantity).to eq(notes_quantity_expected)
        end
      end

      context "when atm already note and then there's a refill" do
        before do
          atm.add_notes(new_cash_notes: cash_notes)
        end

        let(:notes_quantity_expected) { { 10 => 6, 20 => 2, 50 => 4, 100 => 6 } }

        it "returns quantity from each note" do
          expect(atm.notes_quantity).to eq(notes_quantity_expected)
        end
      end
    end

  end

  describe ".update_availability" do
    subject(:atm) { described_class.new }

    context "when the atm is made available for use[withdrawal]" do
      before do
        atm.update_availability(true)
      end

      it {
        expect(atm.available).to be_truthy
      }
    end

    context "when the atm is made unavailable for use[withdrawal]" do
      before do
        atm.update_availability(false)
      end

      it {
        expect(atm.available).to be_falsey
      }
    end
  end

end
