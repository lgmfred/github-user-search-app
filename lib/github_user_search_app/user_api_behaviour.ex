defmodule GithubUserSearchApp.UserApiBehaviour do
  @moduledoc false

  @callback fetch_user(binary()) :: {:ok, map()} | {:error, binary()}
end
