defmodule Bonfire.Data.AccessControl.Verbs do
  @moduledoc """
  A Global cache of known verbs to be queried by their (Pointer) IDs
  or name strings.

  Use of the Verbs Service requires:

  1. Exporting `verbs/0` in relevant modules, returning a keylist of
     name and (pointer) id.
  2. Start `Bonfire.Data.AccessControl.Verbs` before querying.
  3. To populate the search path with otp application.
  4. OTP 21.2 or greater, though we recommend using the most recent
     release available.

  While this module is a GenServer, it is only responsible for setup
  of the cache and then exits with :ignore having done so. It is not
  recommended to restart the service as this will lead to a stop the
  world garbage collection of all processes and the copying of the
  entire cache to each process that has queried it since its last
  local garbage collection.
  """
  alias Bonfire.Data.AccessControl.Verb

  use GenServer, restart: :transient

  @typedoc """
  A query is either a verb name atom or (Pointer) id binary
  """
  @type query :: binary | atom

  @spec start_link(ignored :: term) :: GenServer.on_start()
  @doc "Populates the global cache with verb data via introspection."
  def start_link(_), do: GenServer.start_link(__MODULE__, [])

  def data(), do: :persistent_term.get(__MODULE__)

  @spec verb(query :: query) :: {:ok, Verb.t} | {:error, :not_found}
  @doc "Get a Verb identified by name or id."
  def verb(query) when is_binary(query) or is_atom(query) do
    case Map.get(data(), query) do
      nil -> {:error, :not_found}
      other -> {:ok, other}
    end
  end

  @spec verb!(query) :: Verb.t
  @doc "Look up a Verb by name or id, throw :not_found if not found."
  def verb!(query), do: Map.get(data(), query) || throw(:not_found)

  @spec id(query) :: {:ok, integer()} | {:error, :not_found}
  @doc "Look up a verb id by id, name or schema."
  def id(query), do: with( {:ok, val} <- verb(query), do: {:ok, val.id})

  @spec id!(query) :: integer()
  @doc "Look up a verb id by id, name or schema, throw :not_found if not found."
  def id!(query) when is_atom(query) or is_binary(query), do: id!(query, data())

  @spec ids!([binary | atom]) :: [binary]
  @doc "Look up many ids at once, throw :not_found if any of them are not found"
  def ids!(ids) do
    data = data()
    Enum.map(ids, &id!(&1, data))
  end

  # called by id!/1, ids!/1
  defp id!(query, data), do: Map.get(data, query).id || throw(:not_found)

  # GenServer callback

  @doc false
  def init(_) do
    indexed =
      search_path()
      |> Enum.flat_map(&app_modules/1)
      |> Enum.filter(&declares_verbs?/1)
      |> Enum.reduce(%{}, &index/2)
    :persistent_term.put(__MODULE__, indexed)
    :ignore
  end

  defp app_modules(app), do: app_modules(app, Application.spec(app, :modules))
  defp app_modules(_, nil), do: []
  defp app_modules(_, mods), do: mods

  # called by init/1
  defp search_path(), do: Application.fetch_env!(:bonfire_data_access_control, :search_path)

  # called by init/1
  defp declares_verbs?(module), do: function_exported?(module, :declare_verbs, 0)

  # called by init/1
  defp index(mod, acc), do: index(mod, acc, mod.declare_verbs())

  # called by index/2
  defp index(mod, acc, verbs) do
    Enum.reduce(verbs, acc, fn {k, v}, acc -> index(mod, acc, v, k) end)
  end

  # called by index/3
  defp index(_, acc, id, verb) do
    Pointers.ULID.cast!(id)
    t = %Verb{id: id, verb: verb}
    Map.merge(acc, %{id => t, verb => t})
  end

end
