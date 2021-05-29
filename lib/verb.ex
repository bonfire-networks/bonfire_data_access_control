defmodule Bonfire.Data.AccessControl.Verb do
  @moduledoc """
  """

  use Pointers.Pointable,
    otp_app: :bonfire_data_access_control,
    table_id: "2W0RDDESCR1B1NGD01NGTH1NGS",
    source: "bonfire_data_access_control_verb"

  alias Bonfire.Data.AccessControl.Verb
  alias Ecto.Changeset

  pointable_schema do
    field :verb, :string
  end

  # @default_opts [cast: [:verb], required: [:verb]]

  def changeset(verb \\ %Verb{}, params) do
    verb
    |> Changeset.cast(params, [:verb])
    |> Changeset.validate_required([:verb])
    |> Changeset.unique_constraint([:verb])
  end

end
defmodule Bonfire.Data.AccessControl.Verb.Migration do

  use Ecto.Migration
  import Pointers.Migration
  alias Bonfire.Data.AccessControl.Verb

  @verb_table Verb.__schema__(:source)

  # create_verb_table/{0,1}

  defp make_verb_table(exprs) do
    quote do
      require Pointers.Migration
      Pointers.Migration.create_pointable_table(Bonfire.Data.AccessControl.Verb) do
        Ecto.Migration.add :verb, :text, null: false
        unquote_splicing(exprs)
      end
    end
  end

  defmacro create_verb_table(), do: make_verb_table([])
  defmacro create_verb_table([do: {_, _, body}]), do: make_verb_table(body)

  # drop_verb_table/0

  def drop_verb_table(), do: drop_pointable_table(Verb)

  # create_verb_verb_index/{0,1}

  defp make_verb_verb_index(opts) do
    quote do
      Ecto.Migration.create_if_not_exists(
        Ecto.Migration.unique_index(unquote(@verb_table), [:verb], unquote(opts))
      )
    end
  end

  defmacro create_verb_verb_index(opts \\ [])
  defmacro create_verb_verb_index(opts), do: make_verb_verb_index(opts)

  def drop_verb_verb_index(opts \\ [])
  def drop_verb_verb_index(opts), do: drop_if_exists(unique_index(@verb_table, [:verb], opts))

  # migrate_verb/{0,1}

  defp mv(:up) do
    quote do
      unquote(make_verb_table([]))
      unquote(make_verb_verb_index([]))
    end
  end

  defp mv(:down) do
    quote do
      Bonfire.Data.AccessControl.Verb.Migration.drop_verb_verb_index()
      Bonfire.Data.AccessControl.Verb.Migration.drop_verb_table()
    end
  end

  defmacro migrate_verb() do
    quote do
      if Ecto.Migration.direction() == :up,
        do: unquote(mv(:up)),
        else: unquote(mv(:down))
    end
  end
  defmacro migrate_verb(dir), do: mv(dir)

end
