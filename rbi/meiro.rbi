# typed: true

module Meiro
  extend ModuleMethods

  module ModuleMethods
    sig {params(options: T::Hash[Symbol, T.any(Integer, Float)]).returns(Dungeon)}
    def create_dungeon(options={})
    end
  end
end
