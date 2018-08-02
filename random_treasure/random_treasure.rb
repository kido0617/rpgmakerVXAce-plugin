#===============================================================================
# 2018/08/03 @kido0617
# http://kido0617.github.io/
# 完全に自由にどうぞ。
# クレジットの表記もいりません。
# 詳細: http://kido0617.github.io/rpgmaker/2018-08-03-random-treasure-vxace
# Ver.1.0
#-------------------------------------------------------------------------------


module RANDOMTREASURE
  NAME_VAR = -1   #取得したアイテム名を格納する変数番号
  ICON_VAR = -1   #取得したアイテムのアイコン番号を格納する変数番号
end

class Game_System
  attr_accessor :random_treasures

  alias my_init initialize
  def initialize
    my_init
    @random_treasures = nil
  end
end

class Random_Treasure

  @@shop_interrupt = false

  def self.reset
    @@shop_interrupt = true
  end

  def self.is_reset?
    @@shop_interrupt
  end

  def self.shop_called
    @@shop_interrupt = false
  end

  def self.get
    if !$game_system.random_treasures || $game_system.random_treasures.length == 0
      return
    end
    rate_max = 0
    $game_system.random_treasures.each do |treasure|
      rate_max += treasure['rate']
    end
    rand = rand(rate_max)
    sum = 0
    for i in 0..$game_system.random_treasures.length do
      sum += $game_system.random_treasures[i]['rate']
      if rand < sum 
        id = $game_system.random_treasures[i]['id']
        type = $game_system.random_treasures[i]['type']
        item = self.get_item(type, id)
        break
      end
    end
    $game_party.gain_item(item, 1)
    if RANDOMTREASURE::NAME_VAR != -1
       $game_variables[RANDOMTREASURE::NAME_VAR] = item.name
    end
    if RANDOMTREASURE::ICON_VAR != -1
       $game_variables[RANDOMTREASURE::ICON_VAR] = item.icon_index
    end
  end

  def self.get_item(type, id)
    case type
    when 0;
      item = $data_items[id]
    when 1;
      item = $data_weapons[id]
    when 2;
      item = $data_armors[id]
    end
    return item
  end

end


class Game_Interpreter

  alias my_command_302 command_302
  def command_302
    if Random_Treasure.is_reset?
      Random_Treasure.shop_called
      goodsList = [@params]
      while next_event_code == 605
        @index += 1
        goodsList.push(@list[@index].parameters)
      end
      data = [];
      goodsList.each do |goods|
        item = Random_Treasure.get_item(goods[0], goods[1])
        data.push({
          'type' => goods[0],
          'id' => goods[1],
          'rate' => goods[2] === 0 ? item.price : goods[3]
        });
      end
      $game_system.random_treasures = data
      Fiber.yield
    else
      my_command_302
    end
  end
end
