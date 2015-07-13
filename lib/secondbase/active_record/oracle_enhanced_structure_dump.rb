module ActiveRecord #:nodoc:
  module ConnectionAdapters #:nodoc:
    module OracleEnhancedStructureDump #:nodoc:

      def structure_dump_db_stored_code #:nodoc:
        setup_clean_ddl_params
        structure = []
        structure << ddl_for('SYNONYM')
        structure << ddl_for('VIEW')
        structure << ddl_for('PROCEDURE')
        structure << ddl_for('PACKAGE','PACKAGE_BODY')
        structure << ddl_for('FUNCTION')
        structure << ddl_for('TRIGGER')
        structure << ddl_for('TYPE')
        join_with_statement_token(structure)
      end

      private

      def ddl_for(*object_types)
        types    = object_types.map{|type| "'#{type}'" }.join(', ')
        ddl_dump = select_all("
          SELECT
            OWNER,
            REPLACE(
              DBMS_METADATA.GET_DDL(OBJECT_TYPE, OBJECT_NAME, OWNER),
              ( SELECT( '\"' || SYS_CONTEXT('userenv', 'session_user') || '\".' ) FROM DUAL ),
              ''
            ) as DDL
          FROM ALL_OBJECTS
          WHERE OWNER = SYS_CONTEXT('userenv', 'session_user')
          AND object_type IN (#{types})
        ")
        ddl_dump.map do |row|
          ddl = row['ddl']
          ddl = strip_schema_name(ddl, row['owner'])
          ddl = remove_alter_trigger_statements(ddl)
          ddl = substitute_synonym_target_user(ddl)
          substitute_view_target_user(ddl)
        end
      end

      # Removes explicit schema user/owner prefixes from the DDL.  This allows
      # us to run the DDL in any schema as-is.
      def strip_schema_name(ddl, owner)
        ddl.gsub(/\s#{owner}\./i,' ')
      end

      # Replaces something like
      #   "CREATE OR REPLACE SYNONYM \"USER\".\"CINK_DELAYED_JOBS_SEQ\" FOR \"TARGET_USER\".\"DELAYED_JOBS_SEQ\""
      # with
      #   "CREATE OR REPLACE SYNONYM \"USER\".\"CINK_DELAYED_JOBS_SEQ\" FOR \"${LINKED_USER}\".\"DELAYED_JOBS_SEQ\""
      # so ${LINKED_USER} can be substituted before loading into dev or test.
      #
      def substitute_synonym_target_user(ddl)
        ddl.gsub(/(SYNONYM.*FOR.*)#{synonym_schema_name}/i, '\1${LINKED_USER}')
      end

      # Replaces something like
      #   CREATE OR REPLACE FORCE VIEW "DYO_ART_V" ("ARTID", "DESIGNID", "ARTPRICE") AS
      #   select "ARTID","DESIGNID","ARTPRICE" from dyocink.dyo_art
      # with
      #   CREATE OR REPLACE FORCE VIEW "DYO_ART_V" ("ARTID", "DESIGNID", "ARTPRICE") AS
      #   select "ARTID","DESIGNID","ARTPRICE" from ${LINKED_USER}.dyo_art
      #
      def substitute_view_target_user(ddl)
        ddl.gsub(/from #{synonym_schema_name}/i, 'from ${LINKED_USER}')
      end

      # `alter trigger` statements in a DDL result in compilation errors:
      #   Error(13,1): PLS-00103: Encountered the symbol "ALTER"
      # Removing the statement allows the triggers to compile.
      def remove_alter_trigger_statements(ddl)
        ddl.gsub(/^alter trigger.*$/i, '')
      end

      # Returns the target schema user name used in synonyms in the dump.
      # See databases.yml.
      def synonym_schema_name
        Rails.configuration.database_configuration[Rails.env]["linked_username"]
      end

      # http://docs.oracle.com/cd/B28359_01/appdev.111/b28419/d_metada.htm#BGBJBFGE
      def setup_clean_ddl_params
        execute("
          begin
            dbms_metadata.set_transform_param (dbms_metadata.session_transform,'STORAGE',false);
            dbms_metadata.set_transform_param (dbms_metadata.session_transform,'TABLESPACE',false);
            dbms_metadata.set_transform_param (dbms_metadata.session_transform,'SEGMENT_ATTRIBUTES', false);
            dbms_metadata.set_transform_param (dbms_metadata.session_transform,'REF_CONSTRAINTS', false);
            dbms_metadata.set_transform_param (dbms_metadata.session_transform,'CONSTRAINTS', false);
         end;
        ")
      end
    end
  end
end