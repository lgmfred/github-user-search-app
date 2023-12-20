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
          <h1 class="font-bold text-[#222731] dark:text-[#FFFFFF]">devfinder</h1>
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

        <div class="bg-[#FEFEFE] dark:bg-[#1E2A47] px-6 py-8 flex flex-col gap-4">
          <div class="flex gap-4">
            <img src={@user.avatar_url} class="w-[70px] h-[70px] rounded-full" />
            <div>
              <h2 class="text-#2B3442 dark:text-[#FFFFFF]">
                <%= if @user.name, do: @user.name, else: @user.login %>
              </h2>
              <p class="text-[#0079FF]"><%= "@#{@user.login}" %></p>
              <p class="text-[#697C9A] dark:text-[#FFFFFF]">
                <%= "Joined #{format_date(@user.created_at)}" %>
              </p>
            </div>
          </div>
          <p class="text-[#4B6A9B] dark:text-[#FFFFFF]">
            <%= if @user.bio, do: @user.bio, else: "This profile has no bio" %>
          </p>
          <div class="bg-[#F6F8FF] dark:bg-[#141D2F] flex place-content-around">
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
          <div class="flex flex-col gap-2 items-start justify-around text-[#4B6A9B] dark:text-[#FFFFFF]">
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
    <div class="bg-[#FEFEFE] dark:bg-[#1E2A47]">
      <.form for={@form} id="search-user" phx-submit="search-user" class="flex items-center">
        <.icon name="hero-magnifying-glass-solid" class="text-[#0079FF]" />
        <.input
          field={@form[:username]}
          autocomplete="off"
          placeholder="Search GitHub username…"
          class="placeholder:text-[#4B6A9B] dark:placeholder:text-[#FFFFFF]"
        />
        <.button phx-disable-with="Searching..." class="text-[#FFFFFF] bg-[#0079FF]">
          Search
        </.button>
      </.form>
    </div>
    """
  end

  attr :stat, :string, required: true
  attr :figure, :integer, required: true

  defp stats(assigns) do
    ~H"""
    <div class="flex flex-col items-center justify-center text-[#4B6A9B] dark:text-[#FFFFFF]">
      <p class="text-[#4B6A9B] dark:text-[#FFFFFF]"><%= @stat %></p>
      <p class="text-[#2B3442] dark:text-[#FFFFFF]"><%= @figure %></p>
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
        <.icon name={@icon_name} />
        <p>Not Available</p>
      <% end %>
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
