require "./config/application.rb"

RSpec.describe Application::ATM::Domain::CashMachine do

  describe ".add_notes" do

    context "when try to refuel without getting a note" do
      atm = described_class.new(id: 1)

      it "should raises an exception" do
        expect {
          atm.add_notes
        }.to raise_error(StandardError)
      end
    end

    context "given a context2" do
      it "true" do
        expect(true).to be_truthy
      end
    end

  end

end
