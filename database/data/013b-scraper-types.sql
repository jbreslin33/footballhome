-- Scraper Types Lookup Data
-- Defines the parser implementations for different platforms

INSERT INTO scraper_types (id, name, parser_class, platform, description, sort_order) VALUES
    (1, 'teampass_html', 'ApslHtmlParser', 'TeamPass', 'TeamPass HTML parser (APSL, other leagues)', 1),
    (2, 'google_sheets', 'CasaGoogleSheetsParser', 'Google Sheets', 'Google Sheets API parser (CASA)', 2),
    (3, 'groupme_api', 'GroupMeApiParser', 'GroupMe', 'GroupMe API v3 parser', 3),
    (4, 'google_places', 'GooglePlacesParser', 'Google Places', 'Google Places API for venue data', 4)
ON CONFLICT (id) DO NOTHING;
