defmodule Todo.Repo.Migrations.CreateTodo do
  use Ecto.Migration

  def change do
    create table(:todo) do
      add(:title, :string, null: false)
      add(:done, :boolean, default: false)
      add(:category_id, references(:category))
    end
  end
end
