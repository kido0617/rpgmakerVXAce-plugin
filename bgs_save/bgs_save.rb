#===============================================================================
# 2018/08/05 kido
# https://kido0617.github.io/
# スクリプトコマンドで以下のように実行します
# BGSの保存: $game_system.save_bgs
# BGSの再開: $game_system.replay_bgs
#
# Ver.1.0
#-------------------------------------------------------------------------------

class Game_System

  alias myinit initialize
  def initialize
    myinit
    @saved_bgs = nil
  end
 
  def save_bgs
    @saved_bgs = RPG::BGS.last
  end

  def replay_bgs
    @saved_bgs.replay if @saved_bgs
  end
end
