defmodule Bonfire.Data.AccessControl.InstanceAdmin do
  @moduledoc "A mixin for superpowers"

  use Pointers.Mixin,
    otp_app: :bonfire_data_access_control,
    source: "bonfire_data_access_control_instance_admin"

  alias Bonfire.Data.AccessControl.InstanceAdmin
  alias Ecto.Changeset

  mixin_schema do
    field :is_instance_admin, :boolean
  end

  def changeset(admin \\ %InstanceAdmin{}, params, cast \\ [:is_instance_admin]) do
    admin
    |> Changeset.cast(params, cast)
    |> Changeset.validate_required([:is_instance_admin])
  end

end
defmodule Bonfire.Data.AccessControl.InstanceAdmin.Migration do

  use Ecto.Migration
  import Pointers.Migration
  alias Bonfire.Data.AccessControl.InstanceAdmin

  # @instance_admin_table InstanceAdmin.__schema__(:source)

  # create_instance_admin_table/{0,1}

  defp make_instance_admin_table(exprs) do
    quote do
      require Pointers.Migration
      Pointers.Migration.create_mixin_table(Bonfire.Data.AccessControl.InstanceAdmin) do
        Ecto.Migration.add :is_instance_admin, :bool, null: false, default: false
        unquote_splicing(exprs)
      end
    end
  end

  defmacro create_instance_admin_table(), do: make_instance_admin_table([])
  defmacro create_instance_admin_table([do: {_, _, body}]), do: make_instance_admin_table(body)

  # drop_instance_admin_table/0

  def drop_instance_admin_table(), do: drop_mixin_table(InstanceAdmin)

  # migrate_instance_admin/{0,1}

  defp mc(:up), do: make_instance_admin_table([])
  defp mc(:down) do
    quote do
      Bonfire.Data.AccessControl.InstanceAdmin.Migration.drop_instance_admin_table()
    end
  end

  defmacro migrate_instance_admin() do
    quote do
      if Ecto.Migration.direction() == :up,
        do: unquote(mc(:up)),
        else: unquote(mc(:down))
    end
  end
  defmacro migrate_instance_admin(dir), do: mc(dir)

end
