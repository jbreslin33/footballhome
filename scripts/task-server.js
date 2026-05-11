#!/usr/bin/env node
/**
 * Host-side task server — listens on port 3002, runs make targets on behalf
 * of the backend container (which can't run Chrome/Puppeteer).
 *
 * Bind to 0.0.0.0 so the container can reach it via the bridge gateway.
 * Only allow known tasks.
 */
const http = require('http');
const { spawn } = require('child_process');
const path = require('path');

const PORT = 3002;
const REPO = path.resolve(__dirname, '..');

const ALLOWED_TASKS = {
  'apsl-team': ['make', ['-C', REPO, 'lighthouse-apsl-team']],
  'apsl-standings': ['make', ['-C', REPO, 'lighthouse-apsl-standings']],
  'casa-liga1': ['make', ['-C', REPO, 'lighthouse-casa-liga1']],
  'casa-liga2': ['make', ['-C', REPO, 'lighthouse-casa-liga2']],
};

const server = http.createServer((req, res) => {
  const url = new URL(req.url, `http://localhost:${PORT}`);

  if (url.pathname !== '/run-task') {
    res.writeHead(404, { 'Content-Type': 'application/json' });
    res.end(JSON.stringify({ success: false, message: 'Not found' }));
    return;
  }

  const task = url.searchParams.get('task');
  if (!task || !ALLOWED_TASKS[task]) {
    res.writeHead(400, { 'Content-Type': 'application/json' });
    res.end(JSON.stringify({ success: false, message: `Unknown task: ${task}` }));
    return;
  }

  const [cmd, args] = ALLOWED_TASKS[task];
  const start = Date.now();
  console.log(`\n[task-server] ▶ ${task} started at ${new Date().toLocaleTimeString()}`);
  console.log(`[task-server]   ${cmd} ${args.join(' ')}\n`);

  const child = spawn(cmd, args, { cwd: REPO });
  let stderr = '';

  child.stdout.on('data', d => process.stdout.write(d));
  child.stderr.on('data', d => { process.stderr.write(d); stderr += d.toString(); });

  const timer = setTimeout(() => {
    child.kill();
    console.error(`[task-server] TIMEOUT after 180s`);
    res.writeHead(500, { 'Content-Type': 'application/json' });
    res.end(JSON.stringify({ success: false, message: 'Timed out after 180s' }));
  }, 180000);

  child.on('close', code => {
    clearTimeout(timer);
    const elapsed = ((Date.now() - start) / 1000).toFixed(1);
    if (code === 0) {
      console.log(`\n[task-server] ✓ ${task} done in ${elapsed}s`);
      res.writeHead(200, { 'Content-Type': 'application/json' });
      res.end(JSON.stringify({ success: true, task, elapsed }));
    } else {
      console.error(`\n[task-server] ✗ ${task} failed (exit ${code}) after ${elapsed}s`);
      res.writeHead(500, { 'Content-Type': 'application/json' });
      res.end(JSON.stringify({ success: false, message: `exit code ${code}`, stderr: stderr.slice(-500) }));
    }
  });
});

server.listen(PORT, '0.0.0.0', () => {
  console.log(`[task-server] Listening on 0.0.0.0:${PORT}`);
});
