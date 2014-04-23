require 'spec_helper'

class Meiro::Block
  # テスト用にアクセス可能にする
  attr_accessor :parent, :shape

  # テスト用にpublic実行可能にする
  public :vertical_separate, :horizontal_separate
end

describe Meiro::Block do
  let(:dungeon) { Meiro::Dungeon.new }
  let(:floor) do
    args = [dungeon, dungeon.width, dungeon.height,
            dungeon.min_room_width, dungeon.min_room_height,
            dungeon.max_room_width, dungeon.max_room_height,]
    Meiro::Floor.new(*args)
  end

  let(:x) { 0 }
  let(:y) { 0 }
  let(:width) { 60 }
  let(:height) { 40 }
  let(:parent) { nil }
  let(:block) { described_class.new(floor, x, y, width, height, parent) }

  shared_examples 'vertical' do
    its(:shape) { should eq(:vertical) }
  end

  shared_examples 'horizontal' do
    its(:shape) { should eq(:horizontal) }
  end

  describe '.new' do
    shared_examples 'basic_parameters' do
      its(:x) { x }
      its(:y) { y }
      its(:width) { width }
      its(:height) { height }
    end

    subject { described_class.new(floor, x, y, width, height, parent) }

    context 'rootの場合' do
      context '横長の場合' do
        include_examples 'basic_parameters'
        include_examples 'horizontal'
        its(:parent) { should be_nil }
      end

      context '縦長の場合' do
        let(:height) { 70 }
        include_examples 'basic_parameters'
        include_examples 'vertical'
        its(:parent) { should be_nil }
      end
    end

    context 'parentがいる場合' do
      let(:parent) { described_class.new(floor, x, y, width, height, nil) }

      context '横長の場合' do
        include_examples 'basic_parameters'
        include_examples 'horizontal'
        its(:parent) { should_not be_nil }
      end

      context '縦長の場合' do
        let(:height) { 70 }
        include_examples 'basic_parameters'
        include_examples 'vertical'
        its(:parent) { should_not be_nil }
      end
    end
  end

  describe '#separate' do
    subject { block.separate }

    context '返り値' do
      context '分割可能なBlockの場合' do
        context '横長の場合' do
          it { should be_true }
        end

        context '縦長の場合' do
          let(:height) { 70 }
          it { should be_true }
        end
      end

      context '分割不可能なBlockの場合' do
        let(:width) { 5 }
        let(:height) { 5 }

        it { should be_false }
      end
    end

    context '@separated' do
      before(:each) { block.separate }

      context '分割可能なBlockの場合' do
        it { block.separated?.should be_true }
      end

      context '分割不可能なBlockの場合' do
        let(:width) { 5 }
        let(:height) { 5 }

        it { block.separated?.should be_false }
      end
    end
  end

  describe '#separatable?' do
    subject { block.separatable? }

    context '分割可能で' do
      context '横長の場合' do
        it { should be_true }
      end

      context '縦長の場合' do
        let(:height) { 70 }

        it { should be_true }
      end
    end

    context '分割不可能で' do
      context '横長の場合' do
        let(:width) { 10 }
        let(:height) { 5 }

        it { should be_false }
      end

      context '縦長の場合' do
        let(:width) { 5 }
        let(:height) { 10 }

        it { should be_false }
      end
    end
  end

  describe '#brother' do
    context 'rootの場合' do
      subject { block.brother }

      it { should be_nil }
    end

    context 'parentがいるBlock' do
      before(:each) { block.separate }

      context 'upper_leftの場合' do
        subject { block.upper_left.brother }

        it { should eq(block.lower_right) }
      end

      context 'lower_rightの場合' do
        subject { block.lower_right.brother }

        it { should eq(block.upper_left) }
      end
    end
  end

  describe '#neighbors' do
    context 'rootの場合' do
      subject { block.neighbors }

      it { should eq([]) }
    end

    context 'root1回分割済み' do
      #  +---+---+
      #  | 1 | 2 |
      #  +---+---+
      before(:each) { floor.root_block.separate }

      # 1
      context 'upper_leftの場合' do
        subject { floor.root_block.upper_left.neighbors }

        it { should eq([floor.root_block.lower_right]) }
      end

      # 2
      context 'lower_rightの場合' do
        subject { floor.root_block.lower_right.neighbors }

        it { should eq([floor.root_block.upper_left]) }
      end
    end

    context 'root2回分割済み' do
      #  +---+---+
      #  | 1 | 3 |
      #  +---+---+
      #  | 2 | 4 |
      #  +---+---+
      before(:each) do
        floor.root_block.separate
        floor.root_block.upper_left.separate
        floor.root_block.lower_right.separate
      end

      # 1
      context 'upper_left.upper_leftの場合' do
        subject { floor.root_block.upper_left.upper_left.neighbors }

        it { should eq([floor.root_block.lower_right.upper_left,    # 3
                        floor.root_block.upper_left.lower_right]) } # 2
      end

      # 2
      context 'upper_left.lower_rightの場合' do
        subject { floor.root_block.upper_left.lower_right.neighbors }

        it { should eq([floor.root_block.lower_right.lower_right,  # 4
                        floor.root_block.upper_left.upper_left]) } # 1
      end

      # 3
      context 'lower_right.upper_leftの場合' do
        subject { floor.root_block.lower_right.upper_left.neighbors }

        it { should eq([floor.root_block.upper_left.upper_left,      # 1
                        floor.root_block.lower_right.lower_right]) } # 4
      end

      # 4
      context 'lower_right.lower_rightの場合' do
        subject { floor.root_block.lower_right.lower_right.neighbors }

        it { should eq([floor.root_block.upper_left.lower_right,    # 2
                        floor.root_block.lower_right.upper_left]) } # 3
      end
    end
  end

  describe '#generation' do
    subject { block.generation }

    context 'rootの場合' do
      it { should eq(1) }
    end

    context 'rootを分割したBlockの場合' do
      let(:parent) { described_class.new(floor, x, y, width, height, nil) }
      let(:block) { described_class.new(floor, x, y, width, height, parent) }

      it { should eq(2) }
    end

    context 'rootを分割したBlockを分割したBlockの場合' do
      let(:grandparent) { described_class.new(floor, x, y, width, height, nil) }
      let(:parent) { described_class.new(floor, x, y, width, height, grandparent) }
      let(:block) { described_class.new(floor, x, y, width, height, parent) }

      it { should eq(3) }
    end
  end

  describe '#flatten' do
    subject { block.flatten }

    context '分割していない場合' do
      it { should eq([block]) }
    end

    context '1回分割したBlockの場合' do
      before(:each) { block.separate }

      it { should eq([block.upper_left, block.lower_right]) }
    end

    context '2回分割したBlockの場合' do
      before(:each) do
        block.separate
        block.upper_left.separate
        block.lower_right.separate
      end

      it { should eq([block.upper_left.upper_left,
                      block.upper_left.lower_right,
                      block.lower_right.upper_left,
                      block.lower_right.lower_right,]) }
    end
  end

  describe '#put_room' do
    subject { block.put_room(randomizer_or_room) }

    context '不正な引数を渡した場合' do
      let(:randomizer_or_room) { 1 }

      it { should be_false }
    end

    context '引数にRoomを渡す' do
      let(:randomizer_or_room) { room }

      context 'RoomがBlockに配置できない大きさだった場合' do
        let(:room) { Meiro::Room.new(width, height) }

        it { should be_false }
      end

      context 'RoomがBlockに配置可能な大きさだった場合' do
        let(:room) { Meiro::Room.new(width - 2, height - 2) }

        it { should be_true }
      end
    end

    context '引数に乱数器を渡した場合' do
      let(:randomizer_or_room) { Random.new(1) }

      it { should be_true }
    end

    context '引数にnilを渡した場合' do
      let(:randomizer_or_room) { nil }

      it { should be_true }
    end
  end

  shared_examples 'separated check' do
    its(:upper_left) { should be_instance_of(described_class) }
    its(:lower_right) { should be_instance_of(described_class) }
    its(:partition) { should be_instance_of(Meiro::Partition) }
  end

  shared_examples 'separated height check' do
    it '分割したBlockの高さの合計+1(Partition分)が分割前の高さと等しい' do
      (subject.upper_left.height +
       subject.lower_right.height + 1).should eq(height)
    end
  end

  describe '#horizontal_separate' do
    let(:separated) { block.horizontal_separate }
    subject { separated }

    context '高さが偶数の場合' do
      let(:width) { 10 }
      let(:height) { 20 }

      include_examples 'separated check'
      include_examples 'separated height check'

      its('upper_left.x') { should eq(0) }
      its('upper_left.y') { should eq(0) }
      its('upper_left.width')  { should eq(10) }
      its('upper_left.height') { should eq(10) }
      its('upper_left.generation') { should eq(2) }

      its('partition.x') { should eq(0) }
      its('partition.y') { should eq(10) }
      its('partition.length') { should eq(10) }

      its('lower_right.x') { should eq(0) }
      its('lower_right.y') { should eq(11) }
      its('lower_right.width')  { should eq(10) }
      its('lower_right.height') { should eq(9) }
      its('lower_right.generation') { should eq(2) }
    end

    context '高さが奇数の場合' do
      let(:width) { 10 }
      let(:height) { 21 }

      include_examples 'separated check'
      include_examples 'separated height check'

      its('upper_left.x') { should eq(0) }
      its('upper_left.y') { should eq(0) }
      its('upper_left.width')  { should eq(10) }
      its('upper_left.height') { should eq(10) }
      its('upper_left.generation') { should eq(2) }

      its('partition.x') { should eq(0) }
      its('partition.y') { should eq(10) }
      its('partition.length') { should eq(10) }

      its('lower_right.x') { should eq(0) }
      its('lower_right.y') { should eq(11) }
      its('lower_right.width')  { should eq(10) }
      its('lower_right.height') { should eq(10) }
      its('lower_right.generation') { should eq(2) }
    end
  end

  shared_examples 'separated width check' do
    it '分割したBlockの幅の合計+1(Partition分)が分割前の幅と等しい' do
      (subject.upper_left.width +
       subject.lower_right.width + 1).should eq(width)
    end
  end

  describe '#vertical_separate' do
    let(:separated) { block.vertical_separate }
    subject { separated }

    context '幅が偶数の場合' do
      let(:width) { 20 }
      let(:height) { 10 }

      include_examples 'separated check'
      include_examples 'separated width check'

      its('upper_left.x') { should eq(0) }
      its('upper_left.y') { should eq(0) }
      its('upper_left.width')  { should eq(10) }
      its('upper_left.height') { should eq(10) }
      its('upper_left.generation') { should eq(2) }

      its('partition.x') { should eq(10) }
      its('partition.y') { should eq(0) }
      its('partition.length') { should eq(10) }

      its('lower_right.x') { should eq(11) }
      its('lower_right.y') { should eq(0) }
      its('lower_right.width')  { should eq(9) }
      its('lower_right.height') { should eq(10) }
      its('lower_right.generation') { should eq(2) }
    end

    context '幅が奇数の場合' do
      let(:width) { 21 }
      let(:height) { 10 }

      include_examples 'separated check'
      include_examples 'separated width check'

      its('upper_left.x') { should eq(0) }
      its('upper_left.y') { should eq(0) }
      its('upper_left.width')  { should eq(10) }
      its('upper_left.height') { should eq(10) }
      its('upper_left.generation') { should eq(2) }

      its('partition.x') { should eq(10) }
      its('partition.y') { should eq(0) }
      its('partition.length') { should eq(10) }

      its('lower_right.x') { should eq(11) }
      its('lower_right.y') { should eq(0) }
      its('lower_right.width')  { should eq(10) }
      its('lower_right.height') { should eq(10) }
      its('lower_right.generation') { should eq(2) }
    end
  end
end
