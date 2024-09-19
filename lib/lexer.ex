defmodule Db.Lexer do
  alias Regex

  @spec lex(String.t()) :: list
  def lex(input) do
    ident_re = ~r(^[a-zA-Z][a-zA-Z0-9]\w*)
    number_re = ~r(^[0-9]+)
    string_re = ~r/^"(?:[^"\\]|\\.)*"/
    space_re = ~r(^[ \h\n]+)

    cond do
      input == "" ->
        []

      Regex.match?(space_re, input) ->
        lex(Regex.replace(space_re, input, "", global: false))

      Regex.match?(number_re, input) ->
        num = String.to_integer(List.first(Regex.run(number_re, input, [{:capture, :first}])))

        [{:number, num} | lex(Regex.replace(number_re, input, "", global: false))]

      Regex.match?(string_re, input) ->
        string = List.first(Regex.run(string_re, input, [{:capture, :first}]))
        actual_string = String.slice(string, 1, String.length(string) - 2)

        [{:string, actual_string} | lex(Regex.replace(string_re, input, "", global: false))]

      Regex.match?(ident_re, input) ->
        id = List.first(Regex.run(ident_re, input, [{:capture, :first}]))
        rest = lex(Regex.replace(ident_re, input, "", global: false))

        case id do
          "BEGIN" -> [:begin | rest]
          "COMMIT" -> [:commit | rest]
          "ROLLBACK" -> [:rollback | rest]
          "SET" -> [:set | rest]
          "GET" -> [:get | rest]
          "TRUE" -> [true | rest]
          "FALSE" -> [false | rest]
          _ -> [{:ident, id} | rest]
        end

      true ->
        raise "Syntax error #{input}"
    end
  end
end
