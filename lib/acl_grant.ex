defmodule CommonsPub.Acls.AclGrant do
  @moduledoc """
  """

  use Pointers.Pointable,
    otp_app: :cpub_acls,
    table_id: "MAKESACCESSGRANTPART0FAC1S",
    source: "cpub_acls_acl_grant"

  alias CommonsPub.Acls.{Acl, AclGrant, Foam}
  alias Pointers.{Changesets, Pointer}

  pointable_schema do
    belongs_to :foam, Foam
    belongs_to :subject, Pointer
    belongs_to :acl, Acl
  end

  def changeset(acl \\ %Acl{}, attrs, opts \\ []),
    do: Changesets.auto(acl, attrs, opts, [])
 
end
defmodule CommonsPub.Acls.AclGrant.Migration do

  use Ecto.Migration
  import Pointers.Migration
  alias CommonsPub.Acls.{Acl, AclGrant, Foam}

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
      Pointers.Migration.create_pointable_table(CommonsPub.Acls.Acl) do
        Ecto.Migration.add :foam_id,
          Pointers.Migrations.strong_pointer(CommonsPub.Acls.Foam)
        Ecto.Migration.add :subject_id,
          Pointers.Migrations.strong_pointer()
        Ecto.Migration.add :acl_id,
          Pointers.Migrations.strong_pointer(CommonsPub.Acls.Acl)
        unquote_splicing(body)
      end
    end
  end

  def drop_acl_table(), do: drop_pointable_table(Acl)

end
