require_relative 'spec_helper'

RSpec.describe Loan do
  let(:start_date) { Time.zone.parse('2019-01-01') }
  let(:amount) { 100 }
  let(:interest_rate) { BigDecimal('0.2') }
  let(:payment) { { date: Time.zone.parse('2019-01-01'), amount: 100 } }
  let(:subject) { Loan.new(amount: amount, date: start_date, interest_rate: interest_rate) }

  describe '.new' do
    it 'should create a new loan with attributes set' do
      expect(subject.amount).to eq(amount)
      expect(subject.date).to eq(start_date)
      expect(subject.interest_rate).to eq(interest_rate)
    end
  end

  describe '.add_payment' do
    it 'should return the payment' do
      expect(subject.add_payment(payment)).to eq(payment)
    end

    it 'should add payment to payments list' do
      another_payment = payment.dup.tap { |p| p[:amount] += 100 }
      subject.add_payment(payment)
      subject.add_payment(another_payment)
      expect(subject.payments.size).to eq(2)
      expect(subject.payments).to contain_exactly(payment, another_payment)
    end
  end

  describe '.balance' do
    subject { Loan.new(date: start_date, amount: 100, interest_rate: BigDecimal('0.1')) }

    it 'should return balance on start date without any interest' do
      expect(subject.balance(start_date)).to eq(BigDecimal('100.03'))
    end

    it 'should include accrued interest rate in balance at end of year' do
      expect(subject.balance(start_date.end_of_year)).to eq(BigDecimal('110.67'))
    end

    it 'should include accrued interest up until date supplied' do
      balance_at = Time.zone.local(2019, 1, 4)
      expect(subject.balance(balance_at)).to eq(BigDecimal('100.11'))
    end

    it 'should subtract payments from balance and include accrued interest rate' do
      subject.add_payment(date: '2019-1-6', amount: BigDecimal('50'))
      expect(subject.balance('2019-1-8')).to eq(BigDecimal('50.19'))
    end

    it 'should subtract payments from balance and include accrued interest rate' do
      subject.add_payment(date: '2019-1-6', amount: BigDecimal('50'))
      subject.add_payment(date: '2019-1-8', amount: BigDecimal('50.19'))
      expect(subject.balance('2019-1-8')).to be_zero
    end
  end
end
