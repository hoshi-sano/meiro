require 'spec_helper'

describe Meiro::Dungeon do
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

  describe '.new' do
    subject { described_class.new(options) }

    shared_examples '.new' do
      its(:class) { should eq(described_class) }
      its(:width)  { should eq(width) }
      its(:height) { should eq(height) }
      its(:min_room_number) { should eq(min_room_number) }
      its(:max_room_number) { should eq(max_room_number) }
      its(:min_room_width)  { should eq(min_room_width) }
      its(:min_room_height) { should eq(min_room_height) }
      its(:max_room_width)  { should eq(max_room_width) }
      its(:max_room_height) { should eq(max_room_height) }
      its(:block_split_factor) { should eq(block_split_factor) }
    end

    context 'オプション指定なしの場合(デフォルト値)' do
      let(:options) { Hash.new }

      include_examples '.new'
    end

    context 'オプション指定ありの場合' do
      let(:width) { 10 }
      let(:height) { 10 }
      let(:min_room_number) { 2 }
      let(:max_room_number) { 5 }
      let(:min_room_width) { 10 }
      let(:min_room_height) { 10 }
      let(:max_room_width) { 30 }
      let(:max_room_height) { 30 }
      let(:block_split_factor) { 0.5 }

      include_examples '.new'
    end

    [
     [:width,  '60'],
     [:height, '40'],
     [:min_room_number, '1'],
     [:max_room_number, '6'],
     [:min_room_width,  '8'],
     [:min_room_height, '6'],
     [:max_room_width,  '20'],
     [:max_room_height, '20'],
     [:block_split_factor, 1],
    ].each do |key, value|
      context "#{key}に不正なクラス(#{value.class})のオプションを指定した場合" do
        let(:options) { {key => value} }

        it { expect { subject }.to raise_error }
      end
    end

    [
     [:width,  4],
     [:height, 4],
     [:min_room_number, 0],
     [:min_room_width,  2],
     [:min_room_height, 2],
     [:block_split_factor, 0.0],
    ].each do |key, value|
      context "#{key}に下限以下の値(#{value})を指定したの場合" do
        let(:options) { {key => value} }

        it { expect { subject }.to raise_error }
      end
    end

    context "max_room_numberにmin_room_number以下の値を指定したの場合" do
      let(:min_room_number) { 5 }
      let(:max_room_number) { 4 }

      it { expect { subject }.to raise_error }
    end

    context "max_room_widthにmin_room_width以下の値を指定したの場合" do
      let(:min_room_width) { 20 }
      let(:max_room_width) { 15 }

      it { expect { subject }.to raise_error }
    end

    context "max_room_heightにmin_room_height以下の値を指定したの場合" do
      let(:min_room_height) { 20 }
      let(:max_room_height) { 15 }

      it { expect { subject }.to raise_error }
    end
  end

  describe '#create_floor' do
    before do
      args = [dungeon, width, height,
              min_room_width, min_room_height,
              max_room_width, max_room_height]
      Meiro::Floor.should_receive(:new).once.with(*args)
    end

    let(:dungeon) { described_class.new(options) }

    subject { dungeon.create_floor }

    it 'Meiro::Floor.newをcallする' do
      expect { subject }.not_to raise_error
    end
  end

  describe '#generate_random_floor' do
    before do
      randomizer = dungeon.instance_variable_get(:@randomizer)
      args = [min_room_number, max_room_number,
              block_split_factor, randomizer]
      Meiro::Floor.any_instance.
        should_receive(:generate_random_room).once.with(*args)
    end

    let(:dungeon) { described_class.new(options) }

    subject { dungeon.generate_random_floor }

    it 'Meiro::Floorのインスタンスに対しgenerate_random_roomをcallする' do
      expect { subject }.not_to raise_error
    end
  end
end
