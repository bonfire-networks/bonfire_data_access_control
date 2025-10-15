defmodule Bonfire.Data.AccessControl.Grant do
  @moduledoc """
  """

  use Needle.Pointable,
    otp_app: :bonfire_data_access_control,
    table_id: "0RANTSS0MEACCESST0ASVBJECT",
    source: "bonfire_data_access_control_grant"

  alias Bonfire.Data.AccessControl.Acl
  alias Bonfire.Data.AccessControl.Grant
  alias Bonfire.Data.AccessControl.Verb

  alias Ecto.Changeset
  alias Needle.Changesets
  alias Needle.Pointer

  pointable_schema do
    belongs_to(:acl, Acl)
    belongs_to(:subject, Pointer)
    belongs_to(:verb, Verb)
    field(:value, :boolean)
  end

  @unique_index [:acl_id, :subject_id, :verb_id]
  @cast [:acl_id, :subject_id, :verb_id, :value]
  @required @cast

  def changeset(grant \\ %Grant{}, params) do
    grant
    |> Changesets.cast(params, @cast)
    |> Changeset.validate_required(@required)
    |> Changeset.assoc_constraint(:acl)
    |> Changeset.assoc_constraint(:subject)
    |> Changeset.assoc_constraint(:verb)
    |> Changeset.unique_constraint(@unique_index)
  end
end

defmodule Bonfire.Data.AccessControl.Grant.Migration do
  @moduledoc false
  use Ecto.Migration
  import Needle.Migration
  alias Bonfire.Data.AccessControl.Grant

  @grant_table Grant.__schema__(:source)
  @unique_index [:acl_id, :subject_id, :verb_id]

  # create_grant_table/{0,1}

  defp make_grant_table(exprs) do
    quote do
      import Needle.Migration

      Needle.Migration.create_pointable_table Bonfire.Data.AccessControl.Grant do
        add_pointer(:acl_id, :strong, Bonfire.Data.AccessControl.Acl, null: false)
        add_pointer(:subject_id, :strong, Needle.Pointer, null: false)
        add_pointer(:verb_id, :strong, Bonfire.Data.AccessControl.Verb, null: false)
        Ecto.Migration.add(:value, :boolean)
        unquote_splicing(exprs)
      end
    end
  end

  defmacro create_grant_table(), do: make_grant_table([])
  defmacro create_grant_table(do: {_, _, body}), do: make_grant_table(body)

  # drop_grant_table/0

  def drop_grant_table(), do: drop_pointable_table(Grant)

  # create_grant_unique_index/{0,1}

  defp make_grant_unique_index(opts) do
    quote do
      Ecto.Migration.create_if_not_exists(
        Ecto.Migration.unique_index(
          unquote(@grant_table),
          unquote(@unique_index),
          unquote(opts)
        )
      )
    end
  end

  defmacro create_grant_unique_index(opts \\ [])
  defmacro create_grant_unique_index(opts), do: make_grant_unique_index(opts)

  def drop_grant_unique_index(opts \\ [])

  def drop_grant_unique_index(opts),
    do: drop_if_exists(unique_index(@grant_table, @unique_index, opts))

  # migrate_grant/{0,1}

  defp mg(:up) do
    quote do
      unquote(make_grant_table([]))
      unquote(make_grant_unique_index([]))
    end
  end

  defp mg(:down) do
    quote do
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
