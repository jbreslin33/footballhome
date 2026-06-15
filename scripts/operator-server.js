#!/usr/bin/env node
//
// Lighthouse exhibit — operator dashboard server
// ──────────────────────────────────────────────────────────────────────
// Tiny local-only HTTP server that backs the 20-button operator page at
//   frontend/operator/index.html
//
// Routes:
//   GET  /                       → serve the dashboard HTML
//   GET  /api/status             → JSON: which P# are posted, lastPosted, etc.
//   GET  /api/titles             → JSON: { 1: { title, sub, kicker }, ... }
//                                   (scraped from frontend/exhibit/lighthouse-history.html)
//   POST /api/post/:n            → start a `node post-to-instagram.js exhibit N --yes` job
//                                   body (optional): { mode: 'carousel' | 'single' }
//                                   returns: { jobId }
//   POST /api/preview/:n         → start a render-only preview job (no post)
//                                   returns: { jobId }
//   GET  /api/job/:id            → JSON job snapshot (status + cumulative output)
//   GET  /api/job/:id/stream     → SSE: live stdout/stderr stream until job exits
//
// Only one post-job runs at a time (the post script is heavy: puppeteer
// render + 10 IG container creates + parent + publish). Preview-jobs are
// likewise serialised. Attempting to start a second job while one is
// running returns HTTP 409.
//
// Bound to 127.0.0.1 by default. Override with OPERATOR_HOST / OPERATOR_PORT.
// No auth — keep this port off the public internet.
//
// Start:   make operator-server
//   or:    node scripts/operator-server.js
//

'use strict';

const http       = require('http');
const fs         = require('fs');
const path       = require('path');
const { spawn }  = require('child_process');
const { randomUUID } = require('crypto');
const { JSDOM }  = require('jsdom');

const postLog = require('./exhibit-post-log');

const REPO_ROOT       = path.resolve(__dirname, '..');
const OPERATOR_HTML   = path.join(REPO_ROOT, 'frontend', 'operator', 'index.html');
const SOURCE_HTML     = path.join(REPO_ROOT, 'frontend', 'exhibit', 'lighthouse-history.html');
const HOST            = process.env.OPERATOR_HOST || '127.0.0.1';
const PORT            = parseInt(process.env.OPERATOR_PORT || '3010', 10);

// ── In-memory job table ────────────────────────────────────────────────
// Single live job at a time (post or preview). Older jobs stay in the map
// so /api/job/:id keeps returning their final transcript until restart.
const jobs = new Map();
let activeJobId = null;

function newJob({ kind, posterNum, args }) {
  const id = randomUUID();
  const job = {
    id,
    kind,                  // 'post' | 'preview'
    posterNum,
    args,
    status: 'starting',    // 'starting' | 'running' | 'success' | 'error'
    exitCode: null,
    startedAt: new Date().toISOString(),
    endedAt: null,
    chunks: [],            // [{ stream: 'stdout'|'stderr', text, at }]
    subscribers: new Set(),// SSE response objects
  };
  jobs.set(id, job);
  return job;
}

function pushChunk(job, stream, text) {
  const chunk = { stream, text, at: new Date().toISOString() };
  job.chunks.push(chunk);
  for (const res of job.subscribers) {
    try {
      res.write(`data: ${JSON.stringify(chunk)}\n\n`);
    } catch { /* client gone; will be cleaned up on close */ }
  }
}

function endJob(job, code) {
  job.status = code === 0 ? 'success' : 'error';
  job.exitCode = code;
  job.endedAt = new Date().toISOString();
  const final = { event: 'end', status: job.status, exitCode: code, endedAt: job.endedAt };
  for (const res of job.subscribers) {
    try {
      res.write(`event: end\ndata: ${JSON.stringify(final)}\n\n`);
      res.end();
    } catch { /* */ }
  }
  job.subscribers.clear();
  if (activeJobId === job.id) activeJobId = null;
}

