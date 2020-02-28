import Config

config :todo, Todo.Repo,
  database: "todo_repo",
  username: "user",
  password: "pass",
  hostname: "localhost",
  port: "5432"

config :todo, ecto_repos: [Todo.Repo]
