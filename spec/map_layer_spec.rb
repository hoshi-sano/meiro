require 'spec_helper'

class Meiro::MapLayer
  # テスト用にアクセス可能にする
  attr_accessor :map
end

describe Meiro::MapLayer do
  let(:width) { 10 }
  let(:height) { 5 }

  describe '.new' do
    context '幅:10、高さ:5の場合' do
      subject { described_class.new(width, height) }

      its(:map) do
        expect = [[nil,nil,nil,nil,nil,nil,nil,nil,nil,nil],
                  [nil,nil,nil,nil,nil,nil,nil,nil,nil,nil],
                  [nil,nil,nil,nil,nil,nil,nil,nil,nil,nil],
                  [nil,nil,nil,nil,nil,nil,nil,nil,nil,nil],
                  [nil,nil,nil,nil,nil,nil,nil,nil,nil,nil],]
        should eq(expect)
      end
    end
  end

  let(:map_layer) { described_class.new(width, height) }

  describe '#[]' do
    before(:each) { map_layer.map = [[1,2,3],[4,5,6],[7,8,9]] }

    subject { map_layer[x, y] }

    [
     [0, 0, 1],
     [1, 0, 2],
     [2, 0, 3],
     [0, 1, 4],
     [1, 1, 5],
     [2, 1, 6],
     [0, 2, 7],
     [1, 2, 8],
     [2, 2, 9],
    ].each do |_x, _y, expect|
      context "[#{_x}, #{_y}]にアクセスした場合" do
        let(:x) { _x }
        let(:y) { _y }

        it { should eq(expect) }
      end
    end
  end

  describe '#[]=' do
    [
     [0, 0, 1],
     [1, 0, 2],
     [2, 0, 3],
     [0, 1, 4],
     [1, 1, 5],
     [2, 1, 6],
     [0, 2, 7],
     [1, 2, 8],
     [2, 2, 9],
    ].each do |_x, _y, v|
      context "[#{_x}, #{_y}]にアクセスした場合" do
        subject { map_layer[_x, _y] = v; map_layer[_x, _y] }

        it { should eq(v) }
      end
    end
  end

  describe '#each_line' do
    before(:each) { map_layer.map = [[1,2,3],[4,5,6],[7,8,9]] }

    subject do
      sub = []
      map_layer.each_line {|line| sub.unshift(line) }
      sub
    end

    it { should eq([[7,8,9],[4,5,6],[1,2,3]]) }
  end

  describe '#each_tile' do
    before(:each) { map_layer.map = [[1,2,3],[4,5,6],[7,8,9]] }

    subject do
      sub = [[],[],[]]
      map_layer.each_tile {|x, y, tile| sub[x][y] = tile }
      sub
    end

    it { should eq([[1,4,7],[2,5,8],[3,6,9]]) }
  end
end

class Meiro::BaseMap
  # テスト用にアクセス可能にする
  attr_accessor :map
end

describe Meiro::BaseMap do
  let(:dungeon) { Meiro::Dungeon.new }
  let(:floor) do
    args = [dungeon, dungeon.width, dungeon.height,
            dungeon.min_room_width, dungeon.min_room_height,
            dungeon.max_room_width, dungeon.max_room_height,]
    Meiro::Floor.new(*args)
  end

  let(:width) { 10 }
  let(:height) { 5 }
  let(:wall_klass) { Meiro::Tile::Wall }

  describe '.new' do
    context '要素のクラス指定なしの場合' do
      subject { described_class.new(width, height) }

      its(:map) do
        expect = [[nil,nil,nil,nil,nil,nil,nil,nil,nil,nil],
                  [nil,nil,nil,nil,nil,nil,nil,nil,nil,nil],
                  [nil,nil,nil,nil,nil,nil,nil,nil,nil,nil],
                  [nil,nil,nil,nil,nil,nil,nil,nil,nil,nil],
                  [nil,nil,nil,nil,nil,nil,nil,nil,nil,nil],]
        should eq(expect)
      end
    end

    context '要素のクラス指定ありの場合' do
      subject { described_class.new(width, height, wall_klass) }

      its(:map) do
        subject.each_tile do |x, y, tile|
          tile.should be_instance_of(wall_klass)
        end
      end
    end
  end

  let(:base_map) { described_class.new(width, height, wall_klass) }

  describe '#apply_room' do
    let(:klass_1) { class C1; def self.new; 1; end; end; C1 }
    let(:klass_0) { class C0; def self.new; 0; end; end; C0 }
    let(:base_map) { described_class.new(width, height, klass_1) }
    let(:width) { 5 }
    let(:heiht) { 5 }
    let(:block) { Meiro::Block.new(floor, 0, 0, 5, 5) }
    let(:room) { Meiro::Room.new(3, 3) }

    before(:each) do
      room.block = block
      room.relative_x = 1
      room.relative_y = 1
    end

    subject do
      base_map.apply_room(room, klass_0)
      base_map.map
    end

    it do
      should eq([[1,1,1,1,1],
                 [1,0,0,0,1],
                 [1,0,0,0,1],
                 [1,0,0,0,1],
                 [1,1,1,1,1],])
    end
  end
end
