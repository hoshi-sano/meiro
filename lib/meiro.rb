# typed: strict

require "meiro/version"
require "meiro/options"
require "meiro/dungeon"
require "meiro/map_layer"
require "meiro/floor"
require "meiro/block"
require "meiro/partition"
require "meiro/room"
require "meiro/tile"
require "meiro/passage"

module Meiro
  module ModuleMethods
    def create_dungeon(options={})
      Dungeon.new(options)
    end
  end

  extend ModuleMethods
end
