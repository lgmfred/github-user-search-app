defmodule GithubUserSearchAppWeb.Search do
  @moduledoc false

  alias GithubUserSearchApp.Client
  use GithubUserSearchAppWeb, :live_view

  alias GithubUserSearchApp.Client.Client
  alias Phoenix.LiveView.JS

  def mount(_params, _session, socket) do
    {:ok, user} = fetch_initial_render_user()
    form = to_form(%{"username" => ""})

    {:ok,
     socket
     |> assign(:error, false)
     |> assign(:form, form)
     |> assign(:user, user)}
  end

  def render(assigns) do
    ~H"""
    <div class="flex place-content-center font-normal text-sm md:text-base leading-6 md:leading-9">
      <div class="flex flex-col gap-4 max-w-xs md:max-w-2xl lg:max-w-3xl">
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
          class="gap-4 rounded-lg bg-[#FEFEFE] dark:bg-[#1E2A47] px-6 md:px-10 py-8"
        >
          <img
            id="user-avatar"
            src={@user["avatar_url"]}
            class="w-16 md:w-20 h-16 md:h-20 rounded-full"
          />
          <div
            id="user-identity"
            class="flex flex-col md:-ml-16 lg:ml-0 lg:flex-row lg:justify-between"
          >
            <div class="flex flex-col">
              <h2
                id="user-name"
                class="text-base md:text-2xl font-bold text-#2B3442 dark:text-[#FFFFFF]"
              >
                <%= if @user["name"], do: @user["name"], else: @user["login"] %>
              </h2>
              <p id="user-login" class="text-[#0079FF]"><%= "@#{@user["login"]}" %></p>
            </div>
            <p id="user-created-at" class="text-[#697C9A] dark:text-[#FFFFFF]">
              <%= "Joined #{format_date(@user["created_at"])}" %>
            </p>
          </div>
          <p id="user-bio" class="font-normal text-sm text-[#4B6A9B] dark:text-[#FFFFFF]">
            <%= if @user["bio"], do: @user["bio"], else: "This profile has no bio" %>
          </p>
          <div id="user-stats" class="bg-[#F6F8FF] dark:bg-[#141D2F] flex rounded-lg p-4">
            <.stats
              :for={
                {stat, figure} <- [
                  {"Repo", @user["public_repos"]},
                  {"Followers", @user["followers"]},
                  {"Following", @user["following"]}
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
                  {"hero-map-pin-solid", @user["location"], nil},
                  {"hero-link-solid", @user["blog"], @user["blog"]},
                  {"hero-x-mark", @user["twitter_username"],
                   "https://x.com/#{@user["twitter_username"]}"},
                  {"hero-building-office-2-solid", @user["company"],
                   "https://github.com/#{@user["company"]}"}
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
          <span class="text-[#0079FF]">
            <.icon name="hero-magnifying-glass" />
          </span>
        </div>
        <input
          type="text"
          name="username"
          id="username"
          class="block w-full h-14 rounded-md border-0 py-1.5 pl-12 pr-12 text-gray-900 dark:text-white dark:bg-[#1E2A47] ring-0 placeholder:text-gray-400 focus:ring-1 focus:ring-inset focus:ring-gray-300 text-xs md:text-sm lg:text-base sm:leading-6"
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
        <a href={@link} class="hover:underline">
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
    {:noreply, assign(socket, :error, "No results")}
  end

  def handle_event("search-user", %{"username" => username}, socket) do
    case Client.fetch_user(username) do
      {:ok, user} ->
        form = to_form(%{"username" => ""})

        {:noreply,
         socket
         |> assign(:error, nil)
         |> assign(:form, form)
         |> assign(:user, user)
         |> put_flash(:info, "User successfully fetched!")}

      {:error, error} ->
        form = to_form(%{"username" => ""})

        {:noreply,
         socket
         |> assign(:error, "No results")
         |> assign(:form, form)
         |> put_flash(:error, error)}
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

  defp fetch_initial_render_user do
    case Mix.env() do
      :test -> {:ok, dummy_user()}
      _any -> Client.fetch_user("octocat")
    end
  end

  defp dummy_user do
    %{
      "avatar_url" => "https://avatars.githubusercontent.com/u/583231?v=4",
      "bio" => nil,
      "blog" => "https://github.blog",
      "company" => "@github",
      "created_at" => "2011-01-25T18:44:36Z",
      "followers" => 13_935,
      "following" => 9,
      "html_url" => "https://github.com/octocat",
      "location" => "San Francisco",
      "login" => "octocat",
      "name" => "The Octocat",
      "public_repos" => 8,
      "twitter_username" => nil
    }
  end
end
