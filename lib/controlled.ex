defmodule Bonfire.Data.AccessControl.Controlled do
  @moduledoc """
  """

  use Pointers.Mixin,
    otp_app: :bonfire_data_access_control,
    source: "bonfire_data_access_control_controlled"

  alias Bonfire.Data.AccessControl.{Acl, Controlled}
  alias Ecto.Changeset

  mixin_schema do
    belongs_to :acl, Acl
  end

  def changeset(controlled \\ %Controlled{}, params) do
    controlled
    |> Changeset.cast(params, [:id, :acl_id])
    |> Changeset.validate_required([:acl_id])
    |> Changeset.assoc_constraint(:acl)
  end

end
defmodule Bonfire.Data.AccessControl.Controlled.Migration do

  use Ecto.Migration
  import Pointers.Migration
  alias Bonfire.Data.AccessControl.Controlled

  @controlled_table Controlled.__schema__(:source)

  # create_controlled_table/{0,1}

  defp make_controlled_table(exprs) do
    quote do
      require Pointers.Migration
      Pointers.Migration.create_mixin_table(Bonfire.Data.AccessControl.Controlled) do
        Ecto.Migration.add :acl_id,
          Pointers.Migration.strong_pointer(Bonfire.Data.AccessControl.Acl), null: false
        unquote_splicing(exprs)
      end
    end
  end

  defmacro create_controlled_table(), do: make_controlled_table([])
  defmacro create_controlled_table([do: {_, _, body}]), do: make_controlled_table(body)

  # drop_controlled_table/0

  def drop_controlled_table(), do: drop_mixin_table(Controlled)

  # create_controlled_acl_index/{0, 1}

  defp make_controlled_acl_index(opts) do
    quote do
      Ecto.Migration.create_if_not_exists(
        Ecto.Migration.index(unquote(@controlled_table), [:acl_id], unquote(opts))
      )
    end
  end

  defmacro create_controlled_acl_index(opts \\ [])
  defmacro create_controlled_acl_index(opts), do: make_controlled_acl_index(opts)

  def drop_controlled_acl_index(opts \\ []) do
    drop_if_exists(index(@controlled_table, [:acl_id], opts))
  end


  # migrate_controlled/{0,1}

  defp mc(:up) do
    quote do
      unquote(make_controlled_table([]))
      unquote(make_controlled_acl_index([]))
    end
  end
  defp mc(:down) do
    quote do
      Bonfire.Data.AccessControl.Controlled.Migration.drop_controlled_acl_index()
      Bonfire.Data.AccessControl.Controlled.Migration.drop_controlled_table()
    end
  end

  defmacro migrate_controlled() do
    quote do
      if Ecto.Migration.direction() == :up,
        do: unquote(mc(:up)),
        else: unquote(mc(:down))
    end
  end
  defmacro migrate_controlled(dir), do: mc(dir)

end
