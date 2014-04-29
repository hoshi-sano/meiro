# Meiro

Meiroはいわゆる「ローグライク」系、「不思議のダンジョン」系といわれる
ゲームに使われるようなランダムダンジョン生成用のRubyライブラリです。

Meiro is Random Dungeon Generator for Ruby.
It generates maps used for so-called Rogue-like games.

## インストール - Installation

TODO:

## 使用方法 - Usage

### 基本的な使い方 - Basic Usage

```ruby
require 'meiro'

options = {
  width:  40,
  height: 25,
  min_room_number: 3,
  max_room_number: 6,
  min_room_width:  5,
  max_room_width: 10,
  min_room_height: 3,
  max_room_height: 5,
  block_split_factor: 3.0,
}
dungeon = Meiro.create_dungeon(options)
floor = dungeon.generate_random_floor

floor.classify!(:rogue_like)
puts floor.to_s
# =>
#                                        
#                                        
#                                        
#   |-----|                              
#   |.....|                              
#   |.....|                              
#   |.....+###########     |----------|  
#   |.....|          #     |..........|  
#   |-+---|          ######+..........|  
#     #                    |..........|  
#     #                    |-+--------|  
#     #                      #           
#     #####                ###           
#         #                #             
#       |-+--------|       #             
#       |..........|   |---+------|      
#       |..........|   |..........|      
#       |..........+###+..........|      
#       |..........|   |..........|      
#       |----------|   |----------|      
#                                        
#                                        
#                                        
#                                        
#                                        
```

### 基本構造 - Basic Structure

```
  Dungeon
     |
     +--- Floor
            |
            +--- MapLayer
            |      |
            |      +--- Tiles
            |
            +--- Block(Root)
                   |
                   +--- Block
                   |      |
                   |      +--- Block --- Room
                   |      |
                   |      +--- Block --- Room
                   |
                   +--- Block
                          |
                          +--- Block --- Room
                          |
                          +--- Block --- Room

```

## Contributing

1. Fork it ( http://github.com/hoshi-sano/meiro/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
