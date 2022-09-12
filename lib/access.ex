defmodule Bonfire.Data.AccessControl.Access do
  @moduledoc """
  """

  use Pointers.Pointable,
    otp_app: :bonfire_data_access_control,
    table_id: "2BVNCH0FPERM1SS10NS1NA11ST",
    source: "bonfire_data_access_control_access"

  alias Bonfire.Data.AccessControl.Access
  alias Bonfire.Data.AccessControl.Grant
  alias Bonfire.Data.AccessControl.Verb

  pointable_schema do
    has_many(:grants, Grant)
    belongs_to(:verb, Verb)
    field(:value, :boolean)
  end

  @cast [:verb_id, :value]

  def changeset(access \\ %Access{}, params) do
    Changeset.cast(access, params, @cast)
    |> Changeset.validate_required(@cast)
  end
end

defmodule Bonfire.Data.AccessControl.Access.Migration do
  use Ecto.Migration
  import Pointers.Migration
  alias Bonfire.Data.AccessControl.Access

  # create_access_table/{0,1}

  defp make_access_table(exprs) do
    quote do
      require Pointers.Migration

      Pointers.Migration.create_pointable_table Bonfire.Data.AccessControl.Access do
        Ecto.Migration.add(
          :verb_id,
          Pointers.Migration.strong_pointer(Bonfire.Data.AccessControl.Verb),
          null: false
        )

        Ecto.Migration.add(:value, :boolean)
        unquote_splicing(exprs)
      end
    end
  end

  defmacro create_access_table(), do: make_access_table([])
  defmacro create_access_table(do: {_, _, body}), do: make_access_table(body)

  # drop_access_table/0

  def drop_access_table(), do: drop_pointable_table(Access)

  # migrate_access/{0,1}

  defp ma(:up), do: make_access_table([])

  defp ma(:down) do
    quote do: Bonfire.Data.AccessControl.Access.Migration.drop_access_table()
  end

  defmacro migrate_access() do
    quote do
      if Ecto.Migration.direction() == :up,
        do: unquote(ma(:up)),
        else: unquote(ma(:down))
    end
  end

  defmacro migrate_access(dir), do: ma(dir)
end
