defmodule GithubUserSearchApp.UsersApiTest do
  use ExUnit.Case, async: true

  alias GithubUserSearchApp.UsersApiMock
  import Mox

  setup :verify_on_exit!

  describe "fetch_user/1" do
    test "success: fetch_user, returns user data for existing user" do
      response = %{
        location: "::1, Ouganda",
        login: "lgmfred",
        name: "Ayiko Fred",
        twitter_username: "lgmfred",
        blog: "https://ayikoyo.com"
      }

      expect(UsersApiMock, :fetch_user, fn username ->
        assert username == "lgmfred"

        {:ok, response}
      end)

      assert {:ok, ^response} = users_api_client().fetch_user("lgmfred")
    end

    test "error: fetch_user, returns {:error, :user_not_found} for non-existing user" do
      expect(UsersApiMock, :fetch_user, fn username ->
        assert username == "lgmfred-le-meilleur"

        {:error, :user_not_found}
      end)

      assert {:error, :user_not_found} = users_api_client().fetch_user("lgmfred-le-meilleur")
    end

    test "error: fetch_user, returns {:error, :exception} during fetch process" do
      expect(UsersApiMock, :fetch_user, fn username ->
        assert username == "exception_user"
        {:error, :exception}
      end)

      assert {:error, :exception} = users_api_client().fetch_user("exception_user")
    end
  end
end
