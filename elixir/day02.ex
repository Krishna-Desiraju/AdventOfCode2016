defmodule KeyFinder do
  def move(%{:dx => dx, :dy => dy}, %{:x => x, :y => y}, %{keypad_type: keypad_type}) do
    key_search_result = %{x: x + dx, y: y + dy} |> find_key(%{keypad_type: keypad_type})
    case key_search_result do
      {:ok, _key_value} ->
        %{x: x + dx, y: y + dy}
      :error ->
        %{:x => x, :y => y}
    end
  end

  def get_keypad_map(%{keypad_type: keypad_type}) when keypad_type == :keypad_square_type do
    %{
       1 => %{ -1 => 1, 0 => 2, 1 => 3},
       0 => %{ -1 => 4, 0 => 5, 1 => 6},
      -1 => %{ -1 => 7, 0 => 8, 1 => 9},
    }
  end

  def get_keypad_map(%{keypad_type: keypad_type}) when keypad_type == :keypad_rhombus_type do
    %{
       2 => %{ 0 => "1"},
       1 => %{ -1 => "2", 0 => "3", 1 => "4"},
       0 => %{ -2 => "5", -1 => "6", 0 => "7", 1 => "8", 2 => "9"},
      -1 => %{ -1 => "A", 0 => "B", 1 => "C"},
      -2 => %{ 0 => "D"},

    }
  end

  def find_key(%{:x => x, :y => y} = _position, %{keypad_type: keypad_type}) do
    key_pad = get_keypad_map(%{keypad_type: keypad_type})

    with  {:ok, y_column} <- Map.fetch(key_pad, y),
          {:ok, yx_value} <- Map.fetch(y_column, x),
      do: {:ok, yx_value}
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

  def parse_line(line, %{:x => a, :y => b} = _start_position, %{keypad_type: keypad_type}) do
    line
    |> String.replace(" ", "")
    |> String.upcase
    |> String.graphemes
    |> Enum.map(fn x -> x |> String.to_atom() end)
    |> Enum.map(fn x -> map_moves_to_co_ordinates(%{:movement => x}) end)
    |> Enum.reduce(%{:x => a, :y => b}, fn(elem, acc) -> move(elem, acc, %{keypad_type: keypad_type}) end)
  end

  def parse_lines(%{filetext: lines, keypad_type: keypad_type, start_position: %{:x => x1, :y => y1}}) do
    lines
    |> String.split("\r\n")
    |> Enum.scan(%{:x => x1, :y => y1}, fn(elem, acc) -> parse_line(elem, acc, %{keypad_type: keypad_type}) end)
    |> Enum.map(fn x ->
                  {:ok, keypad_value} = find_key(x, %{keypad_type: keypad_type})
                  keypad_value |> to_string
                end)
    |> Enum.join()
  end

  def parse_file(%{file_path: file_path, keypad_type: keypad_type, start_position: %{:x => x1, :y => y1}}) do
    filetext = file_path |> File.read!
    parse_lines(%{filetext: filetext, keypad_type: keypad_type, start_position: %{:x => x1, :y => y1}})
  end

  def part1_input1_answer do
    (%{file_path: "day02_input1.txt", keypad_type: :keypad_square_type, start_position: %{:x => 0, :y => 0}}) |> parse_file
  end

  def part1_input2_answer do
    (%{file_path: "day02_input2.txt", keypad_type: :keypad_square_type, start_position: %{:x => 0, :y => 0}}) |> parse_file
  end

  def part2_input1_answer do
    %{file_path: "day02_input1.txt", keypad_type: :keypad_rhombus_type, start_position: %{:x => -2, :y => 0}} |> parse_file
  end

  def part2_input2_answer do
    %{file_path: "day02_input2.txt", keypad_type: :keypad_rhombus_type, start_position: %{:x => -2, :y => 0}} |> parse_file
  end
end
