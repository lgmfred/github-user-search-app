defmodule GithubUserSearchAppWeb.CustomComponents do
  @moduledoc """
    Provides core UI components.
  """
  use Phoenix.Component

  def input(assigns) do
    ~H"""
    <div phx-feedback-for={@name} class="w-full">
      <input type={@type} name={@name} id={@id} placeholder={@placeholder} class={@custom_class} />
    </div>
    """
  end
end
