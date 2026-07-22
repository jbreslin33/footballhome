-- Link Chase Sempervive to the LeagueApps member identity while keeping
-- the FH-facing name on the canonical persons row.
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM persons WHERE id = 1550) THEN
    INSERT INTO external_person_aliases (
      provider,
      alias_first_name,
      alias_last_name,
      person_id,
      external_user_id
    )
    VALUES (
      'leagueapps',
      'Aleisha',
      'Zanini',
      1550,
      '57713803'
    )
    ON CONFLICT (provider, external_user_id) WHERE external_user_id IS NOT NULL DO NOTHING;

    INSERT INTO person_emails (person_id, email, is_primary, is_verified)
    VALUES (1550, 'chasemarques10@gmail.com', true, true)
    ON CONFLICT (person_id, email) DO NOTHING;

    INSERT INTO person_phones (
      person_id,
      phone_number,
      is_primary,
      is_verified,
      can_receive_sms,
      can_receive_calls
    )
    VALUES (1550, '386-290-5824', true, true, true, true)
    ON CONFLICT (person_id, phone_number) DO NOTHING;
  END IF;
END $$;
