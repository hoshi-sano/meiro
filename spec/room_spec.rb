require 'spec_helper'

describe Meiro::Room do
  let(:dungeon) { Meiro::Dungeon.new }
  let(:floor) do
    args = [dungeon, dungeon.width, dungeon.height,
            dungeon.min_room_width, dungeon.min_room_height,
            dungeon.max_room_width, dungeon.max_room_height,]
    Meiro::Floor.new(*args)
  end

  let(:width) { 10 }
  let(:height) { 5 }

  describe '.new' do
    subject { described_class.new(width, height) }

    context '正常系' do
      context '汎用値' do
        let(:width) { 10 }
        let(:height) { 5 }

        its(:width) { should eq(10) }
        its(:height) { should eq(5) }
      end

      context '最小値' do
        let(:width) { 3 }
        let(:height) { 3 }

        its(:width) { should eq(3) }
        its(:height) { should eq(3) }
      end
    end

    context '異常系' do
      context '幅が小さすぎる場合' do
        let(:width) { 2 }

        it { expect {subject}.to raise_error }
      end

      context '高さが小さすぎる場合' do
        let(:height) { 2 }

        it { expect {subject}.to raise_error }
      end
    end
  end

  let(:room) { described_class.new(width, height) }

  let(:b_x) { 0 }
  let(:b_y) { 0 }
  let(:b_width) { 60 }
  let(:b_height) { 40 }
  let(:parent) { nil }
  let(:block) { Meiro::Block.new(floor, b_x, b_y, b_width, b_height, parent) }

  let(:relative_x) { 8 }
  let(:relative_y) { 4 }

  describe '#x' do
    context 'Blockを紐付けていない場合' do
      subject do
        room.relative_x = relative_x
        room.relative_y = relative_y
        room.x
      end

      it { should be_nil }
    end

    context 'Blockを紐付けている場合' do
      subject do
        block.put_room(room)
        room.relative_x = relative_x
        room.relative_y = relative_y
        room.x
      end

      context 'Blockのx座標が0の場合' do
        it 'Roomの相対座標がそのまま絶対座標となる' do
          should eq(8)
        end
      end

      context 'Blockのx座標が>0の場合' do
        let(:b_x) { 5 }

        it 'Blockのx座標にRoomの相対座標を足しあわせたものが絶対座標となる' do
          should eq(13)
        end
      end
    end
  end

  describe '#y' do
    context 'Blockを紐付けていない場合' do
      subject do
        room.relative_x = relative_x
        room.relative_y = relative_y
        room.y
      end

      it { should be_nil }
    end

    context 'Blockを紐付けている場合' do
      subject do
        block.put_room(room)
        room.relative_x = relative_x
        room.relative_y = relative_y
        room.y
      end

      context 'Blockのx座標が0の場合' do
        it 'Roomの相対座標がそのまま絶対座標となる' do
          should eq(4)
        end
      end

      context 'Blockのx座標が>0の場合' do
        let(:b_y) { 5 }

        it 'Blockのx座標にRoomの相対座標を足しあわせたものが絶対座標となる' do
          should eq(9)
        end
      end
    end
  end

  describe '#get_all_abs_coordinate' do
    before do
      block.put_room(room)
      room.relative_x = relative_x
      room.relative_y = relative_y
    end

    subject { room.get_all_abs_coordinate }

    context 'ブロックの座標が(0,0)、相対座標が(8,4)、幅が10、高さが5の場合' do
      let(:expected_ary) do
        a = []
        (4..8).each {|y| (8..17).each {|x| a << [x, y] } }
        a
      end

      it { should eq(expected_ary) }
    end
  end

  describe '#block=' do
    subject { room.block = block }

    context '相対座標を指定していない場合' do
      it { expect{ subject }.not_to raise_error }
      it { should be_instance_of(Meiro::Block) }
    end

    context '相対座標を指定している場合' do
      let(:width)  { 5 }
      let(:height) { 5 }
      let(:b_width)  { 10 }
      let(:b_height) { 10 }

      subject do
        room.relative_x = relative_x
        room.relative_y = relative_y
        room.block = block
      end

      [
       [1, 1],
       [1, 4],
       [4, 1],
       [4, 4],
      ].each do |x, y|
        context "適切な相対座標(#{x}, #{y})が指定されている場合" do
          let(:relative_x) { x }
          let(:relative_y) { y }

          it { expect{ subject }.not_to raise_error }
          it { should be_instance_of(Meiro::Block) }
        end
      end

      [
       [0, 0],
       [4, 0],
       [5, 1],
       [0, 4],
       [4, 5],
       [5, 4],
       [9, 9],
      ].each do |x, y|
        context "不適切な相対座標(#{x}, #{y})が指定されている場合" do
          let(:relative_x) { x }
          let(:relative_y) { y }

          it { expect{ subject }.to raise_error }
        end
      end
    end
  end

  describe '#set_random_coordinate' do
    context 'Blockを紐付けていない場合' do
      subject { room.set_random_coordinate }

      it { expect{ subject }.to raise_error }
    end

    context 'Blockを紐付けている場合' do
      let(:randomizer) { Random.new(1) }

      subject do
        block.put_room(room)
        room.set_random_coordinate(randomizer)
      end

      context '乱数のseedが1, Blockの幅:60、高さ:40の場合' do
        # この条件下では必ず以下の組み合わせになる
        it { should eq([38, 13]) }
      end

      context '乱数のseedが1, Blockの幅:30、高さ:20の場合' do
        let(:b_width) { 30 }
        let(:b_height) { 20 }
        # この条件下では必ず以下の組み合わせになる
        it { should eq([6, 12]) }
      end

      context '乱数の幅がないような設定(Blockの幅:12、高さ:7)の場合' do
        let(:width) { 10 }
        let(:height) { 5 }
        let(:b_width) { 12 }
        let(:b_height) { 7 }

        it { should eq([1, 1]) }
      end
    end
  end

  describe '#available_x_max' do
    let(:width)  { 3 }
    let(:height) { 3 }
    let(:b_x) { 0 }
    let(:b_y) { 0 }
    let(:b_width) { 5 }
    let(:b_height) { 5 }

    subject do
      room.relative_x = 1
      room.relative_y = 1
      block.put_room(room)
      room.available_x_max
    end

    context 'Block幅が5、Room幅が3の場合' do
      it { should eq(1) }
    end

    context 'Block幅が6、Room幅が3の場合' do
      let(:b_width) { 6 }
      it { should eq(2) }
    end
  end

  describe '#available_y_max' do
    let(:width)  { 3 }
    let(:height) { 3 }
    let(:b_x) { 0 }
    let(:b_y) { 0 }
    let(:b_width) { 5 }
    let(:b_height) { 5 }

    subject do
      room.relative_x = 1
      room.relative_y = 1
      block.put_room(room)
      room.available_y_max
    end

    context 'Block高さが5、Room高さが3の場合' do
      it { should eq(1) }
    end

    context 'Block高さが6、Room高さが3の場合' do
      let(:b_height) { 6 }
      it { should eq(2) }
    end
  end

  describe '#each_coordinate' do
    let(:width)  { 3 }
    let(:height) { 3 }
    let(:b_x) { 0 }
    let(:b_y) { 0 }
    let(:b_width) { 5 }
    let(:b_height) { 5 }

    subject do
      room.relative_x = 1
      room.relative_y = 1
      block.put_room(room)
      sub = []
      room.each_coordinate do |x, y|
        sub << [x, y]
      end
      sub
    end

    it do
      expected = [[1, 1], [2, 1], [3, 1],
                  [1, 2], [2, 2], [3, 2],
                  [1, 3], [2, 3], [3, 3],]
      should eq(expected)
    end
  end

  describe '#generation' do
    subject { room.generation }

    context 'Blockに割り当てられていない部屋の場合' do
      it { should eq(nil) }
    end

    context 'Blockに割り当てられている部屋の場合' do
      before do
        room.relative_x = 1
        room.relative_y = 1
        block.put_room(room)
        block.should_receive(:generation).once
      end

      it { expect{ subject }.not_to raise_error }
    end
  end

  describe '#partition' do
    subject { room.partition }

    context 'Blockに割り当てられていない部屋の場合' do
      it { should eq(nil) }
    end

    context 'Blockに割り当てられている部屋の場合' do
      before do
        room.relative_x = 1
        room.relative_y = 1
        block.put_room(room)
        block.should_receive(:partition).once
      end

      it { expect{ subject }.not_to raise_error }
    end
  end

  describe '#brother' do
    subject { room.brother }

    context 'Blockに割り当てられていない部屋の場合' do
      it { should eq(nil) }
    end

    context '割り当てられているBlockが分割されたものでない場合' do
      before do
        room.relative_x = 1
        room.relative_y = 1
        block.put_room(room)
      end

      it { should eq(nil) }
    end

    context '割り当てられているBlockが分割されたものである場合' do
      let(:parent) { Meiro::Block.new(floor, b_x, b_y, b_width, b_height, nil) }
      let(:block2) { Meiro::Block.new(floor, b_x, b_y, b_width, b_height, parent) }
      let(:room2) { described_class.new(3, 3) }

      before(:each) do
        room.relative_x = 1
        room.relative_y = 1
        block.put_room(room)
        room2.relative_x = 1
        room2.relative_y = 1
        block2.put_room(room2)
      end

      context '対象の部屋がupper_leftの場合' do
        before do
          parent.instance_variable_set(:@upper_left, block)
          parent.instance_variable_set(:@lower_right, block2)
        end

        it { should eq(room2) }
      end

      context '対象の部屋がupper_leftの場合' do
        before do
          parent.instance_variable_set(:@upper_left, block2)
          parent.instance_variable_set(:@lower_right, block)
        end

        it { should eq(room2) }
      end
    end
  end

  def put_and_return_room(block)
    r = described_class.new(3, 3)
    r.relative_x, r.relative_y = 1, 1
    block.put_room(r)
    r
  end

  describe '#select_partition' do
    let(:root_block) { floor.root_block.separate; floor.root_block }

    subject { room.select_partition(other) }

    context '第2世代-第2世代' do
      # +---+---+
      # | 1 | 2 |
      # +---+---+
      let(:block_1) { root_block.upper_left }
      let(:block_2) { root_block.lower_right }
      let(:room_1) { put_and_return_room(block_1) }
      let(:room_2) { put_and_return_room(block_2) }

      context 'self:1, other:2の場合' do
        let(:room)  { room_1 }
        let(:other) { room_2 }

        it { should eq(root_block.partition) }
      end

      context 'self:2, other:1の場合' do
        let(:room)  { room_1 }
        let(:other) { room_2 }

        it { should eq(root_block.partition) }
      end
    end

    context '第3世代-第3世代' do
      # +---+---+
      # | 1 | 3 |
      # +---+---+
      # | 2 | 4 |
      # +---+---+
      let(:block_l) { root_block.upper_left.separate; root_block.upper_left }
      let(:block_r) { root_block.lower_right.separate; root_block.lower_right }
      let(:block_1) { block_l.upper_left }
      let(:block_2) { block_l.lower_right }
      let(:block_3) { block_r.upper_left }
      let(:block_4) { block_r.lower_right }
      let(:room_1) { put_and_return_room(block_1) }
      let(:room_2) { put_and_return_room(block_2) }
      let(:room_3) { put_and_return_room(block_3) }
      let(:room_4) { put_and_return_room(block_4) }

      context 'self:1, other:2の場合' do
        let(:room)  { room_1 }
        let(:other) { room_2 }

        it { should eq(block_l.partition) }
      end

      context 'self:1, other:3の場合' do
        let(:room)  { room_1 }
        let(:other) { room_3 }

        it { should eq(root_block.partition) }
      end

      context 'self:1, other:4の場合' do
        let(:room)  { room_1 }
        let(:other) { room_3 }

        it { should eq(root_block.partition) }
      end
    end

    context '第2世代-第3世代' do
      # +---+---+
      # |   | 2 |
      # | 1 +---+
      # |   | 3 |
      # +---+---+
      let(:block_1) { root_block.upper_left }
      let(:block_r) { root_block.lower_right.separate; root_block.lower_right }
      let(:block_2) { block_r.upper_left }
      let(:block_3) { block_r.lower_right }
      let(:room_1) { put_and_return_room(block_1) }
      let(:room_2) { put_and_return_room(block_2) }
      let(:room_3) { put_and_return_room(block_3) }

      context 'self:1, other:2の場合' do
        let(:room)  { room_1 }
        let(:other) { room_2 }

        it { should eq(root_block.partition) }
      end

      context 'self:1, other:3の場合' do
        let(:room)  { room_1 }
        let(:other) { room_3 }

        it { should eq(root_block.partition) }
      end
    end

    context '第2世代-第4世代' do
      # +------+---+---+
      # |      | 2 | 3 |
      # |  1   +---+---+
      # |      | 4 | 5 |
      # +------+---+---+
      let(:block_1) { root_block.upper_left }
      let(:block_r) { root_block.lower_right.separate; root_block.lower_right }
      let(:block_ru) { block_r.upper_left.separate; block_r.upper_left }
      let(:block_rl) { block_r.lower_right.separate; block_r.lower_right }
      let(:block_2) { block_ru.upper_left }
      let(:block_3) { block_ru.lower_right }
      let(:block_4) { block_rl.upper_left }
      let(:block_5) { block_rl.lower_right }
      let(:room_1) { put_and_return_room(block_1) }
      let(:room_2) { put_and_return_room(block_2) }
      let(:room_3) { put_and_return_room(block_3) }
      let(:room_4) { put_and_return_room(block_4) }
      let(:room_5) { put_and_return_room(block_5) }

      context 'self:1, other:2の場合' do
        let(:room)  { room_1 }
        let(:other) { room_2 }

        it { should eq(root_block.partition) }
      end

      context 'self:1, other:3の場合' do
        let(:room)  { room_1 }
        let(:other) { room_3 }

        it { should eq(root_block.partition) }
      end

      context 'self:1, other:4の場合' do
        let(:room)  { room_1 }
        let(:other) { room_4 }

        it { should eq(root_block.partition) }
      end

      context 'self:1, other:5の場合' do
        let(:room)  { room_1 }
        let(:other) { room_5 }

        it { should eq(root_block.partition) }
      end
    end
  end
end
