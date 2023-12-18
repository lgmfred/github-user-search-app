defmodule GithubUserSearchApp.ExternalUsersAPI do
  @moduledoc """
  An implementation of a GithubUserSearchApp.UserApiBehaviour
  """
  require Logger

  @behaviour GithubUserSearchApp.UsersAPI

  @base_url "api.github.com"

  @spec fetch_user(binary()) :: {:ok, map()} | {:error, binary()}

  def fetch_user(username) when is_binary(username) do
    url = "https://#{@base_url}/users/#{username}"
    Logger.info("[GitHub API] GET #{url}")

    build_req = Finch.build(:get, url)

    case Finch.request(build_req, GithubUserSearchApp.Finch) do
      {:ok, %Finch.Response{status: 200, body: body}} ->
        IO.inspect(body, label: "Body")
        response = Jason.decode!(body, keys: :atoms)
        Logger.info("[GitHub API] Success: #{inspect(response)}")
        {:ok, response}

      {:ok, %Finch.Response{status: 404, body: _body}} ->
        Logger.warning("[GitHub API] Error 404: User Not found")
        {:error, :user_not_found}

      {:ok, %Finch.Response{status: 403, body: _body}} ->
        Logger.info("[GitHub API] Error: Rate limit exceeded")
        {:error, :rate_limit_exceeded}

      {:error, exception} ->
        Logger.error("[GitHub API] Exception: #{inspect(exception)}")
        {:error, :exception}
    end
  end
end
