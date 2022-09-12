defmodule Bonfire.Data.AccessControl.Accesses do
  @moduledoc """
  A Global cache of known accesses to be queried by their (Pointer) IDs
  or name strings.

  Use of the Accesses Service requires:

  1. Exporting `accesses/0` in relevant modules, returning a keylist of
     name and (pointer) id.
  2. Start `Bonfire.Data.AccessControl.Accesses` before querying.
  3. To populate `:bonfire_data_access_control, :search_path` in config the list of OTP applications where acceses are declared.
  4. OTP 21.2 or greater, though we recommend using the most recent
     release available.

  While this module is a GenServer, it is only responsible for setup
  of the cache and then exits with :ignore having done so. It is not
  recommended to restart the service as this will lead to a stop the
  world garbage collection of all processes and the copying of the
  entire cache to each process that has queried it since its last
  local garbage collection.
  """
  alias Bonfire.Data.AccessControl.Access

  use GenServer, restart: :transient

  @typedoc """
  A query is either a access name atom or (Pointer) id binary
  """
  @type query :: binary | atom

  @spec start_link(ignored :: term) :: GenServer.on_start()
  @doc "Populates the global cache with access data via introspection."
  def start_link(_), do: GenServer.start_link(__MODULE__, [])

  def data(), do: :persistent_term.get(__MODULE__)

  @spec access(query :: query) :: {:ok, Access.t()} | {:error, :not_found}
  @doc "Get a Access identified by name or id."
  def access(query) when is_binary(query) or is_atom(query) do
    case Map.get(data(), query) do
      nil -> {:error, :not_found}
      other -> {:ok, other}
    end
  end

  @spec access!(query) :: Access.t()
  @doc "Look up a Access by name or id, throw :not_found if not found."
  def access!(query), do: Map.get(data(), query) || throw(:not_found)

  @spec id(query) :: {:ok, integer()} | {:error, :not_found}
  @doc "Look up a access id by id, name or schema."
  def id(query), do: with({:ok, val} <- access(query), do: {:ok, val.id})

  @spec id!(query) :: integer()
  @doc "Look up a access id by id, name or schema, throw :not_found if not found."
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
      |> Enum.filter(&declares_accesses?/1)
      |> Enum.reduce(%{}, &index/2)

    :persistent_term.put(__MODULE__, indexed)
    :ignore
  end

  defp app_modules(app), do: app_modules(app, Application.spec(app, :modules))
  defp app_modules(_, nil), do: []
  defp app_modules(_, mods), do: mods

  # called by init/1
  defp search_path(),
    do: Application.fetch_env!(:bonfire_data_access_control, :search_path)

  # called by init/1
  defp declares_accesses?(module), do: function_exported?(module, :accesses, 0)

  # called by init/1
  defp index(mod, acc), do: index(mod, acc, mod.accesses())

  # called by index/2
  defp index(mod, acc, accesses) do
    Enum.reduce(accesses, acc, fn {k, v}, acc -> index(mod, acc, v, k) end)
  end

  # called by index/3
  defp index(_, acc, id, access) do
    Pointers.ULID.cast!(id)
    t = %Access{id: id}
    Map.merge(acc, %{id => t, access => t})
  end
end
