require 'spec_helper'

describe Meiro do
  let(:options) { Hash.new }

  describe '.create_dungeon' do
    subject { described_class.create_dungeon(options) }

    its(:class) { should eq(Meiro::Dungeon) }
  end

  it 'should have a version number' do
    Meiro::VERSION.should_not be_nil
  end
end
