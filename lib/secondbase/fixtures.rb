require 'secondbase/model'

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
    table_names.each { |n| class_names[n.tr('/', '_').to_sym] = n.classify if n.include?('/') }
    connection  = block_given? ? yield : ActiveRecord::Base.connection
    
    # make sure we only load secondbase tables that have fixtures defined...
    sb_table_names = SecondBase::Base.send(:descendants).map(&:table_name)
    sb_table_names = sb_table_names & table_names
    sb_connection = SecondBase::Base.connection                          
    
    # filter out the secondbase tables from firstbase, otherwise we'll get SQL errors...
    table_names_to_fetch = table_names.reject { |table_name| fixture_is_cached?(connection, table_name) || sb_table_names.include?(table_name) }
    fixtures = process_fixture_table_names(table_names_to_fetch, class_names, connection, fixtures_directory)
    fixtures = [fixtures] if !fixtures.instance_of?(Array)
    
    sb_table_names_to_fetch = sb_table_names.reject { |table_name| fixture_is_cached?(sb_connection, table_name)}
    sb_fixtures = process_fixture_table_names(sb_table_names_to_fetch, class_names, sb_connection, fixtures_directory)
    sb_fixtures = [sb_fixtures] if !sb_fixtures.instance_of?(Array)
    
    (fixtures + sb_fixtures).compact
  end
  
  def self.process_fixture_table_names(table_names_to_fetch, class_names, connection, fixtures_directory)
    fixtures_map = {}
    unless table_names_to_fetch.empty?
      ActiveRecord::Base.silence do
        connection.disable_referential_integrity do
          # fixtures_map = {}

          fixtures = table_names_to_fetch.map do |table_name|
            obj = Fixtures.new(connection, table_name.tr('/', '_'), class_names[table_name.tr('/', '_').to_sym], File.join(fixtures_directory, table_name))
            fixtures_map[table_name] = obj
          end

          all_loaded_fixtures.update(fixtures_map)

          connection.transaction(:requires_new => true) do
            fixtures.reverse.each { |fixture| fixture.delete_existing_fixtures }
            fixtures.each { |fixture| fixture.insert_fixtures }

            # Cap primary key sequences to max(pk).
            if connection.respond_to?(:reset_pk_sequence!)
              table_names_to_fetch.each do |table_name|
                connection.reset_pk_sequence!(table_name.tr('/', '_'))
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