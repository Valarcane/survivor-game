-- Supabase schema for multiplayer lobby codes (V1)
-- Run in Supabase SQL editor.

create extension if not exists pgcrypto;

create table if not exists public.lobbies (
  id uuid primary key default gen_random_uuid(),
  code text not null unique check (char_length(code) = 6),
  host_player_id text not null,
  state text not null default 'open' check (state in ('open', 'in_game', 'closed')),
  created_at timestamptz not null default now()
);

create table if not exists public.lobby_players (
  id uuid primary key default gen_random_uuid(),
  lobby_id uuid not null references public.lobbies(id) on delete cascade,
  player_id text not null,
  name text not null default 'Player',
  character_id text not null default 'wanderer',
  is_ready boolean not null default false,
  joined_at timestamptz not null default now(),
  unique (lobby_id, player_id)
);

create index if not exists idx_lobbies_code on public.lobbies(code);
create index if not exists idx_lobby_players_lobby on public.lobby_players(lobby_id);

-- Enable realtime
alter publication supabase_realtime add table public.lobbies;
alter publication supabase_realtime add table public.lobby_players;

-- RLS
alter table public.lobbies enable row level security;
alter table public.lobby_players enable row level security;

drop policy if exists "lobbies_read_all" on public.lobbies;
create policy "lobbies_read_all"
on public.lobbies
for select
to anon, authenticated
using (true);

drop policy if exists "lobbies_create_host" on public.lobbies;
create policy "lobbies_create_host"
on public.lobbies
for insert
to anon, authenticated
with check (
  host_player_id is not null
  and state = 'open'
);

drop policy if exists "lobbies_host_update" on public.lobbies;
create policy "lobbies_host_update"
on public.lobbies
for update
to anon, authenticated
using (true)
with check (true);

drop policy if exists "lobby_players_read_all" on public.lobby_players;
create policy "lobby_players_read_all"
on public.lobby_players
for select
to anon, authenticated
using (true);

drop policy if exists "lobby_players_insert" on public.lobby_players;
create policy "lobby_players_insert"
on public.lobby_players
for insert
to anon, authenticated
with check (
  exists (
    select 1
    from public.lobbies l
    where l.id = lobby_id
      and l.state = 'open'
  )
  and (
    select count(*)
    from public.lobby_players lp
    where lp.lobby_id = lobby_id
  ) < 3
);

drop policy if exists "lobby_players_update" on public.lobby_players;
create policy "lobby_players_update"
on public.lobby_players
for update
to anon, authenticated
using (
  exists (
    select 1
    from public.lobbies l
    where l.id = lobby_id
      and l.state = 'open'
  )
)
with check (
  exists (
    select 1
    from public.lobbies l
    where l.id = lobby_id
      and l.state = 'open'
  )
);

drop policy if exists "lobby_players_delete" on public.lobby_players;
create policy "lobby_players_delete"
on public.lobby_players
for delete
to anon, authenticated
using (true);