function startJob({ kind, posterNum, scriptArgs }) {
  if (activeJobId) {
    const conflict = new Error('A job is already running');
    conflict.code = 'BUSY';
    throw conflict;
  }
  const job = newJob({ kind, posterNum, args: scriptArgs });
  activeJobId = job.id;

  const child = spawn(
    process.execPath,
    [path.join(REPO_ROOT, 'post-to-instagram.js'), ...scriptArgs],
    { cwd: REPO_ROOT, env: process.env }
  );
  job.status = 'running';
  job.pid = child.pid;
  child.stdout.on('data', d => pushChunk(job, 'stdout', d.toString()));
  child.stderr.on('data', d => pushChunk(job, 'stderr', d.toString()));
  child.on('close', code => endJob(job, code));
  child.on('error', err => {
    pushChunk(job, 'stderr', `[spawn error] ${err.message}\n`);
    endJob(job, 1);
  });
  return job;
}

// ── Title scraper ──────────────────────────────────────────────────────
// Cache the title map for 60s — the source HTML rarely changes during an
// operator session and parsing it is cheap but not free.
let titleCache = null;
let titleCacheAt = 0;
function readTitles() {
  if (titleCache && (Date.now() - titleCacheAt) < 60_000) return titleCache;
  if (!fs.existsSync(SOURCE_HTML)) return {};
  const html = fs.readFileSync(SOURCE_HTML, 'utf8');
  const dom = new JSDOM(html);
  const out = {};
  // The source assigns id="poster-N" at runtime via JS (line ~1336 of the
  // source). jsdom doesn't run page scripts, so look up <article class="poster">
  // by DOM order and map the first 20 to P1..P20 by index.
  const articles = Array.from(dom.window.document.querySelectorAll('article.poster'));
  for (let i = 0; i < articles.length && i < postLog.TOTAL_POSTERS; i++) {
    const p = articles[i];
    const kicker = p.querySelector('.poster-band .kicker');
    const title  = p.querySelector('.poster-band h2');
    const sub    = p.querySelector('.poster-band .sub');
    out[i + 1] = {
      kicker: kicker ? kicker.textContent.trim() : '',
      title:  title  ? title.textContent.trim()  : '',
      sub:    sub    ? sub.textContent.trim()    : '',
    };
  }
  titleCache = out;
  titleCacheAt = Date.now();
  return out;
}

// ── HTTP helpers ───────────────────────────────────────────────────────
function sendJson(res, status, body) {
  res.writeHead(status, { 'content-type': 'application/json; charset=utf-8' });
  res.end(JSON.stringify(body));
}
function sendText(res, status, text, type = 'text/plain; charset=utf-8') {
  res.writeHead(status, { 'content-type': type });
  res.end(text);
}
function notFound(res) { sendJson(res, 404, { error: 'not found' }); }
function readBody(req) {
  return new Promise((resolve, reject) => {
    const chunks = [];
    req.on('data', c => chunks.push(c));
    req.on('end', () => {
      const text = Buffer.concat(chunks).toString('utf8');
      if (!text) return resolve({});
      try { resolve(JSON.parse(text)); }
      catch (e) { reject(e); }
    });
    req.on('error', reject);
  });
}

