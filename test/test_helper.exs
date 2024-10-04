Mox.defmock(GithubUserSearchApp.Client.Mock, for: GithubUserSearchApp.Client.Client)

Application.put_env(
  :github_user_search_app,
  :api_client,
  GithubUserSearchApp.Client.Mock
)

ExUnit.start()
