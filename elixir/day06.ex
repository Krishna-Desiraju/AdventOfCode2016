defmodule SignalsAndNoise do
  def parse_file(file_path) do
    file_path
    |> File.read!
    |> String.split("\r\n")
    |> Enum.map(&String.graphemes/1)
  end

  def decipher(file_path) do
    list_of_char_list = parse_file(file_path)
    length_of_any_word = list_of_char_list |> Enum.at(0) |> Enum.count
    list_of_char_list
    |> Enum.reduce(Enum.map(1..length_of_any_word, fn _ -> [] end), fn (elem, acc) -> acc |> Enum.zip(elem) |> Enum.map(fn {a, b} -> a ++ [b] end ) end)
    |> Enum.map(&find_most_repeated_char/1)
    |> Enum.join
  end

  def find_most_repeated_char(list) do
    list
    |> Enum.group_by(&(&1))
    |> Enum.map(fn {k, v} -> {k, Enum.count(v)} end)
    |> Enum.sort_by(fn {_k, v} -> v end, &<=/2)
    |> Enum.map(fn {k, _} -> k end)
    |> Enum.at(0)
  end
end
