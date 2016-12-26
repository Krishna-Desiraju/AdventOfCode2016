defmodule KeyFinder do
  def move(%{:dx => dx, :dy => dy}, %{:x => x, :y => y}) when abs(x + dx) <= 1 and abs(y + dy) <= 1, do: %{:x => x + dx, :y => y + dy}
  def move(_, current_co_ordinates), do: current_co_ordinates

  def find_key_at_the_position(%{:x => x, :y => y} = _position) do
    key_pad = %{
       1 => %{ -1 => 1, 0 => 2, 1 => 3},
       0 => %{ -1 => 4, 0 => 5, 1 => 6},
      -1 => %{ -1 => 7, 0 => 8, 1 => 9},
    }
    key_pad[y][x]
  end

  def map_moves_to_co_ordinates(%{:movement => movement}) do
    movement_map = %{
      :U => %{:dx => 0, :dy => 1},
      :D => %{:dx => 0, :dy => -1},
      :L => %{:dx => -1, :dy => 0},
      :R => %{:dx => 1, :dy => 0}
    }
    movement_map[movement]
  end

  def parse_line(line, %{:x => a, :y => b} = _start_position) do
    line
    |> String.replace(" ", "")
    |> String.upcase
    |> String.graphemes
    |> Enum.map(fn x -> x |> String.to_atom() end)
    |> Enum.map(fn x -> map_moves_to_co_ordinates(%{:movement => x}) end)
    |> Enum.reduce(%{:x => a, :y => b}, fn(elem, acc) -> move(elem, acc) end)
    #|> find_key_at_the_position
    #|> to_string
  end

  def parse_lines(lines) do
    lines
    |> String.split("\n")
    |> Enum.scan(%{:x => 0, :y => 0}, fn(elem, acc) -> parse_line(elem, acc) end)
    |> Enum.map(&(&1 |> find_key_at_the_position() |> to_string()))
    |> Enum.join()
  end
end
