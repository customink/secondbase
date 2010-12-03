###########################
# Monkey patch Fixtures
# Fixtures needs to load fixtures into the database defined by the parent class!
#
# I feel like the concepts here could be incorporated directly into Fixtures. 
# I mean, they shouldn't be so presumptions to think that every model lives in the 
# same database....
class Fixtures
  def self.create_fixtures(fixtures_directory, table_names, class_names = {})
    table_names = [table_names].flatten.map { |n| n.to_s }
    connection  = block_given? ? yield : ActiveRecord::Base.connection
    
    sb_table_names = Object.subclasses_of(SecondBase::Base).map(&:table_name)
    sb_connection = SecondBase::Base.connection
    
    table_names_to_fetch = table_names.reject { |table_name| fixture_is_cached?(connection, table_name) || sb_table_names.include?(table_name) }
    sb_table_names_to_fetch = sb_table_names.reject { |table_name| fixture_is_cached?(sb_connection, table_name) }
    
    
    all_fixtures = []
    reg_fixtures = process_fixture_table_names(table_names_to_fetch, class_names, connection, fixtures_directory) 
    sb_fixtures = process_fixture_table_names(sb_table_names_to_fetch, class_names, sb_connection, fixtures_directory) 
    
    # TODO:  for some reason, sb_fixtures are getting stored as an array with the fixture name.
    #        so we have to flatten them and reject non-fixtures objects...
    sb_fixtures.try(:flatten!)
    sb_fixtures.reject! {|f| !f.instance_of?(Fixtures)} unless sb_fixtures.blank?
    
    reg_fixtures + (sb_fixtures || [] )
  end
  
  def self.process_fixture_table_names(table_names_to_fetch, class_names, connection, fixtures_directory) 
    unless table_names_to_fetch.empty?
      ActiveRecord::Base.silence do
        connection.disable_referential_integrity do
          fixtures_map = {}

          fixtures = table_names_to_fetch.map do |table_name|
            fixtures_map[table_name] = Fixtures.new(connection, File.split(table_name.to_s).last, class_names[table_name.to_sym], File.join(fixtures_directory, table_name.to_s))
          end
          
          all_loaded_fixtures.update(fixtures_map)

          connection.transaction(:requires_new => true) do
            fixtures.reverse.each { |fixture| fixture.delete_existing_fixtures }
            fixtures.each { |fixture| fixture.insert_fixtures }

            # Cap primary key sequences to max(pk).
            if connection.respond_to?(:reset_pk_sequence!)
              table_names.each do |table_name|
                connection.reset_pk_sequence!(table_name)
              end
            end
          end

          cache_fixtures(connection, fixtures_map)
        end
      end
    end
    
    table_names_to_fetch = nil if table_names_to_fetch.blank?
    cached_fixtures(connection, table_names_to_fetch)
  end

end