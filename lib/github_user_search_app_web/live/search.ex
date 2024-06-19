defmodule GithubUserSearchAppWeb.Search do
  @moduledoc false

  use GithubUserSearchAppWeb, :live_view

  alias GithubUserSearchApp.UsersAPI
  alias Phoenix.LiveView.JS

  def mount(_params, _session, socket) do
    # {:ok, user} = UsersAPI.fetch_user("octocat")
    user = dummy_user()
    form = to_form(%{"username" => ""})
    {:ok, assign(socket, user: user, form: form, error: false)}
  end

  def render(assigns) do
    ~H"""
    <div class="flex place-content-center font-normal text-sm md:text-base leading-6 md:leading-9">
      <div class="w-[327px] md:w-[648px] flex flex-col gap-4">
        <%!-- Header div --%>
        <div class="flex items-center justify-between">
          <h1 class="font-bold text-2xl text-[#222731] dark:text-[#FFFFFF]">devfinder</h1>
          <button phx-click={toggle_dark_mode()}>
            <div id="dark-mode" class="hidden gap-2 text-sm text-[#FFFFFF]">
              <h2>LIGHT</h2>
              <.icon name="hero-sun-solid" />
            </div>
            <div id="light-mode" class="flex gap-2 text-sm text-[#4B6A9B]">
              <h2>DARK</h2>
              <.icon name="hero-moon-solid" />
            </div>
          </button>
        </div>

        <.search_form form={@form} error={@error} />

        <div
          id="user-profile"
          class="rounded-lg bg-[#FEFEFE] dark:bg-[#1E2A47] px-6 md:px-10 py-8 flex flex-col gap-6"
        >
          <img
            id="user-avatar"
            src={@user.avatar_url}
            class="w-[70px] md:w-[117px] h-[70px] md:h-[117px]  rounded-full"
          />
          <div id="user-identity">
            <h2
              id="user-name"
              class="text-base md:text-2xl font-bold text-#2B3442 dark:text-[#FFFFFF]"
            >
              <%= if @user.name, do: @user.name, else: @user.login %>
            </h2>
            <p id="user-login" class="text-[#0079FF]"><%= "@#{@user.login}" %></p>
            <p id="user-created-at" class="text-[#697C9A] dark:text-[#FFFFFF]">
              <%= "Joined #{format_date(@user.created_at)}" %>
            </p>
          </div>
          <p id="user-bio" class="font-normal text-sm text-[#4B6A9B] dark:text-[#FFFFFF]">
            <%= if @user.bio, do: @user.bio, else: "This profile has no bio" %>
          </p>
          <div id="user-stats" class="bg-[#F6F8FF] dark:bg-[#141D2F] flex rounded-lg p-[18px]">
            <.stats
              :for={
                {stat, figure} <- [
                  {"Repo", @user.public_repos},
                  {"Followers", @user.followers},
                  {"Following", @user.following}
                ]
              }
              stat={stat}
              figure={figure}
            />
          </div>
          <div
            id="user-links"
            class="font-normal text-sm grid gap-3  md:grid-cols-2 justify-item-start text-[#4B6A9B] dark:text-[#FFFFFF]"
          >
            <.profile_links
              :for={
                {icon, text, link} <- [
                  {"hero-map-pin-solid", @user.location, nil},
                  {"hero-link-solid", @user.blog, @user.blog},
                  {"hero-x-mark", @user.twitter_username, "https://x.com/#{@user.twitter_username}"},
                  {"hero-building-office-2-solid", @user.company,
                   "https://github.com/#{@user.company}"}
                ]
              }
              icon_name={icon}
              text={text}
              link={link}
            >
              <%= text %>
            </.profile_links>
          </div>
        </div>
      </div>
    </div>
    """
  end

  def search_form(assigns) do
    ~H"""
    <.form for={@form} id="search-user" phx-submit="search-user">
      <label for="username" class="sr-only block text-sm font-medium leading-6 text-gray-900">
        Price
      </label>
      <div class="relative mt-2 rounded-full shadow-sm">
        <div class="pointer-events-none absolute inset-y-0 left-0 flex items-center pl-3">
          <span class="text-[#0079FF] sm:text-sm">
            <.icon name="hero-magnifying-glass" />
          </span>
        </div>
        <input
          type="text"
          name="username"
          id="username"
          class="block w-full h-14 rounded-md border-0 py-1.5 pl-12 pr-12 text-gray-900 dark:text-white dark:bg-[#1E2A47] ring-0 placeholder:text-gray-400 focus:ring-1 focus:ring-inset focus:ring-gray-300 sm:text-sm sm:leading-6"
          placeholder="Search GitHub username..."
          aria-describedby="github-username"
        />

        <div class="absolute flex inset-y-0 right-0 flex py-1.5 pr-1.5">
          <span :if={@error} class="flex items-center font-bold mr-4 text-[#F74646]">
            No results
          </span>
          <button class="inline-flex items-center bg-[#0079FF] rounded-lg px-4 font-bold text-white">
            Search
          </button>
        </div>
      </div>
    </.form>
    """
  end

  attr :stat, :string, required: true
  attr :figure, :integer, required: true

  defp stats(assigns) do
    ~H"""
    <div class="flex flex-col flex-1 items-center md:items-start text-[#4B6A9B] dark:text-[#FFFFFF]">
      <p class="text-xs text-[#4B6A9B] dark:text-[#FFFFFF]"><%= @stat %></p>
      <p class="text-base font-bold text-[#2B3442] dark:text-[#FFFFFF]"><%= @figure %></p>
    </div>
    """
  end

  attr :icon_name, :string, required: true
  attr :text, :string, required: true
  attr :link, :string, required: true
  slot :inner_block, required: true

  defp profile_links(assigns) do
    ~H"""
    <div class="flex gap-3 items-center">
      <%= if @text do %>
        <.icon name={@icon_name} />
        <a href={@link}>
          <%= render_slot(@inner_block) %>
        </a>
      <% else %>
        <.icon name={@icon_name} class="opacity-50" />
        <p class="opacity-50">Not Available</p>
      <% end %>
    </div>
    """
  end

  def handle_event("search-user", %{"username" => ""}, socket) do
    {:noreply, assign(socket, error: "No results")}
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
        {:noreply, assign(socket, form: form, error: "No results")}
    end
  end

  defp toggle_dark_mode do
    JS.dispatch("toogle-darkmode")
    |> JS.toggle(to: "#dark-mode", display: "flex")
    |> JS.toggle(to: "#light-mode", display: "flex")
  end

  defp format_date(date) do
    {:ok, utc_time, _int} = DateTime.from_iso8601(date)

    utc_time
    |> DateTime.to_date()
    |> Timex.format!("{D} {Mshort} {YYYY}")
  end

  defp dummy_user do
    %{
      avatar_url: "https://avatars.githubusercontent.com/u/30313228?v=4",
      bio: "I'm enthusiastic about Erlang/Elixir and love building with OTP.
        Currently, I'm learning Elixir, Phoenix, Alpine.js, TailwindCSS,
        and LiveView.",
      blog: "https://ayikoyo.com",
      company: nil,
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
