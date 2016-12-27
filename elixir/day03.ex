defmodule TriangleValidator do
  def validate(%{:a => a, :b => b, :c => c}) when (a + b > c) and (b + c > a) and (c + a > b), do: true
  def validate(%{:a => _a, :b => _b, :c => _c}) , do: false

  def parse_line_to_triangle(line) do
    [a, b, c] = line |> String.split(" ", trim: true) |> Enum.map(&(&1 |> String.to_integer()))
    %{:a => a, :b => b, :c => c}
  end

  def parse_lines(lines) do
    lines
    |> String.split("\n")
    |> Enum.map(fn x -> parse_line_to_triangle(x) end)
    |> Enum.map(fn x -> validate(x) end)
    |> Enum.filter(&(&1))
    |> Enum.map(fn _ -> 1 end)
    |> Enum.sum
  end

  def parse_file(file_path) do
    file_path |> File.read! |> parse_lines
  end

end
