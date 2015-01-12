CREATE OR UPDATE FUNCTION master_part_trig_func() RETURNS trigger
    LANGUAGE plpgsql
    AS $_$ 
        DECLARE
            v_count                 int;
            v_partition_name        text;
            v_partition_timestamp   timestamptz;
        BEGIN 
        IF TG_OP = 'INSERT' THEN 
            v_partition_timestamp := date_trunc('hour', NEW.activation_date);
            v_partition_name := partman.check_name_length('master', 'public', to_char(v_partition_timestamp, 'YYYY_MM_DD_HH24MI'), TRUE
);
            SELECT count(*) INTO v_count FROM pg_tables WHERE schemaname ||'.'|| tablename = v_partition_name;
            IF v_count > 0 THEN 
                EXECUTE 'INSERT INTO '||v_partition_name||' VALUES($1.*)' USING NEW;
            ELSE
                RETURN NEW;
            END IF;
        END IF;
        
        RETURN NULL; 
        END $_$;

