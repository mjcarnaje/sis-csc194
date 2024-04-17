-- FUNCTION: public.insert_course(character varying)

-- DROP FUNCTION IF EXISTS public.insert_course(character varying);

CREATE OR REPLACE FUNCTION public.insert_course(
	p_course_name character varying)
    RETURNS void
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
AS $BODY$
BEGIN
    INSERT INTO courses(course_name)
    VALUES (p_course_name);
END;
$BODY$;

ALTER FUNCTION public.insert_course(character varying)
    OWNER TO postgres;