require "./config/application.rb"

module InputInterface
  module View
    module Atm
      class Home

        @@default_controller = nil
        @@already_caller_supply = false

        def self.initialize_application
          welcome_message()

          run_operation()
        end

        private

        def self.run_operation
          chosen_option = operation_options()

          while !['1', '2'].include?(chosen_option.strip)
            puts "Opção inválida! Reensira a opção corretamente"

            chosen_option = operation_options()
          end

          if chosen_option == '1'
            request_json = input_supply_json

            @@default_controller = build_controller(request_json) unless @@already_caller_supply
            @@already_caller_supply = true

            response = @@default_controller.supply(request_json)

            render(request_json, response)
          else
            controller = @@default_controller.nil? ? build_controller_without_atm : @@default_controller

            request_json = input_withdrawal_json

            response = controller.withdrawal(request_json)

            render(request_json, response)
          end

          rerun_application? ? run_operation() : farewell_message()
        end

        def self.operation_options
          puts <<-MSG

            Qual operação deseja realizar?

            Digite 1 para abastecimento
            Digite 2 para saque

          MSG

          print("Sua opção: ")

          gets.chomp
        end

        def self.welcome_message
          puts <<-MSG

            Bem-vindo ao Sistema de Caixa Eletrônico Locaweb!
                Por favor, siga as instruções na tela.
          MSG
        end

        def self.farewell_message
          puts <<-MSG

            Espero que sua experiência com nossos serviços tenhas sido incrível!
                                    Até breve! =D
          MSG
        end

        def self.input_supply_json
          puts <<-MSG
            Insira seu abastecimento em formato json inline

            Exemplo.: { "caixa":{ "caixaDisponivel":false, "notas":{ "notasDez":100, "notasVinte":50, "notasCinquenta":10, "notasCem":30 } } }

          MSG

          print("Insira aqui: ")

          gets.chomp
        end

        def self.input_withdrawal_json
          puts <<-MSG
            Insira seu saque em um json inline

            Exemplo.: { "saque":{ "valor":600, "horario":"2019-02-13T11:01:01.000Z" } }

          MSG

          print("Insira aqui: ")

          gets.chomp
        end

        def self.rerun_application?
          puts <<-MSG

            Deseja refazer outra operação?

            Digite 1 para SIM
            Aperta qualquer tecla para NÃO
          MSG

          print("Sua opção: ")

          chosen_option = gets.chomp

          return true if chosen_option.strip == "1"
          false
        end

        def self.build_controller(request)
          InputInterface::Controller::Atm::CashMachineController.build(first_supply_request: request)
        end

        def self.build_controller_without_atm
          InputInterface::Controller::Atm::CashMachineController.build
        end

        def self.render(request, response)
          puts <<-MSG

            ENTRADA:

              #{JSON.parse(request)}

            SAÍDA:

              #{response}
          MSG
        end

      end
    end
  end
end

InputInterface::View::Atm::Home.initialize_application
