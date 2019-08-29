require 'active_support/all'
require 'active_support/time'
require 'sinatra'
require 'sinatra/reloader' if ENV['RACK_ENV'] == 'development'
require 'sinatra/json'
require_relative 'loan'

current_loan = nil

def parse_date(date)
  Time.zone = 'Europe/Stockholm'
  Time.zone.parse(date)
end

def parsed_params

  JSON.parse(request.body.read).symbolize_keys.tap do |p|
    p[:date] = parse_date(p[:date])
  end
end

get '/' do
  json(bling: 'bling', env: settings.environment)
end

post '/loan' do
  current_loan = Loan.new(parsed_params)
  json(current_loan.to_h)
end

post '/payment' do
  json current_loan.add_payment(parsed_params)
end

get '/balance' do
  json(balance: current_loan.balance(parse_date(params['date'])))
end
