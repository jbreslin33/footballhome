// Tiny JSON-file log of which exhibit posters have been posted to Instagram.
//
// File: <repo root>/scripts/exhibit-post-log.json
// Shape:
//   {
//     "totalPosters": 20,
//     "posts": [
//       { "posterNum": 1, "mediaId": "18108641053758210",
//         "mode": "carousel", "postedAt": "2026-06-14T18:42:00Z" }
//     ]
//   }
//
// Multiple entries for the same posterNum are allowed (re-posts are tracked
// chronologically). Helpers below collapse to "is this poster posted?" by
// asking whether any entry exists for it.

'use strict';

const fs   = require('fs');
const path = require('path');

const LOG_PATH = path.join(__dirname, 'exhibit-post-log.json');
const TOTAL_POSTERS = 20;

function read() {
  if (!fs.existsSync(LOG_PATH)) {
    return { totalPosters: TOTAL_POSTERS, posts: [] };
  }
  try {
    const raw = fs.readFileSync(LOG_PATH, 'utf8');
    const data = JSON.parse(raw);
    if (!Array.isArray(data.posts)) data.posts = [];
    if (!data.totalPosters) data.totalPosters = TOTAL_POSTERS;
    return data;
  } catch (e) {
    console.error(`⚠️  Could not parse ${LOG_PATH}: ${e.message}. Starting fresh.`);
    return { totalPosters: TOTAL_POSTERS, posts: [] };
  }
}

function write(data) {
  fs.writeFileSync(LOG_PATH, JSON.stringify(data, null, 2) + '\n', 'utf8');
}

function record({ posterNum, mediaId, mode }) {
  const data = read();
  data.posts.push({
    posterNum: Number(posterNum),
    mediaId:   String(mediaId),
    mode:      mode || 'carousel',
    postedAt:  new Date().toISOString(),
  });
  write(data);
  return data;
}

// Returns Set<number> of poster numbers that have at least one successful post.
function postedSet() {
  const data = read();
  return new Set(data.posts.map(p => Number(p.posterNum)));
}

// Lowest poster number 1..N that does NOT yet have an entry, or null if all done.
function nextUnposted() {
  const posted = postedSet();
  for (let n = 1; n <= TOTAL_POSTERS; n++) {
    if (!posted.has(n)) return n;
  }
  return null;
}

// Per-poster status summary suitable for the operator dashboard.
function status() {
  const data = read();
  const byPoster = new Map();
  for (const p of data.posts) {
    const existing = byPoster.get(p.posterNum);
    if (!existing || new Date(p.postedAt) > new Date(existing.postedAt)) {
      byPoster.set(p.posterNum, p);
    }
  }
  const rows = [];
  for (let n = 1; n <= TOTAL_POSTERS; n++) {
    const last = byPoster.get(n);
    const count = data.posts.filter(p => p.posterNum === n).length;
    rows.push({
      posterNum:  n,
      posted:     !!last,
      mediaId:    last ? last.mediaId : null,
      lastMode:   last ? last.mode    : null,
      lastPosted: last ? last.postedAt : null,
      postCount:  count,
    });
  }
  return { totalPosters: TOTAL_POSTERS, rows, nextUnposted: nextUnposted() };
}

module.exports = {
  LOG_PATH,
  TOTAL_POSTERS,
  read,
  write,
  record,
  postedSet,
  nextUnposted,
  status,
};
