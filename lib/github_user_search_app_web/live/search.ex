defmodule GithubUserSearchAppWeb.Search do
  @moduledoc false

  use GithubUserSearchAppWeb, :live_view
  alias GithubUserSearchApp.UsersApi

  def mount(_params, _session, socket) do
    {:ok, user} = UsersApi.fetch_user("octocat")
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
          <div class="flex text-[#4B6A9B]">
            <h2>DARK</h2>
            <.icon name={if false, do: "hero-sun-solid", else: "hero-moon-solid"} />
          </div>
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
                <%= "@#{@user.company}" %>
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
      <.form for={@form} phx-submit="search-user" class="flex items-center">
        <.icon name="hero-magnifying-glass-solid" />
        <.input field={@form[:username]} autocomplete="off" placeholder="Search GitHub username…" />
        <.button>
          Search
        </.button>
      </.form>
    </div>
    """
  end

  def handle_event("search-user", %{"username" => username}, socket) do
    case UsersApi.fetch_user(username) do
      {:ok, user} ->
        form = to_form(%{"username" => ""})
        {:noreply, assign(socket, user: user, form: form)}

      {:error, _error} ->
        form = to_form(%{"username" => ""})
        {:noreply, assign(socket, form: form)}
    end
  end
end
