class CreateUsers < ActiveRecord::Migration

  def change
    create_table :users, force: true do |t|
      t.string :name
      t.string :email
      t.timestamps null: false
    end
  end

end
