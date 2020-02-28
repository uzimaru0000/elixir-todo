defmodule Todo.Repo.Migrations.CreateCategory do
  use Ecto.Migration

  def change do
    create table(:category) do
      add(:name, :string, null: false)
    end

    create(unique_index(:category, [:name]))
  end
end
