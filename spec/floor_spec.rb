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
  let(:seed) { 1 }

  describe '#separate_blocks' do
    subject do
      floor.separate_blocks(min_room_number, max_room_number,
                            block_split_factor, seed)
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
    let(:arbiter) { Random.new(seed) }
    let(:block) { floor.root_block }

    subject { floor.do_separate?(block, block_split_factor, arbiter) }

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
      let(:first)  { Meiro::Block.new(0, 0, width, height, nil) }
      let(:second) { Meiro::Block.new(0, 0, width, height, first) }
      let(:third)  { Meiro::Block.new(0, 0, width, height, second) }
      let(:fourth) { Meiro::Block.new(0, 0, width, height, third) }
      let(:block)  { Meiro::Block.new(0, 0, width, height, fourth) }

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
