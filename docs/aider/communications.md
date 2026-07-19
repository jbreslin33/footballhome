# Aider Context: Communications

Use this file as the first file you pass to aider for Club Admin communications
work: messages, socials, posters/flyers, campaign assets, and outbound copy.

```text
Read this context map. Add the smallest pack for my task, then wait for my next instruction.
Task:
```

## How To Use This File

1. Add only this file first when the communications task is vague.
2. Pick exactly one pack below, unless the task explicitly crosses messages,
   socials, and poster assets.
3. Treat messages as recipient-first, socials as channel-first, and posters or
   flyers as reusable assets that can also export to social formats.
4. Keep durable product rules in `CONVENTIONS.md` or an owning design doc; keep
   only file-selection guidance here.

## Club Admin Communications IA

Use when the Club Admin dashboard grouping, tile placement, or communications
navigation is wrong.

```text
/add frontend/js/screens/admin-club.js frontend/js/app.js docs/operations-design.md docs/aider/communications.md
```

## Messages Hub

Use for canned team replies, welcome copy, broadcasts, lead follow-up snippets,
or the Club Admin Messages screen.

```text
/add frontend/js/screens/messages.js frontend/js/screens/leads.js frontend/js/screens/admin-club.js docs/aider/communications.md
```

## Social Posts

Use for Instagram holiday, promotional, content, schedule, or match social post
work.

```text
/add frontend/js/screens/holiday-posts.js frontend/js/screens/promotional-posts.js frontend/js/screens/content-posts.js frontend/js/screens/MatchSocialScreen.js frontend/js/screens/SocialScheduleScreen.js backend/src/controllers/SocialController.cpp backend/src/controllers/SocialController.h docs/aider/communications.md
```

## Posters / Flyers / Social Exports

Use for printable flyers, public exhibit posters, generated poster assets, and
poster-to-social export previews.

```text
/add frontend/js/screens/flyers.js frontend/js/screens/ad-preview.js frontend/exhibit/lighthouse-history.html frontend/exhibit/slideshow.html scripts/render-poster-from-source.js scripts/debug-poster-count.js scripts/extract-poster-sources.js frontend/js/screens/admin-club.js docs/aider/communications.md
```