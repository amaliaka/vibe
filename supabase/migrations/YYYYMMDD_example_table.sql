-- Migration: YYYYMMDD_describe_change_here.sql
-- OpenSpec change: openspec/changes/CHANGE_ID.yaml

-- ─── Forward migration ────────────────────────────────────────────────────

CREATE TABLE IF NOT EXISTS public.example_table (
  id          uuid        PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id     uuid        NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  title       text        NOT NULL,
  body        text,
  published   boolean     NOT NULL DEFAULT false,
  created_at  timestamptz NOT NULL DEFAULT now(),
  updated_at  timestamptz NOT NULL DEFAULT now()
);

-- Always enable RLS on new tables
ALTER TABLE public.example_table ENABLE ROW LEVEL SECURITY;

-- Public can read published rows
CREATE POLICY "public read published"
  ON public.example_table
  FOR SELECT
  USING (published = true);

-- Owners can read all their own rows
CREATE POLICY "owner read own"
  ON public.example_table
  FOR SELECT
  USING (auth.uid() = user_id);

-- Owners can insert their own rows
CREATE POLICY "owner insert"
  ON public.example_table
  FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- Owners can update their own rows
CREATE POLICY "owner update"
  ON public.example_table
  FOR UPDATE
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- Owners can delete their own rows
CREATE POLICY "owner delete"
  ON public.example_table
  FOR DELETE
  USING (auth.uid() = user_id);

-- ─── Verification query (run after applying) ──────────────────────────────
-- SELECT tablename, rowsecurity FROM pg_tables WHERE tablename = 'example_table';
-- SELECT policyname, cmd FROM pg_policies WHERE tablename = 'example_table';

-- ─── Rollback (run to undo this migration) ───────────────────────────────
-- DROP TABLE IF EXISTS public.example_table CASCADE;
