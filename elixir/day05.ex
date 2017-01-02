defmodule NiceGameOfChess do
  def hash(door_id) do
    :crypto.hash(:md5, door_id) |> Base.encode16()
  end

  def derive_password(%{is_complete: is_complete} = params) when is_complete, do: params
  def derive_password(%{door_id: door_id, index: index, password: password, is_complete: is_complete} = _params) when not is_complete do
    case is_password_letter(door_id, index) do
      {true, password_letter} ->
        updated_password = password <> password_letter
        derive_password(%{door_id: door_id, index: index + 1, password: updated_password, is_complete: (String.length(updated_password) >= 8)})
      {false} ->
        derive_password(%{door_id: door_id, index: index + 1, password: password, is_complete: false})
    end
  end

  def is_password_letter(door_id, index) do
    md5_hash = hash(door_id <> to_string(index))
    if String.starts_with?(md5_hash, "00000") do
      {true, String.slice(md5_hash, 5, 1)}
    else
      {false}
    end
  end

  def find_password_type1(door_id) do
    derive_password(%{door_id: door_id, index: 0, password: "", is_complete: false})
  end

  def is_complete_password(password) do
    password_length = password |> String.replace(" ", "") |> String.length
    password_length == 8
  end

  def is_password_letter_of_type2(door_id, index) do
    md5_hash = hash(door_id <> to_string(index))
    starts_with_5zeros = String.starts_with?(md5_hash, "00000")
    value_char = String.slice(md5_hash, 6, 1)
    case (md5_hash |> String.slice(5, 1) |> to_integer?) do
      {:ok, index} when index >= 0 and index <= 7 and starts_with_5zeros ->
        {true, index, value_char}
      _ ->
        {false}
    end
  end

  def replace_if_empty(str, index, newchar) do
    charlist = String.graphemes(str)
    if Enum.at(charlist, index) == " " do
      new_charlist = Enum.take(charlist, index) ++ [newchar] ++ Enum.drop(charlist, index + 1)
      Enum.join(new_charlist)
    else
      str
    end
  end

  def to_integer?(str) do
    try do
      {:ok, String.to_integer(str)}
    rescue
      ArgumentError -> {:error, -1}
    end
  end

  def derive_password_type2(%{is_complete: is_complete} = params) when is_complete, do: params
  def derive_password_type2(%{door_id: door_id, index: index, password: password, is_complete: is_complete} = _params) when not is_complete do
    case is_password_letter_of_type2(door_id, index) do
      {true, position_char, value_char} ->
        updated_password = replace_if_empty(password, position_char, value_char)
        is_now_complete = is_complete_password(updated_password)
        IO.inspect(%{door_id: door_id, index: index + 1, password: updated_password, is_complete: is_now_complete})
        derive_password_type2(%{door_id: door_id, index: index + 1, password: updated_password, is_complete: is_now_complete})
      {false} ->
        derive_password_type2(%{door_id: door_id, index: index + 1, password: password, is_complete: false})
    end
  end

  def find_password_type2(door_id) do
    derive_password_type2(%{door_id: door_id, index: 0, password: "        ", is_complete: false})
  end

end
