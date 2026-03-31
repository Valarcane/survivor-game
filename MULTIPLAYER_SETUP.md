# Supabase Lobby Multiplayer (V1) Setup

## 1) Create Supabase tables/policies

1. Open Supabase SQL Editor.
2. Run `supabase_lobby_schema.sql`.

## 2) Configure frontend

Open `index.html` and set:

- `SUPABASE_URL`
- `SUPABASE_ANON_KEY`

These are near the top of the main script block.

## 3) Run locally

Use any static server (example):

```bash
python3 -m http.server 8080
```

Open `http://localhost:8080`.

## 4) GitHub Pages compatibility

- App stays fully static (single HTML + Supabase hosted backend).
- Supabase credentials are public anon credentials (expected for browser apps).
- RLS policies are required and included in the SQL file.

## 5) V1 validation checklist

- Create lobby in browser A.
- Join by code in browser B and C.
- Verify lobby caps at 3.
- Toggle ready state from each client.
- Host presses start; all clients should enter run when lobby state changes to `in_game`.
- Refresh one client while in lobby and confirm it can rejoin with code.
