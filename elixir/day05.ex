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

  def find_password(door_id) do
    derive_password(%{door_id: door_id, index: 0, password: "", is_complete: false})
  end
end
