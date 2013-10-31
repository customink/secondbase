module ActiveRecord
  # = Active Record Has And Belongs To Many Association
  module Associations
    class HasAndBelongsToManyAssociation < CollectionAssociation

      def initialize(owner, reflection)
        super
        @join_table = Arel::Table.new(@reflection.options[:join_table], arel_engine)
      end
      
      # determines the appropriate engine for the join table's parent klass
      def arel_engine
        Arel::Sql::Engine.new(@reflection.klass.engine)
      end
    end
  end
end
