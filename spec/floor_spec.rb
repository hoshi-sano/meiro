require 'spec_helper'

class Meiro::Floor
  # テスト用にアクセス可能にする
  attr_accessor :min_room_width, :min_room_height,
                :max_room_width, :max_room_height,
                :root_block, :base_map

  # テスト用にpublic実行可能にする
  public :do_separate?
end

describe Meiro::Floor do
  # デフォルト値
  let(:width) { 60 }
  let(:height) { 40 }
  let(:min_room_number) { 1 }
  let(:max_room_number) { 6 }
  let(:min_room_width) { 8 }
  let(:min_room_height) { 6 }
  let(:max_room_width) { 20 }
  let(:max_room_height) { 20 }
  let(:block_split_factor) { 1.0 }
  let(:options) do
    {
      width:  width,
      height: height,
      min_room_number: min_room_number,
      max_room_number: max_room_number,
      min_room_width:  min_room_width,
      min_room_height: min_room_height,
      max_room_width:  max_room_width,
      max_room_height: max_room_height,
      block_split_factor: block_split_factor,
    }
  end
  let(:dungeon) { Meiro::Dungeon.new(options) }

  describe '.new' do
    subject do
      described_class.new(dungeon, width, height,
                          min_room_width, min_room_height,
                          max_room_width, max_room_height)
    end

    context 'デフォルト値' do
      its(:dungeon) { should eq(dungeon) }
      its(:min_room_width)  { should eq(min_room_width) }
      its(:min_room_height) { should eq(min_room_height) }
      its(:max_room_width)  { should eq(max_room_width) }
      its(:max_room_height) { should eq(max_room_height) }
      its(:root_block) { should_not be_nil }
      its(:base_map) { should_not be_nil }
    end

    context '幅が下限を下回る場合' do
      let(:width) { 4 }

      it { expect{ subject }.to raise_error }
    end

    context '高さが下限を下回る場合' do
      let(:height) { 4 }

      it { expect{ subject }.to raise_error }
    end
  end

  let(:floor) do
    described_class.new(dungeon, width, height,
                        min_room_width, min_room_height,
                        max_room_width, max_room_height)
  end

  describe '#width' do
    subject { floor.width }

    context 'デフォルト値' do
      it { should eq(60) }
    end
  end

  describe '#height' do
    subject { floor.height }

    context 'デフォルト値' do
      it { should eq(40) }
    end
  end

  describe '#all_blocks' do
    before(:each) do
      floor.root_block.should_receive(:flatten).once
    end

    subject { floor.all_blocks }

    it { expect { subject }.not_to raise_error }
  end

  describe '#all_rooms' do
    let(:room) { Meiro::Room.new(3, 3) }

    subject { floor.all_rooms }

    context 'rootのみ' do
      context '部屋なしの場合' do
        it { should eq([]) }
      end

      context '部屋ありの場合' do
        before { floor.root_block.put_room(room) }

        it { should eq([room]) }
      end
    end

    context 'root分割済み' do
      before(:each) { floor.root_block.separate }

      context '部屋なしの場合' do
        it { should eq([]) }
      end

      context '部屋1個の場合' do
        before { floor.root_block.upper_left.put_room(room) }

        it { should eq([room]) }
      end

      context '部屋2個の場合' do
        let(:another_room) { Meiro::Room.new(3, 3) }

        before do
          floor.root_block.upper_left.put_room(room)
          floor.root_block.lower_right.put_room(another_room)
        end

        it { should eq([room, another_room]) }
      end
    end
  end

  describe '#get_block' do

    subject { floor.get_block(x, y) }

    context 'rootのみ' do
      [
       [0, 0],
       [1, 1],
       [0, 39], # height-1
       [0, 40], # height
       [59, 0],  # width-1
       [60, 0],  # width
       [59, 39], # width-1, height-1
       [60, 40], # width, height
      ].each do |_x, _y|
        context "座標(#{_x}, #{_y})を指定した場合" do
          let(:x) { _x }
          let(:y) { _y }
          it { should eq(floor.root_block) }
        end
      end
    end

    context 'root1回分割済み' do
      [
       [ 0,  0, :upper_left],
       [ 1,  1, :upper_left],
       [ 0, 39, :upper_left],  # height-1
       [ 0, 40, :upper_left],  # height
       [59,  0, :lower_right], # width-1
       [60,  0, :lower_right], # width
       [59, 39, :lower_right], # width-1, height-1
       [60, 40, :lower_right], # width, height
      ].each do |_x, _y, which|
        context "座標(#{_x}, #{_y})を指定した場合" do
          before(:each) { floor.root_block.separate }
          let(:x) { _x }
          let(:y) { _y }
          it "#{which}を返す" do
            should eq(floor.root_block.send(which))
          end
        end
      end
    end

    context 'root2回分割済み' do
      [
       [ 0,  0, :upper_left,  :upper_left],
       [ 1,  1, :upper_left,  :upper_left],
       [ 0, 39, :upper_left,  :lower_right],  # height-1
       [ 0, 40, :upper_left,  :lower_right],  # height
       [59,  0, :lower_right, :upper_left], # width-1
       [60,  0, :lower_right, :upper_left], # width
       [59, 39, :lower_right, :lower_right], # width-1, height-1
       [60, 40, :lower_right, :lower_right], # width, height
      ].each do |_x, _y, which_1, which_2|
        context "座標(#{_x}, #{_y})を指定した場合" do
          before(:each) do
            floor.root_block.separate
            floor.root_block.upper_left.separate
            floor.root_block.lower_right.separate
          end
          let(:x) { _x }
          let(:y) { _y }
          it "#{which_1}の#{which_2}を返す" do
            should eq(floor.root_block.send(which_1).send(which_2))
          end
        end
      end
    end
  end

  describe '#fill_floor_by_wall' do
    before(:each) { floor.fill_floor_by_wall(width, height) }

    subject { floor.base_map }

    context 'デフォルト値' do
      its(:width) { should eq(60) }
      its(:height) { should eq(40) }
      it do
        subject.each_tile do |x, y, tile|
          tile.should be_instance_of(Meiro::Tile::Wall)
        end
      end
    end
  end

  # 1 を seed にすると rand が
  #   5, 8, 9, 5, 0, 0, 1, 7, 6, 9...
  # の順に返す
  let(:randomizer) { Random.new(1) }

  describe '#generate_random_room' do
    # TODO
  end

  describe '#connect_rooms' do
    subject { floor.connect_rooms(randomizer) }

    context '部屋なしの場合' do
      before { Meiro::Room.any_instance.should_not_receive(:create_passage) }

      it { expect{ subject }.not_to raise_error }
    end

    context 'rootブロックに部屋1個の場合' do
      let(:room) { Meiro::Room.new(3, 3) }

      before do
        floor.root_block.put_room(room)
        room.should_receive(:create_passage).once.with(randomizer)
      end

      it { expect{ subject }.not_to raise_error }
    end

    context '部屋2個の場合' do
      let(:room1) { Meiro::Room.new(3, 3) }
      let(:room2) { Meiro::Room.new(3, 3) }

      before do
        floor.root_block.separate
        floor.root_block.upper_left.put_room(room1)
        floor.root_block.lower_right.put_room(room2)
        room1.should_receive(:create_passage).once.with(randomizer)
        room2.should_receive(:create_passage).once.with(randomizer)
      end

      it { expect{ subject }.not_to raise_error }
    end
  end

  describe '#apply_rooms_to_map' do
    subject { floor.apply_rooms_to_map }

    context '部屋なしの場合' do
      before do
        floor.base_map.should_not_receive(:apply_room)
        Meiro::Room.any_instance.should_not_receive(:apply_passage)
      end

      it { expect{ subject }.not_to raise_error }
    end

    context '部屋2個の場合' do
      let(:room1) { Meiro::Room.new(3, 3) }
      let(:room2) { Meiro::Room.new(3, 3) }
      let(:flat_klass) { Meiro::Tile::Flat }
      let(:pass_klass) { Meiro::Tile::Passage }
      let(:gate_klass) { Meiro::Tile::Gate }

      before do
        floor.root_block.separate
        floor.root_block.upper_left.put_room(room1)
        floor.root_block.lower_right.put_room(room2)
        map = floor.base_map
        map.should_receive(:apply_room).with(room1, flat_klass).once
        map.should_receive(:apply_room).with(room2, flat_klass).once
        map.should_receive(:apply_passage).
          with([room1, room2], gate_klass, pass_klass).once
      end

      it { expect{ subject }.not_to raise_error }
    end
  end

  describe '#separate_blocks' do
    subject do
      floor.separate_blocks(min_room_number, max_room_number,
                            block_split_factor, randomizer)
    end

    context 'Room数下限:1,上限:6でsplit_factorが1.0の場合' do
      # 第1世代(root): (1 / 1.0 < 5) => true
      # => 分割後、合計2個
      # 第2世代_1:     (2 / 1.0 < 8) => true
      # 第2世代_2:     (2 / 1.0 < 9) => true
      # => 分割後、合計4個
      # 第3世代_1:     (3 / 1.0 < 5) => true
      # 第3世代_2:     (3 / 1.0 < 0) => false
      # 第3世代_3:     (3 / 1.0 < 0) => false
      # 第3世代_4:     (3 / 1.0 < 1) => false
      # => 分割後、合計5個
      its('root_block.flatten.size') { should eq(5) }
    end

    context 'Room数下限:1,上限:1でsplit_factorが1.0の場合' do
      let(:max_room_number) { 1 }
      # 第1世代(root)-try1: (1 / 1.0 < 5) => true
      # => 分割後2個になり、失敗判定でやり直し
      # 第1世代(root)-try2: (1 / 1.0 < 8) => true
      # => 分割後2個になり、失敗判定でやり直し
      # 第1世代(root)-try3: (1 / 1.0 < 9) => true
      # => 分割後2個になり、失敗判定でやり直し
      # 第1世代(root)-try4: (1 / 1.0 < 5) => true
      # => 分割後2個になり、失敗判定でやり直し
      # 第1世代(root)-try5: (1 / 1.0 < 0) => false
      # => 分割せず条件を満たして終了
      its('root_block.flatten.size') { should eq(1) }
    end

    context 'Room数下限:2,上限:2でsplit_factorが1.0の場合' do
      let(:min_room_number) { 2 }
      let(:max_room_number) { 2 }
      its('root_block.flatten.size') { should eq(2) }
    end

    context 'Room数下限:3,上限:3でsplit_factorが1.0の場合' do
      let(:min_room_number) { 3 }
      let(:max_room_number) { 3 }
      its('root_block.flatten.size') { should eq(3) }
    end

    context 'Room数下限:4,上限:4でsplit_factorが1.0の場合' do
      let(:min_room_number) { 4 }
      let(:max_room_number) { 4 }
      its('root_block.flatten.size') { should eq(4) }
    end

    context '不可能な条件を指定した場合' do
      let(:min_room_number) { 100 }
      let(:max_room_number) { 100 }

      it { expect { subject }.to raise_error }
    end
  end

  describe '#do_separate?' do
    let(:randomizer) { Random.new(1) }
    let(:block) { floor.root_block }

    subject { floor.do_separate?(block, block_split_factor, randomizer) }

    context 'rootの分割判定' do
      context 'split_factorが1.0、乱数が5を返す場合' do
        # block.generation が 1,
        # block_split_factor が 1.0,
        # 乱数が 5 を必ず返すため、 1 / 1.0 < 5 で true
        it { should be_true }
      end

      context 'split_factorが0.1、乱数が5を返す場合' do
        let(:block_split_factor) { 0.1 }
        # block.generation が 1,
        # block_split_factor が 0.1,
        # 乱数が 5 を必ず返すため、 1 / 0.1 > 5 で false
        it { should be_false }
      end

      context 'split_factorが10.0、乱数が5を返す場合' do
        let(:block_split_factor) { 10.0 }
        # block.generation が 1,
        # block_split_factor が 10.0,
        # 乱数が 5 を必ず返すため、 1 / 10 < 5 で true
        it { should be_true }
      end
    end

    context '5世代目のBlockの分割判定' do
      let(:first)  { Meiro::Block.new(floor, 0, 0, width, height, nil) }
      let(:second) { Meiro::Block.new(floor, 0, 0, width, height, first) }
      let(:third)  { Meiro::Block.new(floor, 0, 0, width, height, second) }
      let(:fourth) { Meiro::Block.new(floor, 0, 0, width, height, third) }
      let(:block)  { Meiro::Block.new(floor, 0, 0, width, height, fourth) }

      context 'split_factorが1.0、乱数が5を返す場合' do
        # block.generation が 5,
        # block_split_factor が 1.0,
        # 乱数が 5 を必ず返すため、 5 / 1.0 == 5 で false
        it { should be_false }
      end

      context 'split_factorが0.1、乱数が5を返す場合' do
        let(:block_split_factor) { 0.1 }
        # block.generation が 5,
        # block_split_factor が 0.1,
        # 乱数が 5 を必ず返すため、 5 / 0.1 > 5 で false
        it { should be_false }
      end

      context 'split_factorが10.0、乱数が5を返す場合' do
        let(:block_split_factor) { 10.0 }
        # block.generation が 5,
        # block_split_factor が 10.0,
        # 乱数が 5 を必ず返すため、 5 / 10 < 5 で true
        it { should be_true }
      end
    end
  end
end
