#pragma once
#include <string>
#include <vector>

// ────────────────────────────────────────────────────────────────────────────
// LeadForm — thin model over `lead_forms` (migration 282), which holds
// ONLY the form_ids that currently have at least one ACTIVE Meta ad
// pointing at them. Refreshed on every Leads screen load via
// MetaAdsService::fetchAdFormStatuses(). A form_id absent from the table
// is "inactive" -- see Lead::listAll(), whose NOT IN filter treats
// absence as inactive without this model needing a boolean column.
// ────────────────────────────────────────────────────────────────────────────
class LeadForm {
public:
    // Atomically replaces the active-form-id set: deletes rows not in
    // `formIds`, upserts checked_at for the rest -- a single statement
    // (data-modifying CTE), so there's no DELETE-then-INSERT race
    // window for a concurrent listAll() read. Pass an empty vector to
    // clear the table (Meta returned zero active ads). form_ids come
    // straight off the Graph API response, not user input, but are
    // still escaped rather than parameterised: the exec_params path
    // caps out at 16 bind params and the active-form count can exceed
    // that.
    static void replaceActive(const std::vector<std::string>& formIds);
};
