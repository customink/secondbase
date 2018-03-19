if defined?(ActiveRecord::Base)

  # Support test schema sync for Rails 4.2.x and up.
  if ActiveRecord::Migration.respond_to? :maintain_test_schema!
    ThirdBase.on_base do
      ActiveRecord::Migration.maintain_test_schema!
    end
  end


end
