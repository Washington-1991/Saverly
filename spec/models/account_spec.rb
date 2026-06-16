require 'rails_helper'

RSpec.describe Account, type: :model do
  describe "associations" do
    it { should belong_to(:user) }
    it { should have_many(:movements_as_source).class_name('Movement').with_foreign_key('source_account_id').dependent(:restrict_with_error) }
    it { should have_many(:movements_as_destination).class_name('Movement').with_foreign_key('destination_account_id').dependent(:restrict_with_error) }
  end

  describe "validations" do
    subject { build(:account) }
    it { should validate_presence_of(:name) }
    it { should validate_uniqueness_of(:name).scoped_to(:user_id).case_insensitive }
    it { should validate_presence_of(:kind) }
    it { should validate_inclusion_of(:kind).in_array(Account::KINDS) }
    it { should validate_numericality_of(:current_balance) }
  end

  describe "methods" do
    let(:user) { create(:user) }
    let(:asset_account) { create(:account, user: user, kind: "asset", current_balance: 0) }
    let(:expense_account) { create(:account, user: user, kind: "expense") }

    it "#balance returns current_balance" do
      expect(asset_account.balance).to eq(asset_account.current_balance)
    end

    it "#asset? returns true for asset accounts" do
      expect(asset_account.asset?).to be true
      expect(expense_account.asset?).to be false
    end

    it "#adjust_balance! updates balance with lock" do
      expect { asset_account.adjust_balance!(200) }.to change { asset_account.reload.current_balance }.by(200)
    end

    it "#recalc_balance! recalculates from movements" do
      income_account = create(:account, user: user, kind: "income")
      create(:movement, user: user, source_account: income_account, destination_account: asset_account, amount: 500)
      dest = create(:account, user: user, kind: "asset")
      create(:movement, user: user, source_account: asset_account, destination_account: dest, amount: 50)
      asset_account.recalc_balance!
      expect(asset_account.current_balance).to eq(450)
    end
  end
end
