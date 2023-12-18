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
        response = Jason.decode!(body, keys: :atoms)
        Logger.info("[GitHub API] OK 200: #{inspect(response)}")
        {:ok, response}

      {:ok, %Finch.Response{status: 404, body: body}} ->
        response = Jason.decode!(body, keys: :atoms)
        Logger.warning("[GitHub API] Error 404: #{response.message}")
        {:error, response.message}

      {:ok, %Finch.Response{status: 403, body: body}} ->
        response = Jason.decode!(body, keys: :atoms)
        Logger.info("[GitHub API] Error 403: #{response.message}")
        {:error, response.message}

      {:error, exception} ->
        Logger.error("[GitHub API] Exception: #{inspect(exception)}")
        {:error, "An exception occurred!"}
    end
  end
end
