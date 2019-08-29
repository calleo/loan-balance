require 'bigdecimal'
require 'active_support/all'
require 'active_support/time'
require 'active_support/time'

class Loan
  attr_accessor :date
  attr_accessor :amount
  attr_accessor :interest_rate
  attr_accessor :payments

  def initialize(date:, amount:, interest_rate:)
    @date = date
    @amount = BigDecimal(amount)
    @interest_rate = BigDecimal(interest_rate)
    @payments = []
  end

  def balance(date)
    last_balance = @amount
    balance = BigDecimal("0")
    days(date).each do |d|
      balance = ((last_balance + (last_balance * (@interest_rate / 360))) - payment_sum_at(d))
      last_balance = balance
    end
    balance.round(2)
  end

  def add_payment(date:, amount:)
    { date: date, amount: BigDecimal(amount) }.tap do |payment|
      payments << payment
    end
  end

  def payment_sum_at(date)
    payments.select { |p| p[:date].to_date == date.to_date }.sum { |p| p[:amount] }
  end

  def days(at_date)
    (@date.to_date..(at_date).to_date).to_a
  end

  def to_h
    {
        amount: @amount.round(2),
        date: @date,
        interest_rate: @interest_rate.round(2)
    }
  end
end
