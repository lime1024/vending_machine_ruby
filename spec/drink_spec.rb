require 'spec_helper'

RSpec.describe Drink do
  describe 'ジュースの情報' do
    it 'ジュースは値段と名前を持っている' do
      drink = Drink.new(name: 'cola', price: 120)
      expect(drink.name).to eq 'cola'
      expect(drink.price).to eq 120
    end
  end
end
