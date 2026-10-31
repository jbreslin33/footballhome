#!/usr/bin/env python3
# Copy a LeagueApps event's registrations into la_event_registrants (mig 918).
#
# Storage only: nothing in the app reads these rows and nobody on them has
# opted in to anything. Emits SQL on stdout; PII flows through the pipe into
# the DB and never lands in git, per the contacts-in-DB-only rule. Waiver and
# emergency-contact answers are left behind. Safe to rerun: a registration is
# keyed by its LA id, so a rerun refreshes the row instead of adding one.
#
# Add the event to la_events by migration first, then run (program id from
# la_events; repeat per program):
#   sudo podman exec footballhome_leagueapps_sync \
#     python3 /app/scripts/la-event-registrants.py 5148876 \
#   | sudo podman exec -i footballhome_db \
#     psql -U footballhome_user -d footballhome -v ON_ERROR_STOP=1

import datetime
import importlib.util
import os
import pathlib
import sys

spec = importlib.util.spec_from_file_location(
    "la_export", pathlib.Path(__file__).with_name("la-address-backfill.py"))
la_export = importlib.util.module_from_spec(spec)
spec.loader.exec_module(la_export)


def text(value):
    return "NULL" if value in (None, "") else la_export.lit(str(value))


def num(value):
    return "NULL" if value in (None, "") else str(int(value))


def stamp(ms):
    if ms is None:
        return None
    return datetime.datetime.fromtimestamp(ms / 1000, datetime.timezone.utc)


def date_of(ms):
    return "NULL" if ms is None else f"'{stamp(ms).date().isoformat()}'"


def time_of(ms):
    return "NULL" if ms is None else f"'{stamp(ms).isoformat()}'"


COLUMNS = (
    "la_user_id", "la_parent_user_id", "user_type", "first_name", "last_name",
    "birth_date", "gender", "email", "phone", "parent_first_name",
    "parent_last_name", "parent_email", "parent_phone", "address1", "city",
    "state", "zip_code", "registered_at",
)


def row_values(rec):
    return ", ".join([
        num(rec.get("userId")), num(rec.get("parentUserId")),
        text(rec.get("userType")), text(rec.get("firstName")),
        text(rec.get("lastName")), date_of(rec.get("birthDate")),
        text(rec.get("gender")), text(rec.get("email")), text(rec.get("phone")),
        text(rec.get("parentFirstName")), text(rec.get("parentLastName")),
        text(rec.get("parentEmail")), text(rec.get("parentPhone")),
        text(rec.get("address1")), text(rec.get("city")), text(rec.get("state")),
        text(rec.get("zipCode")), time_of(rec.get("created")),
    ])


def main():
    program_ids = [int(a) for a in sys.argv[1:]]
    if not program_ids:
        print("usage: la-event-registrants.py <program_id> [...]", file=sys.stderr)
        sys.exit(2)
    site_id = int(os.environ["LEAGUEAPPS_SITE_ID"])
    tok = la_export.access_token()

    updates = ", ".join(f"{c} = EXCLUDED.{c}" for c in COLUMNS)
    print("BEGIN;")
    for pid in program_ids:
        recs = la_export.registrations(site_id, pid, tok)
        print(f"-- program {pid}: {len(recs)} live registrations", file=sys.stderr)
        for rec in recs:
            rid = rec.get("registrationId") or rec.get("id")
            print(
                f"INSERT INTO la_event_registrants (la_event_id, la_registration_id, "
                f"{', '.join(COLUMNS)}) "
                f"SELECT e.id, {int(rid)}, {row_values(rec)} "
                f"FROM la_events e WHERE e.la_program_id = {pid} "
                f"ON CONFLICT (la_registration_id) DO UPDATE SET {updates}, "
                f"loaded_at = NOW();"
            )
    print("COMMIT;")


if __name__ == "__main__":
    main()
