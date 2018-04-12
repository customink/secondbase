class CreateFeeds < ActiveRecord::Migration

  def change
    create_table :feeds, force: true do |t|
      t.text :body
      t.references :user, index: true
      t.timestamps null: false
    end
  end

end
