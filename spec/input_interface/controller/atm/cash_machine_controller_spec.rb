
RSpec.describe InputInterface::Controller::Atm::CashMachineController do

  describe ".supply" do
    let(:request) { read_json_file("supply.json") }

    context "when the supply operation is success" do
      subject(:controller) { described_class.build(first_supply_request: request) }

      context "when supplies the cash machine for the first time" do
        let(:expected_result) do
          {
            "caixa" => {
              "caixaDisponivel" => false,
              "notas" => {
                "notasDez" => 100,
                "notasVinte" => 50,
                "notasCinquenta" => 10,
                "notasCem" => 30
              }
            },
            "erros" => []
          }
        end

        it "builds cash machine with available" do
          expect(controller.cash_machine).to be
          expect(controller.virtual_cash_machine).to be_nil
        end

        it "fills the cash machine" do
          response = controller.supply(request)

          expect(response).to eq(expected_result)
          expect(controller.cash_machine.total_value).to eq(5500)
        end
      end

      context "when supplies the cash machine for the second time" do
        before do
          controller.supply(request)
        end

        let(:request2) { read_json_file("supply2.json") }
        let(:expected_result) do
          {
            "caixa" => {
              "caixaDisponivel" => false,
              "notas" => {
                "notasDez" => 1,
                "notasVinte" => 2,
                "notasCinquenta" => 1,
                "notasCem" => 2
              }
            },
            "erros" => []
          }
        end

        it "builds cash machine with available" do
          expect(controller.cash_machine).to be
          expect(controller.virtual_cash_machine).to be_nil
        end

        it "fills the cash machine second time" do
          response = controller.supply(request2)

          expect(response).to eq(expected_result)
          expect(controller.cash_machine.total_value).to eq(5800)
        end
      end
    end

    context "when the supply operation fails" do
      let(:request) { read_json_file("supply_with_available_atm.json") }
      subject(:controller) { described_class.build(first_supply_request: request) }

      context "when try atm supply second time being available with withdrawal" do
        before do
          controller.supply(request)
        end

        let(:expected_result) do
          {
            "caixa" => {
              "caixaDisponivel" => true,
              "notas" => {
                "notasDez" => 1,
                "notasVinte" => 2,
                "notasCinquenta" => 1,
                "notasCem" => 2
              },
            },
            "erros" => ["caixa-em-uso"]
          }
        end

        it "operations fails with error message[caixa-em-uso]" do
          response = controller.supply(request)

          expect(response).to eq(expected_result)
        end
      end

    end
  end

  describe ".withdrawal" do
    let(:withdrawal_request) { read_json_file("withdrawal.json") }

    context "when the withdrawal operation fails" do
      subject(:controller) { described_class.build }

      context "when atm non-existent" do
        let(:expected_response) do
          {
            "caixa" => {},
            "erros" => ["caixa-inexistente"]
          }
        end

        it "returns non-existent atm message error" do
          response = controller.withdrawal(withdrawal_request)

          expect(response).to eq(expected_response)
        end
      end

      context "when the atm unavailable for withdrawal"  do
        let(:supply_request) { read_json_file("supply.json") }
        subject(:controller) { described_class.build(first_supply_request: supply_request) }

        before do
          controller.supply(supply_request)
        end

        let(:expected_response) do
          {
            "caixa" => {
              "caixaDisponivel" => false,
              "notas" => {
                "notasDez" => 100,
                "notasVinte" => 50,
                "notasCinquenta" => 10,
                "notasCem" => 30
              }
            },
            "erros" => ["caixa-indisponível"]
          }
        end

        it "returns an unavailable for withdrawal message" do
          response = controller.withdrawal(withdrawal_request)

          expect(response).to eq(expected_response)
        end

      end

      context "when the value to withdraw than more atm value[R$ 300.00]" do
        subject(:controller) { described_class.build(first_supply_request: supply_request) }
        let(:supply_request) { read_json_file("supply_with_available_atm.json") }
        let(:withdrawal_request) { read_json_file("withdrawal_exceeds_atm_value.json") }

        before do
          controller.supply(supply_request)
        end

        let(:expected_response) do
          {
            "caixa" => {
              "caixaDisponivel" => true,
              "notas" => {
                "notasDez" => 1,
                "notasVinte" => 2,
                "notasCinquenta" => 1,
                "notasCem" => 2
              }
            },
            "erros" => ["valor-indisponível"]
          }
        end

        it "returns an amount unavailable atm message" do
          response = controller.withdrawal(withdrawal_request)

          expect(response).to eq(expected_response)
        end
      end

      context "when the same amount tries to be withdrawn in an interval of less than 10 minutes" do
        subject(:controller) { described_class.build(first_supply_request: supply_request) }
        let(:supply_request) { read_json_file("supply_with_available_atm.json") }
        let(:withdrawal_request) { read_json_file("withdrawal.json") }

        before do
          controller.supply(supply_request)
          controller.withdrawal(withdrawal_request)
        end

        let(:expected_response) do
          {
            "caixa" => {
              "caixaDisponivel" => true,
              "notas" => {
                "notasDez" => 1,
                "notasVinte" => 2,
                "notasCinquenta" => 1,
                "notasCem" => 1
              }
            },
            "erros" => ["saque-duplicado"],
            "ultimos_saques" => [
              { "horario" => "2019-02-13T11:01:01.000Z", "valor"=> 100 }
            ]
          }
        end

        it "returns an amount unavailable atm message" do
          response = controller.withdrawal(withdrawal_request)

          expect(response).to eq(expected_response)
        end
      end
    end

    context "when the withdrawal operation was successful" do
      subject(:controller) { described_class.build(first_supply_request: supply_request) }
      let(:supply_request) { read_json_file("supply_with_available_atm.json") }
      let(:withdrawal_request) { read_json_file("withdrawal.json") }

      before do
        controller.supply(supply_request)
      end

      let(:expected_response) do
        {
          "caixa" => {
            "caixaDisponivel" => true,
            "notas" => {
              "notasDez" => 1,
              "notasVinte" => 2,
              "notasCinquenta" => 1,
              "notasCem" => 1
            }
          },
          "erros" => []
        }
      end

      it "returns atm withdrawal success message" do
        response = controller.withdrawal(withdrawal_request)

        expect(response).to eq(expected_response)
      end
    end

  end

  private

  def read_json_file(file_name)
    file_path = File.join(Dir.pwd, 'spec', 'input_interface', 'controller', 'atm', 'request_files', file_name)
    File.read(file_path)
  end

end
