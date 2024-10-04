defmodule GithubUserSearchApp.Client.Client do
  @moduledoc false

  alias GithubUserSearchApp.Client.Http

  @callback fetch_user(binary()) :: {:ok, map()} | {:error, binary()}

  def fetch_user(username), do: impl().fetch_user(username)

  defp impl, do: Application.get_env(:github_user_search_app, :api_client, Http)
end
