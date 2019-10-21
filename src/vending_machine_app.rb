require './src/vending_machine'

class VendingMachineApp
  puts "自販機の世界へようこそ！自販機を作成しますか？ (y/n)"
  create_question = gets.chomp
  vending_machine = VendingMachine.new if create_question == 'y'

  puts "お金を入れて下さい (10 円玉, 50 円玉, 100 円玉, 500 円玉, 1000 円札)"
  money = gets.chomp.to_i
  vending_machine.add_money(money)
  puts "投入金額合計 : #{vending_machine.deposit}"

  while vending_machine.buyable_drinks.empty?
    puts "お金を入れて下さい (10 円玉, 50 円玉, 100 円玉, 500 円玉, 1000 円札)"
    money = gets.chomp.to_i
    vending_machine.add_money(money)
    puts "投入金額合計 : #{vending_machine.deposit}"
  end

  puts "現在購入できる飲み物 : #{vending_machine.buyable_drinks_list.join(' ')}"
  puts "購入したい飲み物の名前を入力して下さい。購入しない場合は続けてお金を入れて下さい (10 円玉, 50 円玉, 100 円玉, 500 円玉, 1000 円札)"

  while input = gets.chomp
    if VendingMachine::AVAILABLE_MONEY.include?(input.to_i)
      money = input.to_i
      vending_machine.add_money(money)
      puts "投入金額合計 : #{vending_machine.deposit}"
      puts "現在購入できる飲み物 : #{vending_machine.buyable_drinks_list.join(' ')}"
      puts "購入したい飲み物の名前を入力して下さい。購入しない場合は続けてお金を入れて下さい (10 円玉, 50 円玉, 100 円玉, 500 円玉, 1000 円札)"
    elsif vending_machine.buyable_drinks_list.include?(input)
      drink_name = input
      bought_drink = vending_machine.buy_drink(drink_name)
      puts "ガコン #{bought_drink[:drink_name]}"
      puts "チャリン #{bought_drink[:deposit]}"
      break
    end
  end
end
