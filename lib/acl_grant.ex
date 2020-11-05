defmodule CommonsPub.Acls.AclGrant do
  @moduledoc """
  """

  use Pointers.Pointable,
    otp_app: :cpub_acls,
    table_id: "MAKESACCESSGRANTPART0FAC1S",
    source: "cpub_acls_acl_grant"

  alias CommonsPub.Access.AccessGrant
  alias CommonsPub.Acls.Acl
  alias Pointers.Changesets

  pointable_schema do
    belongs_to :acl, Acl
    belongs_to :access_grant, AccessGrant
  end

  def changeset(acl \\ %Acl{}, attrs, opts \\ []),
    do: Changesets.auto(acl, attrs, opts, [])
 
end
defmodule CommonsPub.Acls.AclGrant.Migration do

  use Ecto.Migration
  import Pointers.Migration
  alias CommonsPub.Acls.AclGrant

  @acl_grant_table AclGrant.__schema__(:source)
  @unique_index [:acl_id, :access_grant_id]
  @secondary_index [:access_grant_id]

  # create_acl_grant_table{0,1}

  defp make_acl_grant_table(exprs) do
    quote do
      Pointers.Migration.create_pointable_table(CommonsPub.Acls.AclGrant) do
        Ecto.Migration.add :acl_id,
          Pointers.Migrations.strong_pointer(CommonsPub.Acls.Acl)
        Ecto.Migration.add :access_grant_id,
          Pointers.Migrations.strong_pointer(CommonsPub.Access.AccessGrant)
        unquote_splicing(exprs)
      end
    end
  end

  defmacro create_acl_grant_table(), do: make_acl_grant_table([])
  defmacro create_acl_grant_table([do: body]), do: make_acl_grant_table(body)

  # drop_acl_grant_table/0

  def drop_acl_grant_table(), do: drop_pointable_table(AclGrant)

  # create_acl_grant_unique_index/{0,1}

  defp make_acl_grant_unique_index(opts) do
    quote do
      Ecto.Migration.create_if_not_exists(
        Ecto.Migration.unique_index(unquote(@acl_grant_table), unquote(@unique_index), unquote(opts))
      )
    end
  end

  defmacro create_acl_grant_unique_index(opts \\ [])
  defmacro create_acl_grant_unique_index(opts), do: make_acl_grant_unique_index(opts)

  def drop_acl_grant_unique_index(opts \\ [])
  def drop_acl_grant_unique_index(opts), do: drop_if_exists(unique_index(@acl_grant_table, @unique_index, opts))

  defp make_acl_grant_secondary_index(opts) do
    quote do
      Ecto.Migration.create_if_not_exists(
        Ecto.Migration.index(unquote(@acl_grant_table), @secondary_index, unquote(opts))
      )
    end
  end

  defmacro create_acl_grant_secondary_index(opts \\ [])
  defmacro create_acl_grant_secondary_index(opts), do: make_acl_grant_secondary_index(opts)

  def drop_acl_grant_secondary_index(opts \\ [])
  def drop_acl_grant_secondary_index(opts), do: drop_if_exists(index(@acl_grant_table, @secondary_index, opts))

  # migrate_acl_grant{0,1}

  defp mag(:up) do
    quote do
      unquote_splicing(make_acl_grant_table([]))
      unquote_splicing(make_acl_grant_unique_index([]))
      unquote_splicing(make_acl_grant_secondary_index([]))
    end
  end

  defp mag(:down) do
    quote do
      CommonsPub.Acls.AclGrant.Migration.drop_acl_grant_secondary_index()
      CommonsPub.Acls.AclGrant.Migration.drop_acl_grant_unique_index()
      CommonsPub.Acls.AclGrant.Migration.drop_acl_grant_table()
    end
  end

  defmacro migrate_acl_grant(dir \\ direction()), do: mag(dir)

end
