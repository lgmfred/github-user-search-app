Mox.defmock(GithubUserSearchApp.MockUsersAPI, for: GithubUserSearchApp.UsersAPI)

Application.put_env(
  :github_user_search_app,
  :users_api_client_module,
  GithubUserSearchApp.MockUsersAPI
)

ExUnit.start()
