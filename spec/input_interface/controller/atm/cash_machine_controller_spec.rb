
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
          expect(controller.cash_machine.total_value).to eq(5800)
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
          expect(controller.cash_machine.total_value).to eq(5870)
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
          result = controller.supply(request)

          expect(result).to eq(expected_result)
        end
      end

    end
  end

  describe ".withdrawal" do

  end

  private

  def read_json_file(file_name)
    file_path = File.join(Dir.pwd, 'spec', 'input_interface', 'controller', 'atm', 'request_files', file_name)
    File.read(file_path)
  end

end
