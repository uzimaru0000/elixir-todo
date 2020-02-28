defmodule Todo.Category do
  use Ecto.Schema
  import Ecto.Query
  import Ecto.Changeset
  alias Todo.Repo

  schema "category" do
    field(:name, :string)
    has_many(:todo, Todo.Todo)
  end

  def encode(struct) do
    %{
      id: struct.id,
      name: struct.name
    }
  end

  def create(name) do
    %Todo.Category{name: name}
    |> changeset(%{name: name})
    |> Repo.insert()
  end

  def delete(id) do
    get_by_id(id)
    |> Repo.delete()
  end

  def get_all do
    Todo.Category
    |> Repo.all()
  end

  def get_by_id(id) do
    Todo.Category
    |> Repo.get(id)
  end

  def exists?(id) do
    Todo.Category
    |> where([c], c.id == ^id)
    |> Repo.exists?()
  end

  def changeset(struct, params) do
    struct
    |> cast(params, [:name])
    |> validate_required(:name)
  end
end
