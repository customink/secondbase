class CreatePosts < ActiveRecord::Migration[4.2]

  def change
    create_table :posts, force: true do |t|
      t.text :title
      t.text :body
      t.references :user, index: true
      t.timestamps null: false
    end
  end

end
