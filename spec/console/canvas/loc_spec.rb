# frozen_string_literal: true

RSpec.describe Console::Canvas::Loc do
  subject(:loc) { described_class.new(0, 0) }
  it { is_expected.to respond_to(:x) }
  it { is_expected.to respond_to(:y) }
  it { is_expected.to respond_to(:move) }
  it { is_expected.to respond_to(:move!) }

  describe "initialization" do
    it "raises an error if the given x or y value is not an integer" do
      expect { described_class.new(3.4, 2) }.to raise_error(ArgumentError)
      expect { described_class.new(2, 3.4) }.to raise_error(ArgumentError)
    end
  end

  describe "#move(v_x, v_y)" do
    loc = described_class.new(4, 3)
    it "returns a new loc with the given vector added to the old loc" do
      loc_2 = loc.move(-2, 3)
      expect(loc_2.x).to eq(2)
      expect(loc_2.y).to eq(6)
    end
    it "does not modify the current loc" do
      loc.move(-2, 3)
      expect(loc.x).to eq(4)
      expect(loc.y).to eq(3)
    end
    it "raises an error if the given v_x or v_y value is not an integer" do
      expect { loc.move(3.4, 2) }.to raise_error(ArgumentError)
      expect { loc.move(2, 3.4) }.to raise_error(ArgumentError)
    end
  end

  describe "#move!(v_x, v_y)" do
    loc = described_class.new(4, 3)
    it "moves x, y according to the given vector" do
      loc.move!(-2, 3)
      expect(loc.x).to eq(2)
      expect(loc.y).to eq(6)
    end
    it "raises an error if the given v_x or v_y value is not an integer" do
      expect { loc.move!(3.4, 2) }.to raise_error(ArgumentError)
      expect { loc.move!(2, 3.4) }.to raise_error(ArgumentError)
    end
  end
end
