require 'rails_helper'

RSpec.describe Movement, type: :model do
  let(:user) { create(:user) }
  let(:source) { create(:account, user: user, kind: "asset", current_balance: 1000) }
  let(:destination) { create(:account, user: user, kind: "asset", current_balance: 0) }

  describe "validations" do
    subject { build(:movement, user: user, source_account: source, destination_account: destination) }

    it { should validate_presence_of(:date) }
    it { should validate_presence_of(:amount) }
    it { should validate_numericality_of(:amount).is_greater_than(0) }

    it "validates different accounts" do
      movement = build(:movement, user: user, source_account: source, destination_account: source)
      expect(movement).to be_invalid
      expect(movement.errors[:base]).to include("La cuenta origen y destino no pueden ser la misma")
    end

    it "validates accounts belong to same user" do
      other_user = create(:user)
      other_account = create(:account, user: other_user)
      movement = build(:movement, user: user, source_account: source, destination_account: other_account)
      expect(movement).to be_invalid
      expect(movement.errors[:base]).to include("Ambas cuentas deben pertenecer al mismo usuario")
    end

    it "validates sufficient balance for asset source" do
      source.update(current_balance: 50)
      movement = build(:movement, user: user, source_account: source, destination_account: destination, amount: 100)
      expect(movement).to be_invalid
      expect(movement.errors[:base]).to include(a_string_starting_with("Saldo insuficiente en la cuenta origen"))
    end
  end

  describe "callbacks update balances" do
    it "updates balances on create" do
      movement = create(:movement, user: user, source_account: source, destination_account: destination, amount: 100)
      expect(source.reload.current_balance).to eq(900)
      expect(destination.reload.current_balance).to eq(100)
    end

    it "updates balances on destroy" do
      movement = create(:movement, user: user, source_account: source, destination_account: destination, amount: 100)
      movement.destroy
      expect(source.reload.current_balance).to eq(1000)
      expect(destination.reload.current_balance).to eq(0)
    end

    it "updates balances on update (amount change)" do
      movement = create(:movement, user: user, source_account: source, destination_account: destination, amount: 100)
      movement.update(amount: 150)
      expect(source.reload.current_balance).to eq(850)
      expect(destination.reload.current_balance).to eq(150)
    end

    it "updates balances on update (account change)" do
      movement = create(:movement, user: user, source_account: source, destination_account: destination, amount: 100)
      new_dest = create(:account, user: user, kind: "asset")
      movement.update(destination_account: new_dest)
      expect(source.reload.current_balance).to eq(900)
      expect(destination.reload.current_balance).to eq(0)
      expect(new_dest.reload.current_balance).to eq(100)
    end
  end
end
