defmodule GithubUserSearchAppWeb.Search do
  @moduledoc false

  use GithubUserSearchAppWeb, :live_view
  alias GithubUserSearchApp.UsersAPI
  alias Phoenix.LiveView.JS

  def mount(_params, _session, socket) do
    # {:ok, user} = UsersAPI.fetch_user("octocat")
    user = dummy_user()
    form = to_form(%{"username" => ""})
    {:ok, assign(socket, user: user, form: form)}
  end

  def render(assigns) do
    ~H"""
    <div class="flex place-content-center">
      <div class="w-[327px] flex flex-col gap-4">
        <%!-- Header div --%>
        <div class="flex items-center justify-between">
          <h1 class="font-bold text-[#222731]">devfinder</h1>
          <button phx-click={toggle_dark_mode()}>
            <div id="dark-mode" class="hidden gap-2 text-[#FFFFFF]">
              <h2>LIGHT</h2>
              <.icon name="hero-sun-solid" />
            </div>
            <div id="light-mode" class="flex gap-2 text-[#4B6A9B]">
              <h2>DARK</h2>
              <.icon name="hero-moon-solid" />
            </div>
          </button>
        </div>

        <.search_form form={@form} />

        <div class="bg-[#FEFEFE] px-6 py-8 flex flex-col gap-4">
          <div class="flex gap-4">
            <img src={@user.avatar_url} class="w-[70px] h-[70px] rounded-full" />
            <div>
              <h2><%= @user.name %></h2>
              <p><%= "@#{@user.login}" %></p>
              <p><%= @user.created_at %></p>
            </div>
          </div>
          <p>
            <%= @user.bio %>
          </p>
          <div class="bg-[#F6F8FF] flex place-content-around">
            <div class="flex flex-col items-center justify-center">
              <p>Repos</p>
              <p><%= @user.public_repos %></p>
            </div>
            <div class="flex flex-col items-center justify-center">
              <p>Followers</p>
              <p><%= @user.followers %></p>
            </div>
            <div class="flex flex-col items-center justify-center">
              <p>Following</p>
              <p><%= @user.following %></p>
            </div>
          </div>
          <div class="flex flex-col gap-2 items-start justify-around text-[#4B6A9B]">
            <div class="flex gap-3">
              <.icon name="hero-map-pin-solid" />
              <p><%= @user.location %></p>
            </div>
            <div class="flex gap-3 items-center">
              <.icon name="hero-link-solid" />
              <.link navigate={@user.blog}>
                <%= @user.blog %>
              </.link>
            </div>
            <div class="flex gap-3 items-center">
              <.icon name="hero-x-mark" />
              <.link navigate={"https://x.com/#{@user.twitter_username}"}>
                <%= "@#{@user.twitter_username}" %>
              </.link>
            </div>
            <div class="flex gap-3 items-center">
              <.icon name="hero-building-office-2-solid" />
              <.link navigate={"https://github.com/#{@user.login}"}>
                <%= "#{@user.company}" %>
              </.link>
            </div>
          </div>
        </div>
      </div>
    </div>
    """
  end

  def search_form(assigns) do
    ~H"""
    <div class="bg-[#FEFEFE]">
      <.form for={@form} id="search-user" phx-submit="search-user" class="flex items-center">
        <.icon name="hero-magnifying-glass-solid" />
        <.input field={@form[:username]} autocomplete="off" placeholder="Search GitHub username…" />
        <.button phx-disable-with="Searching...">
          Search
        </.button>
      </.form>
    </div>
    """
  end

  def handle_event("search-user", %{"username" => username}, socket) do
    case UsersAPI.fetch_user(username) do
      {:ok, user} ->
        form = to_form(%{"username" => ""})
        socket = put_flash(socket, :info, "User successfully fetched!")
        {:noreply, assign(socket, user: user, form: form)}

      {:error, error} ->
        form = to_form(%{"username" => ""})
        socket = put_flash(socket, :error, error)
        {:noreply, assign(socket, form: form)}
    end
  end

  defp toggle_dark_mode do
    JS.dispatch("toogle-darkmode")
    |> JS.toggle(to: "#dark-mode", display: "flex")
    |> JS.toggle(to: "#light-mode", display: "flex")
  end

  defp dummy_user do
    %{
      avatar_url: "https://avatars.githubusercontent.com/u/30313228?v=4",
      bio: "I'm enthusiastic about Erlang/Elixir and love building with OTP.
        Currently, I'm learning Elixir, Phoenix, Alpine.js, TailwindCSS,
        and LiveView.",
      blog: "https://ayikoyo.com",
      company: "@github",
      created_at: "2017-07-20T08:37:32Z",
      followers: 11_497,
      following: 9,
      html_url: "https://github.com/lgmfred",
      location: "::1, Ouganda",
      login: "lgmfred",
      name: "Ayiko Fred",
      public_repos: 33,
      twitter_username: "lgmfred"
    }
  end
end
