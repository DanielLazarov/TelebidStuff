DO
$do$
    BEGIN 
        FOR i IN 1..1000 LOOP
            INSERT INTO foo (name) values('name' || i);
        END LOOP;
    END 
$do$;
