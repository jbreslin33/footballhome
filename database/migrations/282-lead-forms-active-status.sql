-- 282-lead-forms-active-status.sql
--
-- Tracks which Meta lead-gen form_ids currently have at least one ACTIVE
-- ad pointing at them. Refreshed on every Leads screen load from a live
-- Graph API pull (MetaAdsService::fetchAdFormStatuses -> LeadForm::
-- replaceActive), never trust a stale row past the next refresh. A
-- form_id absent from this table is treated as inactive (paused,
-- deleted, or a form we've simply never seen an ad for) -- see
-- Lead::listAll()'s NOT IN filter, which gets that behavior for free
-- without needing a boolean column.
CREATE TABLE IF NOT EXISTS lead_forms (
  form_id     TEXT PRIMARY KEY,
  checked_at  TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);
