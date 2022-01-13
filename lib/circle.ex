defmodule Bonfire.Data.AccessControl.Circle do
  @moduledoc """
  """

  use Pointers.Virtual,
    otp_app: :bonfire_data_access_control,
    table_id: "41RC1ESAREAV1S1B111TYSC0PE",
    source: "bonfire_data_access_control_circle"

  alias Bonfire.Data.AccessControl.{Circle, Encircle}
  alias Ecto.Changeset

  virtual_schema do
    has_many :encircles, Encircle, on_replace: :delete_if_exists
  end

  def changeset(circle \\ %Circle{}, params) do
    Changeset.cast(circle, params, [])
  end

end
defmodule Bonfire.Data.AccessControl.Circle.Migration do

  import Pointers.Migration
  alias Bonfire.Data.AccessControl.Circle

  def migrate_circle(), do: migrate_virtual(Circle)

end
