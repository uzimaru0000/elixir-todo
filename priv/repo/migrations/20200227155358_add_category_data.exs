defmodule Todo.Repo.Migrations.AddCategoryData do
  use Ecto.Migration
  alias Todo.Category

  def change do
    repo().insert(%Category{name: "none"})
  end
end
