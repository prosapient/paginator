defmodule Paginator.Cursor do
  @moduledoc false

  def decode(nil), do: nil

  def decode(encoded_cursor) do
    encoded_cursor
    |> Base.url_decode64!()
    |> Plug.Crypto.non_executable_binary_to_term([:safe])
    |> case do
      map when is_map(map) ->
        map |> Map.new(fn {key, value} -> {key, Paginator.Cursor.Decode.convert(value)} end)

      legacy when is_list(legacy) ->
        legacy |> Enum.map(&Paginator.Cursor.Decode.convert/1)
    end
  end

  def encode(values) when is_map(values) do
    values
    |> Map.new(fn {key, value} -> {key, Paginator.Cursor.Encode.convert(value)} end)
    |> :erlang.term_to_binary()
    |> Base.url_encode64()
  end
end

defprotocol Paginator.Cursor.Encode do
  @fallback_to_any true

  def convert(term)
end

defprotocol Paginator.Cursor.Decode do
  @fallback_to_any true

  def convert(term)
end

defimpl Paginator.Cursor.Encode, for: Any do
  def convert(term), do: term
end

defimpl Paginator.Cursor.Decode, for: Any do
  def convert(term), do: term
end
