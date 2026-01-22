# Supabase config (RBAC + RLS)

## Objectif
Mettre en place un contrôle d’accès (RBAC) avec RLS sur :
- customers
- accounts
- transactions
- profiles

## Principe
- auth.users = identité
- public.profiles associe user_id -> role (+ customer_id pour les customers)
- RLS active sur les tables métier
- Policies :
  - customer : accès uniquement à ses données
  - analyst : lecture globale
  - admin : accès complet

## Scripts
1) schema.sql
- création public.profiles
- index
- fonctions helpers (si utilisées)

2) policies.sql
- ENABLE RLS
- création des policies par table

## Tests rapides (SQL)
- Vérifier profils :
  SELECT * FROM public.profiles;
- Vérifier RLS active :
  SELECT relrowsecurity FROM pg_class WHERE relname IN ('customers','accounts','transactions','profiles');
