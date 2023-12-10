defmodule GithubUserSearchApp.UsersApiTest do
  use ExUnit.Case

  alias GithubUserSearchApp.UsersApiMock
  import Mox

  setup :verify_on_exit!

  describe "fetch_user/1" do
    test "success: fetch_user, returns user data for existing user" do
      Mox.expect(UsersApiMock, :fetch_user, fn username ->
        assert username == "lgmfred"

        response = %{
          location: "::1, Ouganda",
          login: "lgmfred",
          name: "Ayiko Fred",
          twitter_username: "lgmfred",
          blog: "https://ayikoyo.com"
        }

        {:ok, response}
      end)

      assert UsersApiMock.fetch_user("lgmfred")
    end
  end

  test "success: fetch_user, returns {:error, :user_not_found} for non-existing user" do
    Mox.expect(UsersApiMock, :fetch_user, fn username ->
      assert username == "lgmfred-le-meilleur"

      {:error, :user_not_found}
    end)

    assert UsersApiMock.fetch_user("lgmfred-le-meilleur")
  end
end
