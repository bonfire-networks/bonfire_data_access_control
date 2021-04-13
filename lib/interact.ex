defmodule Bonfire.Data.AccessControl.Interact do
  @moduledoc """
  """

  use Pointers.Pointable,
    otp_app: :bonfire_data_access_control,
    table_id: "M0RETHANJVSTREAD0N1YACCESS",
    source: "bonfire_data_access_control_interact"

  alias Bonfire.Data.AccessControl.{Access, Interact, Verb}
  alias Ecto.Changeset
  # alias Pointers.Pointer

  pointable_schema do
    belongs_to :access, Access
    belongs_to :verb, Verb
    field :value, :boolean
  end

  @cast     [:access_id, :verb_id, :value]
  @required [:access_id, :verb_id, :value]
  def changeset(interact \\ %Interact{}, params) do
    interact
    |> Changeset.cast(params, @cast)
    |> Changeset.validate_required(@required)
    |> Changeset.assoc_constraint(:access)
    |> Changeset.assoc_constraint(:verb)
  end

end
defmodule Bonfire.Data.AccessControl.Interact.Migration do

  use Ecto.Migration
  import Pointers.Migration
  alias Bonfire.Data.AccessControl.Interact

  @interact_table Interact.__schema__(:source)
  @unique_index [:access_id, :verb_id]

  # create_interact_table/{0,1}

  defp make_interact_table(exprs) do
    quote do
      require Pointers.Migration
      Pointers.Migration.create_pointable_table(Bonfire.Data.AccessControl.Interact) do
        Ecto.Migration.add :access_id,
          Pointers.Migration.strong_pointer(Bonfire.Data.AccessControl.Access), null: false
        Ecto.Migration.add :verb_id,
          Pointers.Migration.strong_pointer(Bonfire.Data.AccessControl.Verb), null: false
        Ecto.Migration.add :value, :boolean
        unquote_splicing(exprs)
      end
    end
  end

  defmacro create_interact_table(), do: make_interact_table([])
  defmacro create_interact_table([do: {_, _, body}]), do: make_interact_table(body)

  # drop_interact_table/0

  def drop_interact_table(), do: drop_pointable_table(Interact)

  # create_interact_unique_index/{0,1}

  defp make_interact_unique_index(opts) do
    quote do
      Ecto.Migration.create_if_not_exists(
        Ecto.Migration.unique_index(unquote(@interact_table), unquote(@unique_index), unquote(opts))
      )
    end
  end

  defmacro create_interact_unique_index(opts \\ [])
  defmacro create_interact_unique_index(opts), do: make_interact_unique_index(opts)

  def drop_interact_unique_index(opts \\ [])
  def drop_interact_unique_index(opts), do: drop_if_exists(unique_index(@interact_table, @unique_index, opts))

  defp make_interact_verb_index(opts) do
    quote do
      Ecto.Migration.create_if_not_exists(
        Ecto.Migration.index(unquote(@interact_table), [:verb_id], unquote(opts))
      )
    end
  end
  defmacro create_interact_verb_index(opts \\ [])
  defmacro create_interact_verb_index(opts), do: make_interact_verb_index(opts)

  def drop_interact_verb_index(opts \\ []) do
    drop_if_exists(index(@interact_table, [:verb_id], opts))
  end

  # migrate_interact/{0,1}

  defp mi(:up) do
    quote do
      unquote(make_interact_table([]))
      unquote(make_interact_unique_index([]))
      unquote(make_interact_verb_index([]))
    end
  end
  defp mi(:down) do
    quote do
      Bonfire.Data.AccessControl.Interact.Migration.drop_interact_verb_index()
      Bonfire.Data.AccessControl.Interact.Migration.drop_interact_unique_index()
      Bonfire.Data.AccessControl.Interact.Migration.drop_interact_table()
    end
  end

  defmacro migrate_interact() do
    quote do
      if Ecto.Migration.direction() == :up,
        do: unquote(mi(:up)),
        else: unquote(mi(:down))
    end
  end

  defmacro migrate_interact(dir), do: mi(dir)

end
