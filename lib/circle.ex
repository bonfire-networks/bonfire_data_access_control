defmodule Bonfire.Data.AccessControl.Circle do
  @moduledoc """
  """
  use Needle.Virtual,
    otp_app: :bonfire_data_access_control,
    table_id: "41RC1ESAREAV1S1B111TYSC0PE",
    source: "bonfire_data_access_control_circle"

  alias Bonfire.Data.AccessControl.Circle
  alias Bonfire.Data.AccessControl.Encircle
  alias Bonfire.Data.AccessControl.Stereotyped

  alias Needle.Changesets
  alias Needle.Pointer

  virtual_schema do
    has_many(:encircles, Encircle, on_replace: :delete_if_exists)

    many_to_many(:encircle_subjects, Pointer,
      join_through: Encircle,
      join_keys: [circle_id: :id, subject_id: :id]
    )

    has_one(:stereotyped, Stereotyped, foreign_key: :id, references: :id)
  end

  def changeset(circle \\ %Circle{}, params),
    do: Changesets.cast(circle, params, [])
end

defmodule Bonfire.Data.AccessControl.Circle.Migration do
  @moduledoc false
  import Needle.Migration
  alias Bonfire.Data.AccessControl.Circle

  def migrate_circle(), do: migrate_virtual(Circle)
end
