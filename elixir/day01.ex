defmodule CoOrdinateFinder do
  def parse_to_instruction_list(str) do
    str
      |> String.replace(" ", "")
      |> String.upcase
      |> String.split(",")
      |> Enum.map(&(&1 |> parse_instruction))
      |> Enum.reduce(%{:x => 0, :y => 0, :direction => :N}, fn(elem, acc) -> reduce_instruction(elem, acc) end)
      |> calc_total_blocks
  end

  def parse_instruction(instruction) do
    left_or_right = instruction |> String.slice(0,1)
    magnitude = instruction |> String.slice(1, String.length(instruction))
    %{:left_or_right => left_or_right |> String.to_atom, :magnitude => magnitude |> String.to_integer}
  end

  def reduce_instruction(%{:left_or_right => left_or_right, :magnitude => magnitude} = _elem, %{:x => x, :y => y, :direction => current_direction} = _acc) do
    directions = %{
        {:N, :R} => :E,
        {:N, :L} => :W,
        {:S, :R} => :W,
        {:S, :L} => :E,
        {:E, :R} => :S,
        {:E, :L} => :N,
        {:W, :R} => :N,
        {:W, :L} => :S
      }

    co_ordinates = %{
        :N => %{dx: 0, dy: 1},
        :S => %{dx: 0, dy: -1},
        :E => %{dx: 1, dy: 0},
        :W => %{dx: -1, dy: 0},
      }

    next_direction = directions[{current_direction, left_or_right}]
    %{dx: dx, dy: dy} = co_ordinates[next_direction]
    %{:x => x + (dx * magnitude), :y => y + (dy * magnitude), :direction => next_direction}
  end

  def calc_total_blocks(%{:x => x, :y => y}) do
    abs(x) + abs(y)
  end

end
