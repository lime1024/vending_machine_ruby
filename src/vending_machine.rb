require './src/drink'

class VendingMachine
  AVAILABLE_MONEY = [10, 50, 100, 500, 1000]

  attr_reader :deposit, :sales_amount, :drinks

  def initialize
    @deposit = 0
    @drinks = [{drink: Drink.new(name: 'cola', price: 120), count: 5}]
    @sales_amount = 0
  end

  def add_money(money)
    return money unless AVAILABLE_MONEY.include?(money)
    @deposit += money
    nil
  end

  def release
    release_price = @deposit
    @deposit = 0
    release_price
  end

  def buy_drink(drink_name)
    return unless can_buy?(drink_name)
    drink = select_drink(drink_name)
    drink[:count] -= 1
    @sales_amount += drink[:drink].price
    @deposit -= drink[:drink].price
    { drink_name: drink_name, deposit: release}
  end

  def can_buy?(drink_name)
    drink = select_drink(drink_name)
    drink[:count] >= 1 && drink[:drink].price <= deposit
  end

  def select_drink(drink_name)
    drinks.find do |drink|
      drink[:drink].name == drink_name
    end
  end

  def add_drink(name:, price:, count:)
    @drinks << {drink: Drink.new(name: name, price: price), count: count}
  end

  def buyable_drinks_list
    buyable_drinks.map do |drink|
      drink[:drink].name
    end
  end

  def buyable_drinks
    drinks.select do |drink|
      drink[:drink].price <= deposit && drink[:count] > 0
    end
  end
end
