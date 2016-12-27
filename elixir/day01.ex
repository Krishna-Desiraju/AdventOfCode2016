defmodule CoOrdinateFinder do
  def parse_command(instruction) do
    left_or_right = instruction |> String.slice(0,1)
    magnitude = instruction |> String.slice(1, String.length(instruction))
    %{:left_or_right => left_or_right |> String.to_atom, :magnitude => magnitude |> String.to_integer}
  end

  def move(%{:left_or_right => left_or_right, :magnitude => magnitude} = _elem, %{:x => x, :y => y, :direction => current_direction, :cmd_no => cmd_no, :steps => _steps} = _acc) do
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
    next_steps = 1..magnitude |> Enum.to_list |> Enum.scan(%{:x => x, :y => y}, fn(_elem, %{:x => a, :y => b}) -> %{:x => a + dx, :y => b + dy} end)
    %{:x => x + (dx * magnitude), :y => y + (dy * magnitude), :direction => next_direction, :cmd_no => cmd_no + 1, :steps => next_steps}
  end

  def parse_commands(command_string) do
    command_string
    |> String.replace(" ", "")
    |> String.upcase
    |> String.split(",")
    |> Enum.map(&(&1 |> parse_command))
    |> Enum.scan(%{:x => 0, :y => 0, :direction => :N, :cmd_no => 0, :steps => []}, fn(elem, acc) -> move(elem, acc) end)
  end

  def calc_total_blocks(%{:x => x, :y => y}) do
    abs(x) + abs(y)
  end

  def calc_total_blocks(command_string) do
    command_string
    |> parse_commands
    |> Enum.take(-1)
    |> Enum.fetch!(0)
    |> calc_total_blocks
  end

  def find_first_retravel_point(command_string) do
    command_string
    |> parse_commands
    |> Enum.map(fn pos -> pos[:steps] |> Enum.map(fn step -> %{x: step[:x], y: step[:y], cmd_no: pos[:cmd_no]} end) end)
    |> List.flatten
    |> Enum.group_by(fn step -> %{x: step[:x], y: step[:y]} end)
    |> Enum.filter(fn {_k, v} -> Enum.count(v) > 1 end)
    |> Enum.map(fn {k, v} -> %{x: k[:x], y: k[:y], first_cmd_no: (Enum.min_by(v, fn elem -> elem[:cmd_no] end))[:cmd_no]} end)
    |> Enum.min_by(fn pos -> pos[:first_cmd_no] end)
    |> calc_total_blocks
  end

end
