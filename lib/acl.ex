defmodule Bonfire.Data.AccessControl.Acl do
  @moduledoc """
  Conceptually, a complete list of all permissions for everybody.

  In practice, it's a partial specification and anything not
  explicitly granted is assumed to be denied.

  Can be reused to secure multiple objects, thus exists independently
  of any object.
  """

  use Pointers.Pointable,
    otp_app: :bonfire_data_access_control,
    table_id: "11STSPERM1TTED1NTERACT10NS",
    source: "bonfire_data_access_control_acl"

  alias Bonfire.Data.AccessControl.{Acl, Grant, Controlled}
  alias Ecto.Changeset

  pointable_schema do
    has_many :grants, Grant
    has_many :controlled, Controlled
  end

  def changeset(acl \\ %Acl{}, params), do: acl
    |> Changeset.cast(params, [])
    |> Changeset.cast_assoc(:grants, with: &Grant.changeset/2)

end
defmodule Bonfire.Data.AccessControl.Acl.Migration do

  use Ecto.Migration
  import Pointers.Migration
  alias Bonfire.Data.AccessControl.Acl

  # create_acl_table/{0,1}

  defp make_acl_table(exprs) do
    quote do
      require Pointers.Migration
      Pointers.Migration.create_pointable_table(Bonfire.Data.AccessControl.Acl) do
        unquote_splicing(exprs)
      end
    end
  end

  defmacro create_acl_table(), do: make_acl_table([])
  defmacro create_acl_table([do: {_, _, body}]), do: make_acl_table(body)

  # drop_acl_table/0

  def drop_acl_table(), do: drop_pointable_table(Acl)

  # migrate_acl/{0,1}

  defp ma(:up), do: make_acl_table([])
  defp ma(:down) do
    quote do: Bonfire.Data.AccessControl.Acl.Migration.drop_acl_table()
  end

  defmacro migrate_acl() do
    quote do
      if Ecto.Migration.direction() == :up,
        do: unquote(ma(:up)),
        else: unquote(ma(:down))
    end
  end
  defmacro migrate_acl(dir), do: ma(dir)

end
