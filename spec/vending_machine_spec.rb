require 'spec_helper'

RSpec.describe VendingMachine do
  let(:vending_machine) { VendingMachine.new }

  describe 'お金の投入' do
    context '使用可能なお金が投入されたとき' do
      it '投入金額の総計を取得できる' do
        vending_machine.add_money(100)
        deposit = vending_machine.deposit
        expect(deposit).to eq 100
      end

      it '複数回お金を投入できる' do
        vending_machine.add_money(10)
        vending_machine.add_money(50)
        vending_machine.add_money(100)
        vending_machine.add_money(500)
        vending_machine.add_money(1000)
        deposit = vending_machine.deposit
        expect(deposit).to eq 1660
      end

      it '釣り銭は出力されない' do
        expect(vending_machine.add_money(100)).to eq nil
        expect(vending_machine.add_money(50)).to eq nil
      end

      it '現在の売上金額が取得できる' do
        vending_machine.add_money(500)
        vending_machine.buy_drink('cola')
        expect(vending_machine.sales_amount).to eq 120
      end
    end

    context '使用不可能なお金が投入されたとき' do
      it '投入金額に加算せず、そのまま釣り銭としてユーザに出力する' do
        vending_machine.add_money(100)
        expect(vending_machine.add_money(1)).to eq 1
        expect(vending_machine.add_money(5)).to eq 5
        expect(vending_machine.add_money(2000)).to eq 2000
        expect(vending_machine.add_money(5000)).to eq 5000
        expect(vending_machine.add_money(10000)).to eq 10000
        expect(vending_machine.add_money(999)).to eq 999
        expect(vending_machine.deposit).to eq 100
      end
    end
  end

  describe 'お金の払い戻し' do
    it '払い戻し操作を行うと、投入金額の総計を釣り銭として出力する' do
      vending_machine.add_money(500)
      release_price = vending_machine.release
      deposit = vending_machine.deposit
      expect(release_price).to eq 500
      expect(deposit).to eq 0
    end
  end

  describe 'ジュースの管理' do
    it '初期状態でコーラを5本格納している' do
      drinks = vending_machine.drinks
      expect(drinks.size).to eq 1
      expect(drinks[0][:drink].name).to eq 'cola'
      expect(drinks[0][:drink].price).to eq 120
      expect(drinks[0][:count]).to eq 5
    end

    it 'ジュースの在庫を追加できる' do
      expect{
        vending_machine.add_drink(name: 'redbull', price: 200, count: 5)
        vending_machine.add_drink(name: 'water', price: 100, count: 5)
      }.to change{ vending_machine.drinks.size }.from(1).to(3)
      redbull = vending_machine.select_drink('redbull')
      water = vending_machine.select_drink('water')
      expect(redbull[:count]).to eq 5
      expect(redbull[:drink].price).to eq 200
      expect(water[:count]).to eq 5
      expect(water[:drink].price).to eq 100
    end
  end

  describe 'ジュースの購入' do
    context 'ジュースの値段以上の金額が投入されているとき' do
      it '購入するとジュースとお釣りが返ってくる' do
        vending_machine.add_money(100)
        vending_machine.add_money(100)
        expect(vending_machine.buy_drink('cola')).to eq ({ drink_name: 'cola', deposit: 80 })
      end

      it '購入するとジュースの在庫を減らし、売上金額を増やす' do
        vending_machine.add_money(100)
        vending_machine.add_money(10)
        vending_machine.add_money(10)
        drinks = vending_machine.drinks
        expect(drinks[0][:drink].name).to eq 'cola'
        expect{ vending_machine.buy_drink('cola') }.to change{ drinks[0][:count] }.by(-1)
        expect(vending_machine.sales_amount).to eq 120
      end

      it '在庫があれば購入できることが取得できる' do
        vending_machine.add_money(100)
        vending_machine.add_money(100)
        expect(vending_machine.can_buy?('cola')).to be true
      end

      it '在庫がなければ購入できない' do
        5.times do
          vending_machine.add_money(100)
          vending_machine.add_money(100)
          vending_machine.buy_drink('cola')
        end
        expect(vending_machine.can_buy?('cola')).to be false
        expect(vending_machine.buy_drink('cola')).to be nil
      end

      it '購入すると釣り銭を出力する' do
        vending_machine.add_money(100)
        vending_machine.add_money(100)
        expect(vending_machine.buy_drink('cola')).to eq ({ drink_name: 'cola', deposit: 80 })
        expect(vending_machine.deposit).to eq 0
      end

      it '投入金額とジュースが同じ値段でも釣り銭を出力する' do
        vending_machine.add_money(100)
        vending_machine.add_money(10)
        vending_machine.add_money(10)
        expect(vending_machine.buy_drink('cola')).to eq ({ drink_name: 'cola', deposit: 0 })
      end
    end

    context 'ジュースの値段以下の金額が投入されているとき' do
      it '在庫があっても購入できないことが取得できる' do
        vending_machine.add_money(100)
        expect(vending_machine.can_buy?('cola')).to be false
        expect(vending_machine.buy_drink('cola')).to be nil
      end
    end
  end

  describe '購入可能なジュースのリストの取得' do
    it '120円以下の商品はリストに含まれていること' do
      vending_machine.add_drink(name: 'water', price: 100, count: 1)
      vending_machine.add_drink(name: 'redbull', price: 200, count: 1)
      vending_machine.add_money(100)
      vending_machine.add_money(10)
      vending_machine.add_money(10)
      expect(vending_machine.buyable_drinks_list).to match_array ['water', 'cola']
    end

    it '在庫が無い商品はリストに含まれないこと' do
      vending_machine.add_drink(name: 'redbull', price: 200, count: 1)
      vending_machine.add_money(500)
      vending_machine.buy_drink('redbull')
      vending_machine.add_money(500)
      expect(vending_machine.buyable_drinks_list).to_not include ['redbull']
    end
  end
end
