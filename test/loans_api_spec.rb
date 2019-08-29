require_relative 'spec_helper'

RSpec.describe 'Loans API' do
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  let(:json_response) { JSON.parse(last_response.body) }

  describe '/' do
    it 'says hello' do
      get '/'
      expect(last_response).to be_successful
      expect(json_response).to eq('bling' => 'bling', 'env' => 'test')
    end
  end

  describe '/loans' do
    it 'creates a new loan on post' do
      post '/loan', { amount: '100.12', date: '2019-01-01', interest_rate: '0.1' }.to_json
      expect(last_response.status).to eq(200)
      expect(json_response['interest_rate']).to eq('0.1')
      expect(json_response['amount']).to eq('100.12')
      expect(json_response['date']).to eq(Time.zone.parse('2019-01-01').as_json)
    end
  end

  describe '/payment' do
    before do
      post '/loan', { amount: '100.12', date: '2019-01-01', interest_rate: '0.1' }.to_json
    end
    it 'creates a new payment on post' do
      post '/payment', { amount: '100.12', date: '2019-01-01' }.to_json
      expect(last_response.status).to eq(200)
      expect(json_response['amount']).to eq('100.12')
      expect(json_response['date']).to eq(Time.zone.parse('2019-01-01').as_json)
    end
  end

  describe '/balance' do
    it 'responds with the current balance' do
      post '/loan', { amount: '100.12', date: '2019-01-01', interest_rate: '0.1' }.to_json
      post '/payment', { amount: '10', date: '2019-01-03' }.to_json
      get '/balance', date: '2019-01-04'
      expect(last_response.status).to eq(200)
      expect(json_response['balance']).to eq('90.23')
    end
  end
end
