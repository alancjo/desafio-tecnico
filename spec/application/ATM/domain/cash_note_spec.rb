
RSpec.describe Application::ATM::Domain::CashNote do

  let(:note_10)  { described_class.new(value: 10, quantity: 1) }
  let(:note_20)  { described_class.new(value: 20, quantity: 1) }
  let(:note_50)  { described_class.new(value: 50, quantity: 1) }
  let(:note_100) { described_class.new(value: 100, quantity: 3) }

  describe ".name" do
    it "translates name note" do
      expect(note_10.name).to eq("notasDez")
      expect(note_20.name).to eq("notasVinte")
      expect(note_50.name).to eq("notasCinquenta")
      expect(note_100.name).to eq("notasCem")
    end
  end

  describe ".increase_quantity" do
    it "increases quantity received to note" do
      expect { note_100.increase_quantity(3) }.to change { note_100.quantity }.by(3)
    end
  end

  describe ".to_hash" do
    it "returns object as hash" do
      expect(note_20.to_hash).to eq({ value: 20, quantity: 1 })
    end
  end

  describe ".withdraw" do

    context "when the note has quantity to remove" do
      it "removes 2 notes hundred when the amount to withdraw is 250" do
        remaining_value = note_100.withdraw(250)

        expect(note_100.quantity).to eq(3 - 2)
        expect(remaining_value).to eq(50)
      end
    end

    context "when the note not has quantity to remove" do
      let(:note_100) { described_class.new(value: 100, quantity: 0) }

      it "does remove decrease quantity and value to withdraw" do
        remaining_value = note_100.withdraw(250)

        expect(note_100.quantity).to eq(0)
        expect(remaining_value).to eq(250)
      end
    end
  end
end
