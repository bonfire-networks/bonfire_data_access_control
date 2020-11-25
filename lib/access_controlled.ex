defmodule Bonfire.Data.AccessControl.AccessControlled do
  @moduledoc """
  """

  use Pointers.Mixin,
    otp_app: :bonfire_data_access_control,
    source: "bonfire_data_access_control_access_controlled"

  alias Bonfire.Data.AccessControl.{AccessControlled, Acl}
  alias Pointers.{Changesets, Pointer}

  mixin_schema do
    belongs_to :caretaker, Pointer
    belongs_to :acl, Acl
  end

  def changeset(acl \\ %Acl{}, attrs, opts \\ []),
    do: Changesets.auto(acl, attrs, opts, [])
 
end
defmodule Bonfire.Data.AccessControl.AccessControlled.Migration do

  use Ecto.Migration
  import Pointers.Migration
  alias Bonfire.Data.AccessControl.AccessControlled

  # create_access_controlled_table/{0,1}

  defp make_access_controlled_table(exprs) do
    quote do
      require Pointers.Migration
      Pointers.Migration.create_mixin_table(Bonfire.Data.AccessControl.AccessControlled) do
        Ecto.Migration.add :caretaker_id,
          Pointers.Migration.strong_pointer(), null: false
        Ecto.Migration.add :acl_id,
          Pointers.Migration.strong_pointer(Bonfire.Data.AccessControl.Acl), null: false
        unquote_splicing(exprs)
      end
    end
  end

  defmacro create_access_controlled_table(), do: make_access_controlled_table([])
  defmacro create_access_controlled_table([do: {_, _, body}]), do: make_access_controlled_table(body)

  # drop_access_controlled_table/0

  def drop_access_controlled_table(), do: drop_pointable_table(Acl)

  # migrate_acl/{0,1}

  defp mac(:up) do
    quote do
      require Bonfire.Data.AccessControl.AccessControlled.Migration
      Bonfire.Data.AccessControl.AccessControlled.Migration.create_access_controlled_table()
      Bonfire.Data.AccessControl.AccessControlled.Migration.create_access_controlled_caretaker_index()
      Bonfire.Data.AccessControl.AccessControlled.Migration.create_access_controlled_acl_index()
    end      
  end
  defp mac(:down) do
    quote do
      Bonfire.Data.AccessControl.AccessControlled.Migration.drop_access_controlled_acl_index()
      Bonfire.Data.AccessControl.AccessControlled.Migration.drop_access_controlled_caretaker_index()
      Bonfire.Data.AccessControl.AccessControlled.Migration.drop_access_controlled_table()
    end
  end

  defmacro migrate_access_controlled() do
    quote do
      if Ecto.Migration.direction() == :up,
        do: unquote(mac(:up)),
        else: unquote(mac(:down))
    end
  end
  defmacro migrate_access_controlled(dir), do: mac(dir)

end
