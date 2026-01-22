-- =========================================================
-- 0) RLS ON (tables métier)
-- =========================================================
ALTER TABLE public.customers ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.accounts ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.transactions ENABLE ROW LEVEL SECURITY;


-- =========================================================

-- 2) Helpers 

-- =========================================================

CREATE OR REPLACE FUNCTION public.is_role(r text)

RETURNS boolean

LANGUAGE sql

STABLE

SECURITY DEFINER

SET search_path = public

AS $$

  SELECT EXISTS (

    SELECT 1

    FROM public.profiles p

    WHERE p.user_id = auth.uid()

      AND p.role = r

  );

$$;
 
CREATE OR REPLACE FUNCTION public.current_customer_id()

RETURNS bigint

LANGUAGE sql

STABLE

SECURITY DEFINER

SET search_path = public

AS $$

  SELECT p.customer_id

  FROM public.profiles p

  WHERE p.user_id = auth.uid();

$$;
 
GRANT EXECUTE ON FUNCTION public.is_role(text) TO authenticated;

GRANT EXECUTE ON FUNCTION public.current_customer_id() TO authenticated;
 

