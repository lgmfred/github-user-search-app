defmodule GithubUserSearchApp.Client.HttpTest do
  use ExUnit.Case, async: true

  import Mox

  alias GithubUserSearchApp.Client.Client
  alias GithubUserSearchApp.Client.Mock

  setup :verify_on_exit!

  describe "fetch_user/1" do
    test "success: fetch_user, returns user data for existing user" do
      valid_user = %{
        "location" => "::1, Ouganda",
        "login" => "lgmfred",
        "name" => "Ayiko Fred",
        "twitter_username" => "lgmfred",
        "blog" => "https://ayikoyo.com"
      }

      expect(Mock, :fetch_user, fn _username ->
        {:ok, valid_user}
      end)

      assert {:ok, ^valid_user} = Client.fetch_user("lgmfred")
    end

    test "error: fetch_user, returns {:error, :user_not_found} for non-existing user" do
      expect(Mock, :fetch_user, fn _username ->
        {:error, "Not Found"}
      end)

      assert {:error, "Not Found"} = Client.fetch_user("lgmfred-le-meilleur")
    end

    test "error: fetch_user, returns {:error, :exception} during fetch process" do
      expect(Mock, :fetch_user, fn _username ->
        {:error, :exception}
      end)

      assert {:error, :exception} = Client.fetch_user("exception_user")
    end
  end
end
