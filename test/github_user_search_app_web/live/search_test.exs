defmodule GithubUserSearchAppWeb.SearchTest do
  use GithubUserSearchAppWeb.ConnCase

  import Phoenix.LiveViewTest

  import Mox

  @mock_module Application.compile_env(:github_user_search_app, :api_client)
  @dummy_user %{
    "avatar_url" => "https://avatars.githubusercontent.com/u/30313228?v=4",
    "bio" => "Mediocre erl/iex necromancer with eventually consistent opinions.",
    "blog" => "https://ayikoyo.com",
    "company" => nil,
    "created_at" => "2017-07-20T08:37:32Z",
    "followers" => 11,
    "following" => 7,
    "html_url" => "https://github.com/lgmfred",
    "location" => "::1, Ouganda",
    "login" => "lgmfred",
    "name" => "Ayiko Fred",
    "public_repos" => 39,
    "twitter_username" => "lgmfred"
  }

  setup :verify_on_exit!

  describe "/" do
    test "user can render the default home page in connected state", %{conn: conn} do
      {:ok, view, html} = live(conn, ~p"/")

      assert has_element?(view, ~s(input[placeholder*="Search GitHub username..."]))
      assert has_element?(view, "button", "Search")

      assert html =~ "The Octocat"
      assert html =~ "This profile has no bio"
    end

    test "No results: click submit with empty input field", %{conn: conn} do
      {:ok, view, html} = live(conn, ~p"/")

      refute html =~ "No results"

      html =
        view
        |> form("#search-user")
        |> render_submit()

      assert html =~ "No results"
    end

    test "Success: search for an existing github user", %{conn: conn} do
      expect(@mock_module, :fetch_user, fn _username ->
        {:ok, @dummy_user}
      end)

      {:ok, view, _html} = live(conn, ~p"/")

      view
      |> form("#search-user", %{"username" => @dummy_user["login"]})
      |> render_submit()

      assert has_element?(view, "input", "")
      assert has_element?(view, ~s(img[src*="#{@dummy_user["avatar_url"]}"]))
      assert has_element?(view, ~s(a[href*="#{@dummy_user["blog"]}"]))

      assert render(view) =~ @dummy_user["name"]
      assert render(view) =~ @dummy_user["location"]
    end

    test "No results: search for a non existing github user", %{conn: conn} do
      expect(@mock_module, :fetch_user, fn _username ->
        {:error, "Not Found"}
      end)

      {:ok, view, html} = live(conn, ~p"/")

      refute html =~ "No results"

      new_html =
        view
        |> form("#search-user", %{"username" => "@lgm-non-existing-user"})
        |> render_submit()

      assert new_html =~ "No results"
      assert new_html =~ "The Octocat"
      assert new_html =~ "San Francisco"
    end
  end
end
