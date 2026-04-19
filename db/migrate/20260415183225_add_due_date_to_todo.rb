class AddDueDateToTodo < ActiveRecord::Migration[8.1]
  def change
    add_column :todos, :due_date, :datetime
  end
end
