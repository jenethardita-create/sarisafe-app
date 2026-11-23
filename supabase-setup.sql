-- =========================================================
-- SARISAFE: COMPLETE SUPABASE DATABASE SETUP
-- Role-isolated auto-sync (staff = upload own, owner = full read)
-- =========================================================

-- 1. CREATE THE STORE
create table if not exists public.sarisafe_stores (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  created_at timestamptz not null default now()
);

insert into public.sarisafe_stores (id, name)
values (
  '11111111-1111-4111-8111-111111111111',
  'Fuentez Store'
)
on conflict (id) do nothing;


-- 2. CREATE USER PROFILES
create table if not exists public.sarisafe_profiles (
  user_id uuid primary key references auth.users(id) on delete cascade,
  store_id uuid not null references public.sarisafe_stores(id),
  full_name text,
  role text not null check (role in ('owner', 'staff')),
  created_at timestamptz not null default now()
);


-- 3. CREATE TRANSACTIONS TABLE
create table if not exists public.sarisafe_transactions (
  id text primary key,
  ts timestamptz not null,
  data jsonb not null,
  store_id uuid,
  created_by uuid references auth.users(id),
  updated_by uuid references auth.users(id),
  updated_at timestamptz not null default now()
);

alter table public.sarisafe_transactions
  add column if not exists store_id uuid,
  add column if not exists created_by uuid references auth.users(id),
  add column if not exists updated_by uuid references auth.users(id),
  add column if not exists updated_at timestamptz default now();

update public.sarisafe_transactions
set store_id = '11111111-1111-4111-8111-111111111111'
where store_id is null;

alter table public.sarisafe_transactions
  alter column store_id set not null;


-- 4. CREATE SHIFTS TABLE
create table if not exists public.sarisafe_shifts (
  id text primary key,
  ts timestamptz not null,
  data jsonb not null,
  store_id uuid,
  created_by uuid references auth.users(id),
  updated_by uuid references auth.users(id),
  updated_at timestamptz not null default now()
);

alter table public.sarisafe_shifts
  add column if not exists store_id uuid,
  add column if not exists created_by uuid references auth.users(id),
  add column if not exists updated_by uuid references auth.users(id),
  add column if not exists updated_at timestamptz default now();

update public.sarisafe_shifts
set store_id = '11111111-1111-4111-8111-111111111111'
where store_id is null;

alter table public.sarisafe_shifts
  alter column store_id set not null;


-- 5. ADD STORE FOREIGN KEYS
do $$
begin
  if not exists (
    select 1 from pg_constraint
    where conname = 'sarisafe_transactions_store_fk'
      and conrelid = 'public.sarisafe_transactions'::regclass
  ) then
    alter table public.sarisafe_transactions
      add constraint sarisafe_transactions_store_fk
      foreign key (store_id)
      references public.sarisafe_stores(id);
  end if;

  if not exists (
    select 1 from pg_constraint
    where conname = 'sarisafe_shifts_store_fk'
      and conrelid = 'public.sarisafe_shifts'::regclass
  ) then
    alter table public.sarisafe_shifts
      add constraint sarisafe_shifts_store_fk
      foreign key (store_id)
      references public.sarisafe_stores(id);
  end if;
end;
$$;


-- 6. INDEXES FOR FASTER SYNCHRONIZATION
create index if not exists sarisafe_tx_upd on public.sarisafe_transactions(updated_at);
create index if not exists sarisafe_sh_upd on public.sarisafe_shifts(updated_at);
create index if not exists sarisafe_tx_store on public.sarisafe_transactions(store_id);
create index if not exists sarisafe_sh_store on public.sarisafe_shifts(store_id);


-- 7. HELPER FUNCTIONS FOR STORE & ROLE LOOKUP
create or replace function public.current_sarisafe_store_id()
returns uuid
language sql
stable
security definer
set search_path = public, pg_temp
as $$
  select store_id
  from public.sarisafe_profiles
  where user_id = auth.uid()
  limit 1;
$$;

create or replace function public.current_sarisafe_role()
returns text
language sql
stable
security definer
set search_path = public, pg_temp
as $$
  select role
  from public.sarisafe_profiles
  where user_id = auth.uid()
  limit 1;
$$;


-- 8. AUTOMATIC USER, IMMUTABILITY, AND TIMESTAMP TRACKING
create or replace function public.sarisafe_touch()
returns trigger
language plpgsql
as $$
begin
  if tg_op = 'INSERT' then
    if new.store_id is null then
      new.store_id := public.current_sarisafe_store_id();
    end if;

    new.created_by := auth.uid();
    new.updated_by := auth.uid();
  else
    -- Enforce immutability of recorded transaction financial fields and signatures.
    if tg_table_name = 'sarisafe_transactions' and (
      new.data->>'kind'   is distinct from old.data->>'kind' or
      new.data->>'amount' is distinct from old.data->>'amount' or
      new.data->>'fee'    is distinct from old.data->>'fee' or
      new.data->>'ref'    is distinct from old.data->>'ref' or
      new.data->>'type'   is distinct from old.data->>'type' or
      new.data->>'sig'    is distinct from old.data->>'sig'
    ) then
      raise exception 'Recorded transaction financial fields and signatures are immutable';
    end if;

    -- Preserve the original creator and store.
    new.store_id := old.store_id;
    new.created_by := old.created_by;
    new.updated_by := auth.uid();
  end if;

  new.updated_at := now();
  return new;
