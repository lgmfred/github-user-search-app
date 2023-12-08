defmodule GithubUserSearchAppWeb.Search do
  use GithubUserSearchAppWeb, :live_view

  def mount(_params, _session, socket) do
    form = to_form(%{"username" => ""})
    {:ok, assign(socket, form: form)}
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
          <div>
            <img src="" alt="" />
            <div>
              <h2>The Octocat</h2>
              <p>@octocat</p>
              <p>Joined 25 Jan 2011</p>
            </div>
          </div>
          <p>
            Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Donec odio. Quisque volutpat mattis eros.
          </p>
          <div class="bg-[#F6F8FF] flex place-content-around">
            <div class="flex flex-col items-center justify-center">
              <p>Repos</p>
              <p>8</p>
            </div>
            <div class="flex flex-col items-center justify-center">
              <p>Followers</p>
              <p>3938</p>
            </div>
            <div class="flex flex-col items-center justify-center">
              <p>Following</p>
              <p>9</p>
            </div>
          </div>
          <div class="flex flex-col gap-2 items-start justify-around text-[#4B6A9B]">
            <div class="flex gap-3">
              <.icon name="hero-map-pin-solid" />
              <p>San Francisco</p>
            </div>
            <div class="flex gap-3 items-center">
              <.icon name="hero-link-solid" />
              <p>https://github.blog</p>
            </div>
            <div class="flex gap-3 items-center">
              <.icon name="hero-x-mark" />
              <p>Not Available</p>
            </div>
            <div class="flex gap-3 items-center">
              <.icon name="hero-building-office-2-solid" />
              <p>@github</p>
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
      <.form for={@form} class="flex items-center">
        <.icon name="hero-magnifying-glass-solid" />
        <.input field={@form[:username]} autocomplete="off" placeholder="Search GitHub username…" />
        <.button>
          Search
        </.button>
      </.form>
    </div>
    """
  end
end
