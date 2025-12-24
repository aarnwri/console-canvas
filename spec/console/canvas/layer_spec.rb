# frozen_string_literal: true

RSpec.describe Console::Canvas::Layer do
  subject(:layer) { described_class.new }
  public_methods = %w[
    grid def_char size_x size_y empty? insert_str sufficient_for_str? expand_for_str
    add_row add_col merge! sufficient_for_layer? expand_for_layer render
  ]
  public_methods.each { |method| it { is_expected.to respond_to(method) } }

  describe "initialization" do
    it "uses sensible defaults" do
      expect(layer.instance_variable_get(:@grid).count).to eq(0)
      expect(layer.instance_variable_get(:@def_char)).to eq(" ")
    end
    it "raises an error if the given x or y value is not an integer" do
      expect { described_class.new(3.4, 2) }.to raise_error(ArgumentError)
      expect { described_class.new(2, 3.4) }.to raise_error(ArgumentError)
    end
    it "raises an error if the given default char is not a char" do
      expect { described_class.new(0, 0, 5) }.to raise_error(ArgumentError)
      expect { described_class.new(0, 0, "testing") }.to raise_error(ArgumentError)
    end
    it "sets up the grid with the default char" do
      layer = described_class.new(1, 1, "j")
      expect(layer.instance_variable_get(:@grid)[0][0]).to eq("j")
    end
  end

  describe "#size_x" do
    let(:layer) { described_class.new(2, 1) }
    it "returns the size of the grid in the x direction" do
      expect(layer.size_x).to eq(2)
    end
    context "when grid is empty (nothing in the y direction)" do
      let(:layer) { described_class.new }
      it "does not error out, but returns 0" do
        expect(layer.size_x).to eq(0)
      end
    end
  end

  describe "#size_y" do
    let(:layer) { described_class.new(2, 1) }
    it "returns the size of the grid in the y direction" do
      expect(layer.size_y).to eq(1)
    end
  end

  describe "#empty?" do
    context "with an empty grid" do
      let(:layer) { described_class.new }
      it "returns true" do
        expect(layer.empty?).to be true
      end
    end
    context "with a non-empty grid" do
      let(:layer) { described_class.new(2, 1) }
      it "returns false" do
        expect(layer.empty?).to be false
      end
    end
  end

  describe "#insert_str(str, loc = Console::Canvas::Loc.new)" do
    context "when the layer is big enough" do
      let(:layer) { described_class.new(6, 1) }
      let(:str) { "fooey" }
      it "inserts the given string into the grid at the given location" do
        layer.insert_str(str, Console::Canvas::Loc.new(1, 0))
        expect(layer.instance_variable_get(:@grid)).to eq([[" ", "f", "o", "o", "e", "y"]])
      end
    end
    context "when the layer is not big enough" do
      let(:layer) { described_class.new(4, 1) }
      let(:str) { "fooey" }
      it "expands the layer, and then inserts the string as normal" do
        layer.insert_str(str, Console::Canvas::Loc.new(1, 0))
        expect(layer.instance_variable_get(:@grid)).to eq([[" ", "f", "o", "o", "e", "y"]])
      end
    end
    context "when the layer is not big enough in the y direction" do
      let(:layer) { described_class.new(4, 1) }
      let(:str) { "fooey" }
      it "expands the layer, and then inserts the string as normal" do
        layer.insert_str(str, Console::Canvas::Loc.new(1, 1))
        expect(layer.instance_variable_get(:@grid)).to eq([
          [" ", " ", " ", " ", " ", " "],
          [" ", "f", "o", "o", "e", "y"]
        ])
      end
    end
  end

  describe "#sufficient_for_str?" do
    context "when layer is big enough for string at location" do
      let(:layer) { described_class.new(2, 1) }
      let(:str) { "fo" }
      it "returns true" do
        expect(layer.sufficient_for_str?(str)).to be true
      end
    end
    context "when layer is not big enough for string at location" do
      let(:layer) { described_class.new(2, 1) }
      let(:str) { "fooey" }
      it "returns false" do
        expect(layer.sufficient_for_str?(str)).to be false
      end
    end
  end

  describe "#expand_for_str" do
    context "when layer is too small in the x direction" do
      let(:layer) { described_class.new(2, 1) }
      let(:str) { "fooey" }
      it "expands the grid in the x direction" do
        layer.expand_for_str(str, Console::Canvas::Loc.new(1, 0))
        grid = layer.instance_variable_get(:@grid)
        expect(grid[0].length).to eq(6)
        expect(grid.length).to eq(1)
      end
    end
    context "when layer is too small in the y direction" do
      let(:layer) { described_class.new(2, 1) }
      let(:str) { "fooey" }
      it "expands the grid in the y direction" do
        layer.expand_for_str(str, Console::Canvas::Loc.new(1, 1))
        grid = layer.instance_variable_get(:@grid)
        expect(grid[0].length).to eq(6)
        expect(grid.length).to eq(2)
        expect(grid[0]).to eq([" ", " ", " ", " ", " ", " "])
        expect(grid[1]).to eq([" ", " ", " ", " ", " ", " "])
      end
    end
    context "when the given location is off the screen" do
      let(:off_screen_loc) { Console::Canvas::Loc.new(1000, 1) }
      it "raises an error indicating that the location is off the screen" do
        expect { layer.expand_for_str("fooey", off_screen_loc) }.to raise_error(Console::Canvas::Error, /location off screen/)
      end
    end
  end

  describe "#add_row" do
    it "defaults to one row" do
      layer.add_row
      expect(layer.instance_variable_get(:@grid).count).to eq(1)
    end
    it "adds the number of rows specified" do
      layer.add_row(2)
      expect(layer.instance_variable_get(:@grid).count).to eq(2)
    end
    context "when the width of the rows is greater than 0" do
      let(:layer) { described_class.new(2, 1) }

      it "adds the row such that it is the same width as all the other rows" do
        layer.add_row
        grid = layer.instance_variable_get(:@grid)
        expect(grid.last.count).to eq(grid.first.count)
      end
    end
  end

  describe "#add_col" do
    it "defaults to one column" do
      # NOTE: We have to add a row first, otherwise, there is nothing to add
      # a column to...
      layer.add_row
      layer.add_col
      expect(layer.instance_variable_get(:@grid)[0].count).to eq(1)
    end
    it "adds the number of columns specified to each exesting row" do
      layer.add_row(2)
      layer.add_col(2)
      expect(layer.instance_variable_get(:@grid)[0].count).to eq(2)
      expect(layer.instance_variable_get(:@grid)[1].count).to eq(2)
    end
  end

  describe "#merge!" do
    context "with an existing grid of [['a', 'b', 'c']]" do
      let(:layer_1) do
        layer = described_class.new
        layer.insert_str("abc")
        layer
      end
      context "and a merge grid of [[' ', 'd', ' ']]" do
        let(:layer_2) do
          layer = described_class.new(3, 0)
          layer.insert_str("d", Console::Canvas::Loc.new(1, 0))
          layer
        end
        it "updates the existing grid to be [['a', 'd', 'c']]" do
          layer_1.merge!(layer_2)
          expect(layer_1.instance_variable_get(:@grid)).to eq([["a", "d", "c"]])
        end
      end
      context "and a merge grid of [[' ', 'd'], ['e', 'f']]" do
        let(:layer_2) do
          layer = described_class.new(2, 0)
          layer.insert_str("d", Console::Canvas::Loc.new(1, 0))
          layer.insert_str("ef", Console::Canvas::Loc.new(0, 1))
          layer
        end
        context "and a merge location of (1, 0)" do
          let(:loc) { Console::Canvas::Loc.new(1, 0) }
          it "updates the existing grid to be [['a', 'b', 'd'], [' ', 'e', 'f']]" do
            layer_1.merge!(layer_2, loc)
            grid = layer_1.instance_variable_get(:@grid)
            expect(grid[0]).to eq(["a", "b", "d"])
            expect(grid[1]).to eq([" ", "e", "f"])
          end
        end
      end
    end
  end

  describe "#sufficient_for_layer?" do
    context "when layer is big enough for other layer at location" do
      let(:layer) { described_class.new(2, 1) }
      let(:other) { described_class.new(2, 1) }
      it "returns true" do
        expect(layer.sufficient_for_layer?(other)).to be true
      end
    end
    context "when layer is not big enough for other layer at location in x dir" do
      let(:layer) { described_class.new(2, 1) }
      let(:other) { described_class.new(2, 1) }
      let(:other_loc) { Console::Canvas::Loc.new(1, 0) }
      it "returns false" do
        expect(layer.sufficient_for_layer?(other, other_loc)).to be false
      end
    end
    context "when layer is not big enough for other layer at location in y dir" do
      let(:layer) { described_class.new(2, 1) }
      let(:other) { described_class.new(1, 1) }
      let(:other_loc) { Console::Canvas::Loc.new(0, 1) }
      it "returns false" do
        expect(layer.sufficient_for_layer?(other, other_loc)).to be false
      end
    end
  end

  describe "#expand_for_layer" do
    context "when layer is too small in the x direction" do
      let(:layer) { described_class.new(2, 2) }
      let(:other) { described_class.new(2, 1) }
      let(:other_loc) { Console::Canvas::Loc.new(1, 0) }
      it "expands the grid in the x direction" do
        layer.expand_for_layer(other, other_loc)
        grid = layer.instance_variable_get(:@grid)
        expect(grid[0].length).to eq(3)
        expect(grid.length).to eq(2)
        expect(grid[0]).to eq([" ", " ", " "])
        expect(grid[1]).to eq([" ", " ", " "])
      end
    end
    context "when layer is too small in the y direction" do
      let(:layer) { described_class.new(2, 1) }
      let(:other) { described_class.new(2, 2) }
      let(:other_loc) { Console::Canvas::Loc.new(0, 1) }
      it "expands the grid in the y direction" do
        layer.expand_for_layer(other, other_loc)
        grid = layer.instance_variable_get(:@grid)
        expect(grid[0].length).to eq(2)
        expect(grid.length).to eq(3)
        expect(grid[0]).to eq([" ", " "])
        expect(grid[1]).to eq([" ", " "])
        expect(grid[2]).to eq([" ", " "])
      end
    end
    context "when the given location is off the screen" do
      let(:layer) { described_class.new(2, 1) }
      let(:other) { described_class.new(2, 1) }
      let(:other_loc) { Console::Canvas::Loc.new(1000, 1) }
      it "raises an error indicating that the location is off the screen" do
        expect { layer.expand_for_layer(other, other_loc) }.to raise_error(Console::Canvas::Error, /location off screen/)
      end
    end
    context "when the given layer pushes the location off the screen" do
      let(:layer) { described_class.new(2, 1) }
      let(:other) { described_class.new(1000, 1) }
      let(:other_loc) { Console::Canvas::Loc.new }
      it "raises an error indicating that the location is off the screen" do
        expect { layer.expand_for_layer(other, other_loc) }.to raise_error(Console::Canvas::Error, /location off screen/)
      end
    end
  end

  describe "#render" do
    let(:layer) { described_class.new(2, 1) }
    before { layer.insert_str("testing") }
    it "outputs content to the conosle" do
      expect { layer.render }.to output(/testing/).to_stdout
    end
  end
end
