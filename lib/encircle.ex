defmodule Bonfire.Data.AccessControl.Encircle do
  @moduledoc """
  """

  use Pointers.Pointable,
    otp_app: :bonfire_data_access_control,
    table_id: "1NSERTSAP01NTER1NT0AC1RC1E",
    source: "bonfire_data_access_control_encircle"

  alias Bonfire.Data.AccessControl.Circle
  alias Bonfire.Data.AccessControl.Encircle

  alias Ecto.Changeset
  alias Pointers.Pointer

  pointable_schema do
    belongs_to(:subject, Pointer)
    belongs_to(:circle, Pointer)
  end

  @cast [:subject_id, :circle_id]
  @required @cast
  @unique_index @cast

  def changeset(encircle \\ %Encircle{}, params) do
    encircle
    |> Changeset.cast(params, @cast)
    |> Changeset.validate_required(@required)
    |> Changeset.assoc_constraint(:subject)
    |> Changeset.assoc_constraint(:circle)
    |> Changeset.unique_constraint(@unique_index)
  end
end

defmodule Bonfire.Data.AccessControl.Encircle.Migration do
  use Ecto.Migration
  import Pointers.Migration
  alias Bonfire.Data.AccessControl.Encircle

  @encircle_table Encircle.__schema__(:source)
  @unique_index [:subject_id, :circle_id]

  # create_encircle_table/{0,1}

  defp make_encircle_table(exprs) do
    quote do
      require Pointers.Migration

      Pointers.Migration.create_pointable_table Bonfire.Data.AccessControl.Encircle do
        Ecto.Migration.add(
          :subject_id,
          Pointers.Migration.strong_pointer()
        )

        Ecto.Migration.add(
          :circle_id,
          Pointers.Migration.strong_pointer()
        )

        unquote_splicing(exprs)
      end
    end
  end

  defmacro create_encircle_table(), do: make_encircle_table([])

  defmacro create_encircle_table(do: {_, _, body}),
    do: make_encircle_table(body)

  def drop_encircle_table(), do: drop_pointable_table(Encircle)

  def migrate_encircle_unique_index(dir \\ direction(), opts \\ [])

  def migrate_encircle_unique_index(:up, opts),
    do: create_if_not_exists(unique_index(@encircle_table, @unique_index, opts))

  def migrate_encircle_unique_index(:down, opts),
    do: drop_if_exists(unique_index(@encircle_table, @unique_index, opts))

  def migrate_encircle_circle_index(dir \\ direction(), opts \\ [])

  def migrate_encircle_circle_index(:up, opts),
    do: create_if_not_exists(index(@encircle_table, [:circle_id], opts))

  def migrate_encircle_circle_index(:down, opts),
    do: drop_if_exists(index(@encircle_table, [:circle_id], opts))

  defp me(:up) do
    quote do
      Bonfire.Data.AccessControl.Encircle.Migration.create_encircle_table()

      Bonfire.Data.AccessControl.Encircle.Migration.migrate_encircle_unique_index()

      Bonfire.Data.AccessControl.Encircle.Migration.migrate_encircle_circle_index()
    end
  end

  defp me(:down) do
    quote do
      Bonfire.Data.AccessControl.Encircle.Migration.migrate_encircle_circle_index()

      Bonfire.Data.AccessControl.Encircle.Migration.migrate_encircle_unique_index()

      Bonfire.Data.AccessControl.Encircle.Migration.drop_encircle_table()
    end
  end

  defmacro migrate_encircle() do
    quote do
      if Ecto.Migration.direction() == :up,
        do: unquote(me(:up)),
        else: unquote(me(:down))
    end
  end

  defmacro migrate_encircle(dir), do: me(dir)
end
