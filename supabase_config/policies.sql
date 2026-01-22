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
 
 
 -- =========================================================
-- 4) CREATE policies
-- =========================================================
 
-- ========== PROFILES ==========
-- Lire son propre profil
CREATE POLICY "profiles_read_own"
ON public.profiles FOR SELECT
TO authenticated
USING (user_id = auth.uid());
 
-- Admin : tout sur profiles 
CREATE POLICY "profiles_admin_all"
ON public.profiles FOR ALL
TO authenticated
USING (public.is_role('admin'))
WITH CHECK (public.is_role('admin'));
 


