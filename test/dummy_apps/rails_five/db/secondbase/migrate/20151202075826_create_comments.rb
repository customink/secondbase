class CreateComments < ActiveRecord::Migration[4.2]

  def change
    create_table :comments, force: true do |t|
      t.text :body
      t.references :user, index: true
      t.timestamps null: false
    end
  end

end
