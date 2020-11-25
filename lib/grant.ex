defmodule Bonfire.Data.AccessControl.Grant do
  @moduledoc """
  """

  use Pointers.Pointable,
    otp_app: :bonfire_data_accesscontrol,
    table_id: "GRANTSS0MEACCESST0ASVBJECT",
    source: "bonfire_data_accesscontrol_grant"

  alias Bonfire.Data.AccessControl.{Acl, Access, Grant}
  alias Pointers.{Changesets, Pointer}

  pointable_schema do
    belongs_to :subject, Pointer
    belongs_to :access, Access
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
  @secondary_indexes [:subject_id, :access_id]

  # create_grant_table/{0,1}

  defp make_grant_table(exprs) do
    quote do
      require Pointers.Migration
      Pointers.Migration.create_pointable_table(Bonfire.Data.AccessControl.Grant) do
        Ecto.Migration.add :subject_id,
          Pointers.Migration.strong_pointer(), null: false
        Ecto.Migration.add :acl_id,
          Pointers.Migration.strong_pointer(Bonfire.Data.AccessControl.Acl), null: false
        Ecto.Migration.add :access_id,
          Pointers.Migration.strong_pointer(Bonfire.Data.AccessControl.Access), null: false
        unquote_splicing(exprs)
      end
    end
  end

  defmacro create_grant_table(), do: make_grant_table([])
  defmacro create_grant_table([do: {_, _, body}]), do: make_grant_table(body)

  # drop_grant_table/0

  def drop_grant_table(), do: drop_pointable_table(Grant)

  # create_acl_grant_unique_index/{0,1}

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

  defp make_grant_secondary_indexes(opts) do
    quote do
      unquote_splicing(Enum.map(@secondary_indexes, fn i ->
            quote do
              Ecto.Migration.create_if_not_exists(
                Ecto.Migration.index(unquote(@grant_table), unquote(i), unquote(opts))
              )
            end
          ))
    end
  end

  defmacro create_grant_secondary_indexes(opts \\ [])
  defmacro create_grant_secondary_indexes(opts), do: make_grant_secondary_indexes(opts)

  def drop_grant_secondary_index(opts \\ [])
  def drop_grant_secondary_index(opts) do
    for i in @secondary_indexes do
      drop_if_exists(index(@grant_table, i, opts))
    end
  end

  # migrate_grant/{0,1}

  defp mag(:up) do
    quote do
      require Bonfire.Data.AccessControl.Grant.Migration
      Bonfire.Data.AccessControl.Grant.Migration.create_grant_table()
      Bonfire.Data.AccessControl.Grant.Migration.create_grant_unique_index()
      Bonfire.Data.AccessControl.Grant.Migration.create_grant_secondary_indexes()
    end
  end
  defp mag(:down) do
    quote do
      Bonfire.Data.AccessControl.Grant.Migration.drop_grant_secondary_indexes()
      Bonfire.Data.AccessControl.Grant.Migration.drop_grant_unique_index()
      Bonfire.Data.AccessControl.Grant.Migration.drop_grant_table()
    end
  end

  defmacro migrate_grant() do
    quote do
      if Ecto.Migration.direction() == :up,
        do: unquote(mag(:up)),
        else: unquote(mag(:down))
    end
  end

  defmacro migrate_grant(dir), do: mag(dir)

end
