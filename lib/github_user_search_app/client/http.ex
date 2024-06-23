defmodule GithubUserSearchApp.Client.Http do
  @moduledoc """
  @moduledoc false
  """

  @behaviour GithubUserSearchApp.Client.Client

  alias GithubUserSearchApp.Client.Http

  @base_url "https://api.github.com/users/"

  @impl GithubUserSearchApp.Client.Client
  def fetch_user(username) do
    :get
    |> Finch.build(@base_url <> username)
    |> Finch.request(Http)
    |> handle_response()
  end

  defp handle_response({:ok, %Finch.Response{status: 200, body: body}}) do
    response = Jason.decode!(body)
    {:ok, response}
  end

  defp handle_response({:ok, %Finch.Response{status: 404, body: body}}) do
    response = Jason.decode!(body)
    {:error, response["message"]}
  end

  defp handle_response({:ok, %Finch.Response{status: 403, body: body}}) do
    response = Jason.decode!(body)
    {:error, response["message"]}
  end

  defp handle_response({:error, reason}) do
    {:error, reason}
  end
end
