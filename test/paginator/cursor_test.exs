defmodule Paginator.CursorTest do
  use ExUnit.Case, async: true

  alias Paginator.Cursor

  defmodule MYTEST1 do
    defstruct id: nil
  end

  defmodule MYTEST2 do
    defstruct id: nil
  end

  defimpl Paginator.Cursor.Encode, for: MYTEST1 do
    def convert(term), do: {:m1, term.id}
  end

  defimpl Paginator.Cursor.Decode, for: Tuple do
    def convert({:m1, id}), do: %MYTEST1{id: id}
  end

  test "cursor for struct with custom implementation is shorter" do
    cursor1 = Cursor.encode(%{v1: %MYTEST1{id: 1}})

    assert Cursor.decode(cursor1) == %{v1: %MYTEST1{id: 1}}

    cursor2 = Cursor.encode(%{v1: %MYTEST2{id: 1}})

    assert Cursor.decode(cursor2) == %{v1: %MYTEST2{id: 1}}
    assert bit_size(cursor1) < bit_size(cursor2)
  end

  describe "encoding and decoding terms" do
    test "it encodes and decodes map cursors" do
      cursor = Cursor.encode(%{a: 1, b: 2})

      assert Cursor.decode(cursor) == %{a: 1, b: 2}
    end
  end

  describe "Cursor.decode/1" do
    test "it safely decodes user input" do
      assert_raise ArgumentError, fn ->
        # this binary represents the atom :fubar_0a1b2c3d4e
        <<131, 100, 0, 16, "fubar_0a1b2c3d4e">>
        |> Base.url_encode64()
        |> Cursor.decode()
      end
    end
  end
end
