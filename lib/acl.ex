defmodule CommonsPub.Acls.Acl do
  @moduledoc """
  """

  use Pointers.Pointable,
    otp_app: :cpub_acls,
    table_id: "11STSPERM1TTED1NTERACT10NS",
    source: "cpub_access_access"

  alias CommonsPub.Acls.Acl
  alias Pointers.{Changesets, Pointer}

  pointable_schema do
    belongs_to :guest_access, Pointer
    belongs_to :local_user_access, Pointer
  end

  def changeset(acl \\ %Acl{}, attrs, opts \\ []),
    do: Changesets.auto(acl, attrs, opts, [])

end
defmodule CommonsPub.Acls.Acl.Migration do

  use Ecto.Migration
  import Pointers.Migration
  alias CommonsPub.Acls.Acl

  def create_acl_table() do
    create_pointable_table(Acl) do
      add :guess_acces_id, weak_pointer()
      add :local_user_access_id, weak_pointer()
    end
  end

  def drop_acl_table(), do: drop_pointable_table(Acl)

  def migrate_acl(dir \\ direction())
  def migrate_acl(:up), do: create_acl_table()
  def migrate_acl(:down), do: drop_acl_table()
end
