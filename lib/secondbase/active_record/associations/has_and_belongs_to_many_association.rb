module ActiveRecord
  # = Active Record Has And Belongs To Many Association
  module Associations
    class HasAndBelongsToManyAssociation < AssociationCollection 
      
      # determines the appropriate engine for the join table's parent klass
      def arel_engine
        Arel::Sql::Engine.new(@reflection.klass.engine)
      end
      
      # This method is entirely replicated, except for line 25.  We simply
      # need to pass in the appropriate engine to Arel.  
      def insert_record(record, force = true, validate = true)
        if record.new_record?
          if force
            record.save!
          else
            return false unless record.save(:validate => validate)
          end
        end

        if @reflection.options[:insert_sql]
          @owner.connection.insert(interpolate_and_sanitize_sql(@reflection.options[:insert_sql], record))
        else
          relation   = Arel::Table.new(@reflection.options[:join_table], arel_engine)
          timestamps = record_timestamp_columns(record)
          timezone   = record.send(:current_time_from_proper_timezone) if timestamps.any?

          attributes = Hash[columns.map do |column|
            name = column.name
            value = case name.to_s
              when @reflection.primary_key_name.to_s
                @owner.id
              when @reflection.association_foreign_key.to_s
                record.id
              when *timestamps
                timezone
              else
                @owner.send(:quote_value, record[name], column) if record.has_attribute?(name)
            end
            [relation[name], value] unless value.nil?
          end]

          relation.insert(attributes)
        end

        return true
      end
      
      # This method is entirely replicated, except for line 57.  We simply
      # need to pass in the appropriate engine to Arel.
      def delete_records(records)
        if sql = @reflection.options[:delete_sql]
          records.each { |record| @owner.connection.delete(interpolate_and_sanitize_sql(sql, record)) }
        else

          relation = Arel::Table.new(@reflection.options[:join_table], arel_engine)
          
          relation.where(relation[@reflection.primary_key_name].eq(@owner.id).
            and(relation[@reflection.association_foreign_key].in(records.map { |x| x.id }.compact))
          ).delete
        end
      end
    end
  end
end