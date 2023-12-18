defmodule GithubUserSearchApp.UsersAPI do
  @moduledoc false

  @callback fetch_user(binary()) :: {:ok, map()} | {:error, binary()}

  def fetch_user(username), do: impl().fetch_user(username)

  defp impl do
    Application.get_env(
      :github_user_search_app,
      :users_api_client_module,
      GithubUserSearchApp.ExternalUsersAPI
    )
  end
end
