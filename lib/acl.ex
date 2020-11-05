defmodule CommonsPub.Acls.Acl do
  @moduledoc """
  """

  use Pointers.Pointable,
    otp_app: :cpub_acls,
    table_id: "11STSPERM1TTED1NTERACT10NS",
    source: "cpub_acls_acls"

  alias CommonsPub.Acls.Acl
  alias Pointers.Changesets

  pointable_schema do
  end

  def changeset(acl \\ %Acl{}, attrs, opts \\ []),
    do: Changesets.auto(acl, attrs, opts, [])
 
end
defmodule CommonsPub.Acls.Acl.Migration do

  use Ecto.Migration
  import Pointers.Migration
  alias CommonsPub.Acls.Acl

  # create_acl_table/{0,1}

  defp make_acl_table(exprs) do
    quote do
      CommonsPub.Acls.Acl.Migration.create_acl_table do
        unquote_splicing(exprs)
      end
    end
  end

  defmacro create_acl_table(), do: make_acl_table([])
  defmacro create_acl_table([do: body]), do: make_acl_table(body)

  # drop_acl_table/0

  def drop_acl_table(), do: drop_pointable_table(Acl)

  # migrate_acl/{0,1}

  defp ma(:up), do: make_acl_table([])
  defp ma(:down) do
    quote do: CommonsPub.Acls.Acl.Migration.drop_acl_table()
  end

  defmacro migrate_acl(dir \\ direction()), do: ma(dir)

end
