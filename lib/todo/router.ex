defmodule Todo.Router do
  use Plug.Router
  require Logger
  alias Todo.{Repo, Todo, Category}

  plug(Plug.Logger)
  plug(:match)
  plug(Plug.Parsers, parsers: [:json], json_decoder: Poison)
  plug(:dispatch)

  def take_result(result) do
    case result do
      {:ok, value} -> {200, value}
      _ -> {500, Poison.encode!(%{message: "internal error"})}
    end
  end

  def send_json_data({status, body}, conn) do
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(status, body)
  end

  get "/" do
    send_resp(conn, 200, Poison.encode!(%{message: "server is running"}))
  end

  get "/todo" do
    Todo.get_all()
    |> Enum.map(&Todo.encode/1)
    |> Poison.encode()
    |> take_result
    |> send_json_data(conn)
  end

  get "/todo/:id" do
    conn.params["id"]
    |> String.to_integer()
    |> Todo.get_by_id()
    |> Todo.encode()
    |> Poison.encode()
    |> take_result
    |> send_json_data(conn)
  end

  get "/todo/category/:id" do
    conn.params["id"]
    |> String.to_integer()
    |> Todo.get_by_category()
    |> Enum.map(&Todo.encode/1)
    |> Poison.encode()
    |> take_result
    |> send_json_data(conn)
  end

  get "/categories" do
    Category.get_all()
    |> Enum.map(&Category.encode/1)
    |> Poison.encode()
    |> take_result
    |> send_json_data(conn)
  end

  get "/category/:id" do
    conn.params["id"]
    |> String.to_integer()
    |> Category.get_by_id()
    |> Category.encode()
    |> Poison.encode()
    |> take_result
    |> send_json_data(conn)
  end

  post "/todo" do
    %{"title" => title} = conn.body_params

    category =
      if Map.has_key?(conn.body_params, :category) do
        conn.body_params
      else
        1
      end

    case title |> Todo.create(%Category{id: category}) |> take_result do
      {200, _} -> {200, Poison.encode!(%{message: "success"})}
      err -> err
    end
    |> send_json_data(conn)
  end

  post "/category" do
    %{"name" => name} = conn.body_params

    case name |> Category.create() |> take_result do
      {200, _} -> {200, Poison.encode!(%{message: "success"})}
      err -> err
    end
    |> send_json_data(conn)
  end

  put "/todo/:id" do
    conn.params["id"]
    |> String.to_integer()
    |> Todo.get_by_id()
    |> Todo.changeset(conn.body_params)
    |> Repo.update()
    |> take_result
    |> (&(case &1 do
            {200, t} ->
              t |> Todo.encode() |> Poison.encode() |> take_result

            err ->
              err
          end)).()
    |> send_json_data(conn)
  end

  put "/category/:id" do
    conn.params["id"]
    |> String.to_integer()
    |> Category.get_by_id()
    |> Category.changeset(conn.body_params)
    |> Repo.update()
    |> take_result
    |> (&(case &1 do
            {200, t} ->
              t |> Category.encode() |> Poison.encode() |> take_result

            err ->
              err
          end)).()
    |> send_json_data(conn)
  end

  delete "/todo/:id" do
    conn.params["id"]
    |> String.to_integer()
    |> Todo.delete()
    |> take_result
    |> (&(case &1 do
            {200, _} -> {200, Poison.encode!(%{message: "success"})}
            err -> err
          end)).()
    |> send_json_data(conn)
  end

  delete "/category/:id" do
    conn.params["id"]
    |> String.to_integer()
    |> Category.delete()
    |> take_result
    |> (&(case &1 do
            {200, _} -> {200, Poison.encode!(%{message: "success"})}
            err -> err
          end)).()
    |> send_json_data(conn)
  end

  match _ do
    send_resp(conn, 404, Poison.encode!(%{message: "not found"}))
  end
end
