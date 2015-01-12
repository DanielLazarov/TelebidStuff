CREATE TABLE master(
    id SERIAL PRIMARY KEY,
    value TEXT,
    some_date TIMESTAMP NOT NULL DEFAULT now()
);
CREATE TABLE foreign_to_master(
    id SERIAL PRIMARY KEY,
    valuef TEXT,
    some_datef TIMESTAMP NOT NULL DEFAULT now(),
    master_id INTEGER REFERENCES master(id) DEFERRABLE
);
   
DO
$do$
BEGIN
    FOR i IN 1..1000 LOOP
        INSERT INTO master 
        values (
            default, 'somedat', now() + '15 minutes');
    END LOOP;
END
$do$;

DO
$do$
BEGIN
    FOR i IN 1..1000 LOOP
        INSERT INTO master 
        values (
            default, 'somedat', now() + '30 minutes');
    END LOOP;
END
$do$;

DO
$do$
BEGIN
    FOR i IN 1..1000 LOOP
        INSERT INTO master 
        values (
            default, 'somedat', now() + '45 minutes');
    END LOOP;
END
$do$;

DO
$do$
BEGIN
    FOR i IN 1..1000 LOOP
        INSERT INTO master 
        values (
            default, 'somedat', now() + '60 minutes');
    END LOOP;
END
$do$;




DO
$do$
BEGIN
    FOR i IN 1..1000 LOOP
        INSERT INTO foreign_to_master 
        values (
            default, 'somedat', now() + '15 minutes', i%500 + 1);
    END LOOP;
END
$do$;

DO
$do$
BEGIN
    FOR i IN 1..1000 LOOP
        INSERT INTO foreign_to_master 
        values (
            default, 'somedat', now() + '30 minutes', i%500 + 1);
    END LOOP;
END
$do$;

DO
$do$
BEGIN
    FOR i IN 1..1000 LOOP
        INSERT INTO foreign_to_master 
        values (
            default, 'somedat', now() + '45 minutes', i%500 + 1);
    END LOOP;
END
$do$;

DO
$do$
BEGIN
    FOR i IN 1..1000 LOOP
        INSERT INTO foreign_to_master 
        values (
            default, 'somedat', now() + '60 minutes', i%500 + 1);
    END LOOP;
END
$do$;

SELECT partman.create_parent('public.foreign_to_master', 'some_datef', 'time-dynamic', 'quarter-hour', '{"id"}', 1 );  
