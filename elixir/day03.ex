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
    |> length
  end

  def parse_file(file_path) do
    file_path |> File.read! |> parse_as_vertical_triangles
  end

  def find_vertical_triangle_triplet(index, indexed_map) when rem(index,3) == 1 do
    %{a: a1, b: b1, c: c1} = indexed_map[index]
    %{a: a2, b: b2, c: c2} = indexed_map[index + 1]
    %{a: a3, b: b3, c: c3} = indexed_map[index + 2]
    [ %{a: a1, b: a2, c: a3},
      %{a: b1, b: b2, c: b3},
      %{a: c1, b: c2, c: c3}]
  end
  def find_vertical_triangle_triplet(_index, _indexed_map), do: []

  def parse_as_vertical_triangles(lines) do
    h_triangles =
      lines
      |> String.split("\n")
      |> Enum.map(fn x -> x |> parse_line_to_triangle end)

    keyword_list =
      1..length(h_triangles)
      |> Enum.to_list
      |> Enum.zip(h_triangles)
      |> Enum.into(%{})

    keyword_list
    |> Enum.map(fn {index, _triplet} -> find_vertical_triangle_triplet(index, keyword_list) end)
    |> List.flatten
    |> Enum.map(fn x -> validate(x) end)
    |> Enum.filter(&(&1))
    |> length
  end
end
