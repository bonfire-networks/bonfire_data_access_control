defmodule CommonsPub.Access.Access do
  @moduledoc """
  """

  use Pointers.Pointable,
    otp_app: :cpub_acls,
    table_id: "11STSPERM1TTED1NTERACT10NS",
    source: "cpub_access_access"

  alias CommonsPub.Acls.Acl
  alias Pointers.{Changesets, Pointer}

  pointable_schema do
  end

  def changeset(acl \\ %Acl{}, attrs, opts \\ []),
    do: Changesets.auto(acl, attrs, opts, [])
 
end
defmodule CommonsPub.Acls.Acl.Migration do

  use Ecto.Migration
  import Pointers.Migration
  alias CommonsPub.Acls.Acl

  def migrate_acl(dir \\ direction())
  def migrate_acl(:up), do: create_acl_table
  def migrate_acl(:down), do: drop_acl_table()

  defmacro create_acl_table() do
    quote do
      CommonsPub.Acls.Acl.Migration.create_acl_table do
      end
    end
  end

  defmacro create_acl_table([do: body]) do
    quote do
      Pointers.Migration.create_pointable_table(Acl), do: unquote(body)
    end
  end

  def drop_acl_table(), do: drop_pointable_table(Acl)

end
