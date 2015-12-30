class CreatePosts < ActiveRecord::Migration

  def change
    create_table :users, force: true do |t|
      t.text :title
      t.text :body
      t.references :user, index: true
      t.timestamps
    end
  end

end