end;
$$;


-- 9. ATTACH TRIGGERS
drop trigger if exists sarisafe_tx_touch on public.sarisafe_transactions;
create trigger sarisafe_tx_touch
before insert or update on public.sarisafe_transactions
for each row execute function public.sarisafe_touch();

drop trigger if exists sarisafe_sh_touch on public.sarisafe_shifts;
create trigger sarisafe_sh_touch
before insert or update on public.sarisafe_shifts
for each row execute function public.sarisafe_touch();


-- 10. ENABLE ROW LEVEL SECURITY
alter table public.sarisafe_stores enable row level security;
alter table public.sarisafe_profiles enable row level security;
alter table public.sarisafe_transactions enable row level security;
alter table public.sarisafe_shifts enable row level security;


-- 11. CLEAN UP OLD POLICIES
drop policy if exists "store read" on public.sarisafe_transactions;
drop policy if exists "store insert" on public.sarisafe_transactions;
drop policy if exists "store update" on public.sarisafe_transactions;
drop policy if exists "store read" on public.sarisafe_shifts;
drop policy if exists "store insert" on public.sarisafe_shifts;
drop policy if exists "store update" on public.sarisafe_shifts;

drop policy if exists "sarisafe_store_read" on public.sarisafe_stores;
drop policy if exists "sarisafe_profiles_read" on public.sarisafe_profiles;
drop policy if exists "sarisafe_transactions_read" on public.sarisafe_transactions;
drop policy if exists "sarisafe_transactions_insert" on public.sarisafe_transactions;
drop policy if exists "sarisafe_transactions_update" on public.sarisafe_transactions;
drop policy if exists "sarisafe_shifts_read" on public.sarisafe_shifts;
drop policy if exists "sarisafe_shifts_insert" on public.sarisafe_shifts;
drop policy if exists "sarisafe_shifts_update" on public.sarisafe_shifts;


-- 12. STORE & PROFILE POLICIES (Confidentiality Isolation)
create policy "sarisafe_store_read"
on public.sarisafe_stores
for select to authenticated
using (id = public.current_sarisafe_store_id());

create policy "sarisafe_profiles_read"
on public.sarisafe_profiles
for select to authenticated
using (
  user_id = auth.uid()
  or (
    store_id = public.current_sarisafe_store_id()
    and public.current_sarisafe_role() = 'owner'
  )
);


-- 13. TRANSACTION POLICIES
-- Owners can view ALL store transactions; staff can only see rows they uploaded.
create policy "sarisafe_transactions_read"
on public.sarisafe_transactions
for select to authenticated
using (
  store_id = public.current_sarisafe_store_id()
  and (
    public.current_sarisafe_role() = 'owner'
    or created_by = auth.uid()
  )
);

create policy "sarisafe_transactions_insert"
on public.sarisafe_transactions
for insert to authenticated
with check (
  store_id = public.current_sarisafe_store_id()
  and public.current_sarisafe_role() in ('owner', 'staff')
);

create policy "sarisafe_transactions_update"
on public.sarisafe_transactions
for update to authenticated
using (
  store_id = public.current_sarisafe_store_id()
  and (
    public.current_sarisafe_role() = 'owner'
    or created_by = auth.uid()
  )
)
with check (
  store_id = public.current_sarisafe_store_id()
  and (
    public.current_sarisafe_role() = 'owner'
    or created_by = auth.uid()
  )
);


-- 14. SHIFT POLICIES
-- Owners can view ALL store shifts; staff can only see shifts they uploaded.
create policy "sarisafe_shifts_read"
on public.sarisafe_shifts
for select to authenticated
using (
  store_id = public.current_sarisafe_store_id()
  and (
    public.current_sarisafe_role() = 'owner'
    or created_by = auth.uid()
  )
);

create policy "sarisafe_shifts_insert"
on public.sarisafe_shifts
for insert to authenticated
with check (
  store_id = public.current_sarisafe_store_id()
  and public.current_sarisafe_role() in ('owner', 'staff')
);

create policy "sarisafe_shifts_update"
on public.sarisafe_shifts
for update to authenticated
using (
  store_id = public.current_sarisafe_store_id()
  and (
    public.current_sarisafe_role() = 'owner'
    or created_by = auth.uid()
  )
)
with check (
  store_id = public.current_sarisafe_store_id()
  and (
    public.current_sarisafe_role() = 'owner'
    or created_by = auth.uid()
  )
);


-- 15. GRANT PERMISSIONS
grant usage on schema public to authenticated;
grant select on public.sarisafe_stores, public.sarisafe_profiles to authenticated;
grant select, insert, update on public.sarisafe_transactions, public.sarisafe_shifts to authenticated;
grant execute on function public.current_sarisafe_store_id() to authenticated;
grant execute on function public.current_sarisafe_role() to authenticated;