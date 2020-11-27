defmodule Bonfire.Data.AccessControl.Grant do
  @moduledoc """
  """

  use Pointers.Pointable,
    otp_app: :bonfire_data_access_control,
    table_id: "GRANTSS0MEACCESST0ASVBJECT",
    source: "bonfire_data_access_control_grant"

  alias Bonfire.Data.AccessControl.{Acl, Access, Grant}
  alias Pointers.{Changesets, Pointer}

  pointable_schema do
    belongs_to :subject, Pointer
    belongs_to :access, Access
    belongs_to :acl, Acl
  end

  def changeset(grant \\ %Grant{}, attrs, opts \\ []),
    do: Changesets.auto(grant, attrs, opts, [])
 
end
defmodule Bonfire.Data.AccessControl.Grant.Migration do

  use Ecto.Migration
  import Pointers.Migration
  alias Bonfire.Data.AccessControl.Grant

  @grant_table Grant.__schema__(:source)
  @unique_index [:acl_id, :subject_id, :access_id]

  # create_grant_table/{0,1}

  defp make_grant_table(exprs) do
    quote do
      require Pointers.Migration
      Pointers.Migration.create_pointable_table(Bonfire.Data.AccessControl.Grant) do
        Ecto.Migration.add :subject_id,
          Pointers.Migration.strong_pointer(), null: false
        Ecto.Migration.add :access_id,
          Pointers.Migration.strong_pointer(Bonfire.Data.AccessControl.Access), null: false
        Ecto.Migration.add :acl_id,
          Pointers.Migration.strong_pointer(Bonfire.Data.AccessControl.Acl), null: false
        unquote_splicing(exprs)
      end
    end
  end

  defmacro create_grant_table(), do: make_grant_table([])
  defmacro create_grant_table([do: {_, _, body}]), do: make_grant_table(body)

  # drop_grant_table/0

  def drop_grant_table(), do: drop_pointable_table(Grant)

  # create_grant_unique_index/{0,1}

  defp make_grant_unique_index(opts) do
    quote do
      Ecto.Migration.create_if_not_exists(
        Ecto.Migration.unique_index(unquote(@grant_table), unquote(@unique_index), unquote(opts))
      )
    end
  end

  defmacro create_grant_unique_index(opts \\ [])
  defmacro create_grant_unique_index(opts), do: make_grant_unique_index(opts)

  def drop_grant_unique_index(opts \\ [])
  def drop_grant_unique_index(opts), do: drop_if_exists(unique_index(@grant_table, @unique_index, opts))

  defp make_grant_subject_index(opts) do
    quote do
      Ecto.Migration.create_if_not_exists(
        Ecto.Migration.index(unquote(@grant_table), [:subject_id], unquote(opts))
      )
    end
  end

  defp make_grant_access_index(opts) do
    quote do
      Ecto.Migration.create_if_not_exists(
        Ecto.Migration.index(unquote(@grant_table), [:access_id], unquote(opts))
      )
    end
  end

  defmacro create_grant_subject_index(opts \\ [])
  defmacro create_grant_subject_index(opts), do: make_grant_subject_index(opts)

  defmacro create_grant_access_index(opts \\ [])
  defmacro create_grant_access_index(opts), do: make_grant_access_index(opts)

  def drop_grant_subject_index(opts \\ []) do
      drop_if_exists(index(@grant_table, [:subject_id], opts))
  end

  def drop_grant_access_index(opts \\ []) do
      drop_if_exists(index(@grant_table, [:access_id], opts))
  end


  # migrate_grant/{0,1}

  defp mg(:up) do
    quote do
      unquote(make_grant_table([]))
      unquote(make_grant_unique_index([]))
      unquote(make_grant_subject_index([]))
      unquote(make_grant_access_index([]))
    end
  end
  defp mg(:down) do
    quote do
      Bonfire.Data.AccessControl.Grant.Migration.drop_grant_access_index()
      Bonfire.Data.AccessControl.Grant.Migration.drop_grant_subject_index()
      Bonfire.Data.AccessControl.Grant.Migration.drop_grant_unique_index()
      Bonfire.Data.AccessControl.Grant.Migration.drop_grant_table()
    end
  end

  defmacro migrate_grant() do
    quote do
      if Ecto.Migration.direction() == :up,
        do: unquote(mg(:up)),
        else: unquote(mg(:down))
    end
  end

  defmacro migrate_grant(dir), do: mg(dir)

end
