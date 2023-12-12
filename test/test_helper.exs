Mox.defmock(GithubUserSearchApp.UsersApiMock,
  for: GithubUserSearchApp.UserApiBehaviour
)

Application.put_env(:github_user_search_app, :users_api_client, GithubUserSearchApp.UsersApiMock)

ExUnit.start()
