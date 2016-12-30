defmodule SecurityThroughObsurity do
  def derive_check_sum(encrypted_name) do
    encrypted_name
    |> String.replace("-", "")
    |> String.graphemes
    |> Enum.group_by(fn char -> char end)
    |> Enum.map(fn {k,v} -> {k, length(v)} end)
    |> Enum.sort_by(fn {_k,v} -> v end, &>=/2)
    |> Enum.take(5)
    |> Enum.map(fn {k,_v} -> k end)
    |> Enum.join
  end

  def check_if_real_room(derived_check_sum, given_check_sum) do
    derived_check_sum == given_check_sum
  end

  def parse_room_name(room_name) do
    matches = Regex.run(~r/^(([a-z]+\-)+)(\d+)(\[)([a-z]+)(\])$/, room_name)
    %{encrypted_name: Enum.at(matches, 1), sector_id: String.to_integer(Enum.at(matches, 3)), check_sum: Enum.at(matches, 5)}
  end

  def calc_real_room_sector_ids_sum(file_path) do
    file_path
    |> File.read!
    |> String.split("\r\n")
    |> Enum.map(&parse_room_name/1)
    |> Enum.filter(fn %{encrypted_name: encrypted_name, check_sum: check_sum} -> check_if_real_room(derive_check_sum(encrypted_name), check_sum) end)
    |> Enum.reduce(0, fn (%{sector_id: sector_id}, acc) -> acc + sector_id end)
  end

  def decrypt_shift_cipher(encrypted_name, shift) do
    alphabet = "abcdefghijklmnopqrstuvwxyz" |> String.graphemes
    modulus_shift = rem(shift,26)
    shifted_alphabet = Enum.drop(alphabet, modulus_shift) ++ Enum.take(alphabet, modulus_shift)
    cipher_map = Enum.zip(alphabet, shifted_alphabet) |> Enum.into(%{}) |> Map.merge(%{"-" => " "})
    encrypted_name
    |> String.graphemes
    |> Enum.map(fn char -> cipher_map[char] end)
    |> Enum.join
  end

  def print_decrypted_room_names(file_path) do
    real_names =
    file_path
    |> File.read!
    |> String.split("\r\n")
    |> Enum.map(&parse_room_name/1)
    |> Enum.map(fn %{encrypted_name: encrypted_name, sector_id: sector_id} -> {decrypt_shift_cipher(encrypted_name, sector_id), sector_id} end)
    |> Enum.map(fn {k,v} -> "#{k} --- #{v}\r\n" end)
    |> Enum.join()

    File.write!("day04_output2.txt", real_names)
  end
end
