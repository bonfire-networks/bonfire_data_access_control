defmodule Bonfire.Data.AccessControl.Access do
  @moduledoc """
  """

  use Pointers.Pointable,
    otp_app: :bonfire_data_access_control,
    table_id: "ABVNCH0FPERM1SS10NS1NA11ST",
    source: "bonfire_data_access_control_access"

  alias Bonfire.Data.AccessControl.{Access, Interact}
  alias Ecto.Changeset

  pointable_schema do
    has_many :grants, Grant
    has_many :interacts, Interact
    field :can_see, :boolean
    field :can_read, :boolean
  end

  def changeset(access \\ %Access{}, params) do
    Changeset.cast(access, params, [:can_see, :can_read])
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
      Pointers.Migration.create_pointable_table(Bonfire.Data.AccessControl.Access) do
        unquote_splicing(exprs)
        Ecto.Migration.add :can_see, :boolean
        Ecto.Migration.add :can_read, :boolean
      end
    end
  end

  defmacro create_access_table(), do: make_access_table([])
  defmacro create_access_table([do: {_, _, body}]), do: make_access_table(body)

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
