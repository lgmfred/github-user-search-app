defmodule GithubUserSearchAppWeb.SearchTest do
  use GithubUserSearchAppWeb.ConnCase

  import Phoenix.LiveViewTest

  import Mox

  @mock_module Application.compile_env(:github_user_search_app, :users_api_client_module)

  test "rendering default page in connected state", %{conn: conn} do
    {:ok, view, html} = live(conn, ~p"/")

    assert has_element?(view, ~s(input[placeholder*="Search GitHub username..."]))
    assert has_element?(view, "button", "Search")
    assert has_element?(view, ~s(a[href*="https://ayikoyo.com"]))

    assert html =~ "Ayiko Fred"
    assert html =~ "enthusiastic about Erlang/Elixir and love building with OTP."
  end

  describe "user can search for a GitHub user" do
    setup :verify_on_exit!

    test "Success: search for an existing github user", %{conn: conn} do
      user = dummy_existing_user()

      expect(@mock_module, :fetch_user, fn username ->
        assert username == "ferd"

        {:ok, user}
      end)

      {:ok, view, _html} = live(conn, ~p"/")

      view
      |> form("#search-user", %{"username" => user.login})
      |> render_submit()

      assert has_element?(view, "input", "")
      assert has_element?(view, ~s(img[src*="#{user.avatar_url}"]))
      assert has_element?(view, ~s(a[href*="#{user.blog}"]))

      assert render(view) =~ user.name
      assert render(view) =~ user.location
    end

    defp dummy_existing_user do
      %{
        avatar_url: "https://avatars.githubusercontent.com/u/111141?v=4",
        bio: nil,
        blog: "https://ferd.ca",
        company: nil,
        created_at: "2009-08-02T17:50:24Z",
        followers: 1227,
        following: 23,
        html_url: "https://github.com/ferd",
        location: "Saguenay, Qc, Canada",
        login: "ferd",
        name: "Fred Hebert",
        public_repos: 128,
        twitter_username: nil
      }
    end
  end
end
