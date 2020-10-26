defmodule CommonsPub.Acls.AclGrant do
  @moduledoc """
  """

  use Pointers.Pointable,
    otp_app: :cpub_acls,
    table_id: "MAKESACCESSGRANTPART0FAC1S",
    source: "cpub_acls_acl_grant"

  alias CommonsPub.Acls.{Acl, AclGrant}
  alias Pointers.{Changesets, Pointer}

  pointable_schema do
    belongs_to :access_grant, Pointer
    belongs_to :access_list, Acl
  end

  def changeset(acl \\ %AclGrant{}, attrs, opts \\ []),
    do: Changesets.auto(acl, attrs, opts, [])
end

defmodule CommonsPub.Acls.AclGrant.Migration do

  use Ecto.Migration
  import Pointers.Migration
  alias CommonsPub.Acls.{Acl, AclGrant}

  def create_acl_table() do
    create_pointable_table(AclGrant) do
      add :access_grant_id, strong_pointer()
      add :access_list_id, strong_pointer(CommonsPub.Acls.Acl)
    end
  end

  def drop_acl_table(), do: drop_pointable_table(Acl)

  def migrate_acl_grant(dir \\ direction())
  def migrate_acl_grant(:up), do: create_acl_table()
  def migrate_acl_grant(:down), do: drop_acl_table()

end
