defmodule Todo.Todo do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query
  alias Todo.Repo

  schema "todo" do
    field(:title, :string)
    field(:done, :boolean, defualt: false)
    belongs_to(:category, Todo.Category)
  end

  def encode(struct) do
    %{
      id: struct.id,
      title: struct.title,
      done: struct.done,
      category: struct.category.name
    }
  end

  def create(title, category) do
    Ecto.build_assoc(category, :todo, %{title: title})
    |> changeset(%{title: title})
    |> Repo.insert()
  end

  def delete(id) do
    id
    |> get_by_id
    |> Repo.delete()
  end

  def changeset(struct, params) do
    struct
    |> cast(params, [:title, :done, :category_id])
    |> validate_required(:title)
    |> validate_category
  end

  defp validate_category(changeset) do
    category_id = get_field(changeset, :category_id)

    if Todo.Category.exists?(category_id) do
      changeset
    else
      add_error(changeset, :category_id, "not exists category")
    end
  end

  defp preload_query(query) do
    query
    |> join(:inner, [t], c in assoc(t, :category))
    |> preload([t, c], category: c)
  end

  def get_all do
    Todo.Todo
    |> preload_query()
    |> Repo.all()
  end

  def get_by_id(id) do
    Todo.Todo
    |> where([t], t.id == ^id)
    |> preload_query()
    |> first()
    |> Repo.one()
  end

  def get_by_category(cid) do
    Todo.Todo
    |> where([t], t.category_id == ^cid)
    |> preload_query()
    |> Repo.all()
  end
end