// ── Routes ─────────────────────────────────────────────────────────────
const server = http.createServer(async (req, res) => {
  try {
    const url = new URL(req.url, `http://${req.headers.host}`);
    const route = `${req.method} ${url.pathname}`;

    // GET /
    if (req.method === 'GET' && (url.pathname === '/' || url.pathname === '/index.html')) {
      if (!fs.existsSync(OPERATOR_HTML)) {
        return sendText(res, 500, 'frontend/operator/index.html not found');
      }
      const html = fs.readFileSync(OPERATOR_HTML, 'utf8');
      return sendText(res, 200, html, 'text/html; charset=utf-8');
    }

    // GET /api/status
    if (req.method === 'GET' && url.pathname === '/api/status') {
      const s = postLog.status();
      const titles = readTitles();
      for (const row of s.rows) row.meta = titles[row.posterNum] || null;
      return sendJson(res, 200, {
        ...s,
        activeJobId,
        host: HOST, port: PORT,
        serverTime: new Date().toISOString(),
      });
    }

    // GET /api/titles
    if (req.method === 'GET' && url.pathname === '/api/titles') {
      return sendJson(res, 200, readTitles());
    }

    // POST /api/post/:n
    let m = url.pathname.match(/^\/api\/post\/(\d+)$/);
    if (req.method === 'POST' && m) {
      const n = parseInt(m[1], 10);
      if (n < 1 || n > postLog.TOTAL_POSTERS) {
        return sendJson(res, 400, { error: `posterNum out of range 1..${postLog.TOTAL_POSTERS}` });
      }
      const body = await readBody(req).catch(() => ({}));
      const mode = body.mode === 'single' ? 'single' : 'carousel';
      const scriptArgs = mode === 'single'
        ? ['exhibit', String(n), 'single', '--yes']
        : ['exhibit', String(n), '--yes'];
      try {
        const job = startJob({ kind: 'post', posterNum: n, scriptArgs });
        return sendJson(res, 202, { jobId: job.id, posterNum: n, mode, kind: 'post' });
      } catch (e) {
        if (e.code === 'BUSY') {
          return sendJson(res, 409, { error: 'another job is running', activeJobId });
        }
        throw e;
      }
    }

    // POST /api/preview/:n
    m = url.pathname.match(/^\/api\/preview\/(\d+)$/);
    if (req.method === 'POST' && m) {
      const n = parseInt(m[1], 10);
      if (n < 1 || n > postLog.TOTAL_POSTERS) {
        return sendJson(res, 400, { error: `posterNum out of range 1..${postLog.TOTAL_POSTERS}` });
      }
      const body = await readBody(req).catch(() => ({}));
      const mode = body.mode === 'single' ? 'single' : 'carousel';
      const scriptArgs = mode === 'single'
        ? ['exhibit', String(n), 'single', 'preview']
        : ['exhibit', String(n), 'preview'];
      try {
        const job = startJob({ kind: 'preview', posterNum: n, scriptArgs });
        return sendJson(res, 202, { jobId: job.id, posterNum: n, mode, kind: 'preview' });
      } catch (e) {
        if (e.code === 'BUSY') {
          return sendJson(res, 409, { error: 'another job is running', activeJobId });
        }
        throw e;
      }
    }

    // GET /api/job/:id
    m = url.pathname.match(/^\/api\/job\/([0-9a-f-]+)$/);
    if (req.method === 'GET' && m) {
      const job = jobs.get(m[1]);
      if (!job) return notFound(res);
      const { subscribers, ...snapshot } = job;
      return sendJson(res, 200, snapshot);
    }

    // GET /api/job/:id/stream  (SSE)
    m = url.pathname.match(/^\/api\/job\/([0-9a-f-]+)\/stream$/);
    if (req.method === 'GET' && m) {
      const job = jobs.get(m[1]);
      if (!job) return notFound(res);
      res.writeHead(200, {
        'content-type': 'text/event-stream',
        'cache-control': 'no-cache',
        connection: 'keep-alive',
      });
      // Replay any chunks captured before the client subscribed.
      for (const chunk of job.chunks) {
        res.write(`data: ${JSON.stringify(chunk)}\n\n`);
      }
      if (job.status === 'success' || job.status === 'error') {
        // Job already finished — send the end event and close.
        res.write(`event: end\ndata: ${JSON.stringify({
          event: 'end', status: job.status, exitCode: job.exitCode, endedAt: job.endedAt,
        })}\n\n`);
        return res.end();
      }
      job.subscribers.add(res);
      req.on('close', () => job.subscribers.delete(res));
      return;
    }

    return notFound(res);
  } catch (e) {
    console.error('server error:', e);
    sendJson(res, 500, { error: e.message });
  }
});

server.listen(PORT, HOST, () => {
  console.log(`Operator dashboard listening at http://${HOST}:${PORT}/`);
  console.log(`(post-log:  ${path.relative(REPO_ROOT, postLog.LOG_PATH)})`);
  if (HOST !== '127.0.0.1' && HOST !== 'localhost') {
    console.warn('⚠️  Bound to a non-local host. There is no auth — only do this on a trusted LAN.');
  }
});
