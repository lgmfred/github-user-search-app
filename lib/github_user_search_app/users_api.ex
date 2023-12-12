defmodule GithubUserSearchApp.UsersApi do
  @moduledoc """
  An implementation of a GithubUserSearchApp.UserApiBehaviour
  """
  require Logger

  alias GithubUserSearchApp.UserApiBehaviour
  @behaviour UserApiBehaviour

  @base_url "api.github.com"

  @impl UserApiBehaviour

  @spec fetch_user(binary()) :: {:ok, map()} | {:error, binary()}

  def fetch_user(username) when is_binary(username) do
    url = "https://#{@base_url}/users/#{username}"
    Logger.info("[GitHub API] GET #{url}")

    build_req = Finch.build(:get, url)

    case Finch.request(build_req, GithubUserSearchApp.Finch) do
      {:ok, %Finch.Response{status: 200, body: body}} ->
        response = Jason.decode!(body, keys: :atoms)
        Logger.info("[GitHub API] Success: #{inspect(response)}")

        {:ok, response}

      {:ok, %Finch.Response{status: 404, body: _body}} ->
        Logger.warning("[GitHub API] Error 404: User Not found")

        {:error, :user_not_found}

      {:error, exception} ->
        Logger.error("[GitHub API] Exception: #{inspect(exception)}")
        {:error, :exception}
    end
  end
end
