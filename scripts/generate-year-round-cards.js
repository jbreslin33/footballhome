// scripts/generate-year-round-cards.js
// The three year-round player ads (owner 2026-10-28: "all year programs …
// Fall, Winter, Spring and Summer", 3 ads — Youth, Men, Women).  Same look
// as generate-club-wide-card.js; a four-season strip lights the season
// that is the reason to join NOW (youth: PPR indoor next; adults: spots
// open now).  Move the lit season when the season turns — the cards
// never carry a date, so they can run all year.
//
// Usage: node scripts/generate-year-round-cards.js
//   → frontend/images/posts/{youth,mens,womens}-year-round-ad.png
const puppeteer = require('puppeteer');
const fs = require('fs'), path = require('path');
const R = path.resolve(__dirname, '..', 'frontend', 'images');
const uri = p => 'data:image/' + (p.endsWith('.png') ? 'png' : 'jpeg') + ';base64,' + fs.readFileSync(p).toString('base64');
const crest = uri(R + '/teams/logos/lighthouse-1893.png');
const ppr = uri(R + '/leagues/phila-parks-rec.jpg');
const OUT = path.join(R, 'posts');
const css = `*{margin:0;padding:0;box-sizing:border-box}body{width:1080px;height:1080px;overflow:hidden;font-family:'Segoe UI','Helvetica Neue',Arial,sans-serif;color:#fff}
.card{width:1080px;height:1080px;position:relative;background:radial-gradient(ellipse at 30% 20%,#1a3a8a 0%,#0d2247 45%,#060f25 100%);padding:60px}
.pattern{position:absolute;inset:0;opacity:.06;background-image:radial-gradient(#fff 1px,transparent 1px);background-size:22px 22px}
.gb{position:absolute;left:0;right:0;height:12px;background:#f5d442}.t{top:0}.b{bottom:0}
.header{display:flex;align-items:center;gap:24px;margin-top:8px}.header img{height:130px}
.club{font-size:30px;font-weight:900;letter-spacing:2px}.since{font-size:18px;color:#f5d442;font-weight:700;letter-spacing:4px}
.badge{margin-left:auto;height:110px;width:110px;border-radius:50%;border:4px solid #f5d442;background:#fff;display:flex;align-items:center;justify-content:center;overflow:hidden}.badge img{height:96px}
.ballc{margin-left:auto;width:110px;height:110px;border-radius:50%;background:#0d2247;border:4px solid #f5d442;display:flex;align-items:center;justify-content:center;font-size:64px}
.hero{margin-top:26px;text-align:center}.kicker{font-size:28px;letter-spacing:14px;color:#f5d442;font-weight:800;text-transform:uppercase}
h1{font-size:112px;font-weight:900;line-height:.95;margin-top:14px;text-shadow:0 6px 24px rgba(0,0,0,.55)}h1 .a{color:#f5d442}
.sub{font-size:36px;font-weight:700;margin-top:22px}.sub strong{color:#f5d442}
.her{margin-top:16px;font-size:22px;font-weight:800;letter-spacing:1.5px;color:#f5d442;line-height:1.35}
.pills{display:flex;justify-content:center;gap:14px;margin-top:14px}.pill{background:rgba(245,212,66,.18);border:2px solid rgba(245,212,66,.55);color:#f5d442;padding:12px 26px;border-radius:999px;font-size:22px;font-weight:800;letter-spacing:1px}
.cta{margin-top:24px;background:#f5d442;color:#0a1628;border-radius:16px;padding:16px 24px;text-align:center}.cta .top{font-size:18px;font-weight:800;letter-spacing:3px}.cta .bot{font-size:28px;font-weight:900;margin-top:4px}
.yr{margin-top:20px;text-align:center;font-size:20px;font-weight:900;letter-spacing:6px;color:#f5d442}.seasons{display:flex;justify-content:center;gap:12px;margin-top:10px}.s{flex:1;background:rgba(255,255,255,.08);border:1px solid rgba(255,255,255,.2);border-radius:14px;padding:12px 6px;text-align:center}.s .i{font-size:34px}.s .l{font-size:19px;font-weight:900;letter-spacing:2px;margin-top:4px}.s .d{font-size:15px;opacity:.85;margin-top:2px}.s.now{background:rgba(245,212,66,.2);border:2px solid #f5d442}.s.now .l{color:#f5d442}
.venue{position:absolute;bottom:44px;left:60px;right:60px;background:rgba(255,255,255,.1);border:3px solid rgba(245,212,66,.65);border-radius:20px;padding:16px 20px;text-align:center}
.venue .n{font-size:44px;font-weight:900;color:#f5d442}.venue .ad{font-size:30px;font-weight:700;margin-top:8px}`;
const card = (o) => `<!DOCTYPE html><html><head><meta charset="utf-8"><style>${css}</style></head><body><div class="card"><div class="pattern"></div><div class="gb t"></div>
<div class="header"><img src="${crest}"><div><div class="club">LIGHTHOUSE 1893 SC</div><div class="since">EST. ${o.est} · PHILADELPHIA</div></div>${o.badge}</div>
<div class="hero"><div class="kicker">${o.kicker}</div><h1>${o.h1}</h1><div class="sub">${o.sub}</div><div class="her">${o.her}</div></div>
<div class="pills">${o.pills.map(p=>`<div class="pill">${p}</div>`).join('')}</div>
<div class="yr">FULL-YEAR PROGRAM</div><div class="seasons">${o.seasons.map(([i,l,d,n])=>`<div class="s${n?" now":""}"><div class="i">${i}</div><div class="l">${l}</div><div class="d">${d}</div></div>`).join("")}</div>
<div class="venue"><div class="n">LIGHTHOUSE SPORTS COMPLEX</div><div class="ad">199 East Erie Avenue · Philadelphia, PA</div></div>
<div class="gb b"></div></div></body></html>`;
const ball = '<div class="ballc">⚽</div>';
const cards = {
 'youth-year-round-ad': {est:'1897', badge:`<div class="badge"><img src="${ppr}"></div>`, kicker:'Boys & Girls · Join Now', h1:'SOCCER <span class="a">ALL</span><br><span class="a">YEAR</span> ROUND', sub:'Join any time · <strong>All skill levels welcome</strong>', her:"Philadelphia's oldest non-profit ⚽ club", pills:['BOYS','GIRLS'],
   seasons:[['🍂','FALL','Outdoor league'],['❄️','WINTER','PPR indoor'],['🌸','SPRING','Outdoor league'],['☀️','SUMMER','Training']]},
 'mens-year-round-ad': {est:'1893', badge:ball, kicker:"Men's Club · Join Now", h1:'SOCCER <span class="a">ALL</span><br><span class="a">YEAR</span> ROUND', sub:'<strong>APSL &amp; CASA Liga 1</strong> · Open to new players', her:"America's oldest active ⚽ club", pills:['MEN'],
   seasons:[['🍂','FALL','League games'],['❄️','WINTER','Indoor training'],['🌸','SPRING','League games'],['☀️','SUMMER','Training']]},
 'womens-year-round-ad': {est:'1895', badge:ball, kicker:"Women's Club · Join Now", h1:'SOCCER <span class="a">ALL</span><br><span class="a">YEAR</span> ROUND', sub:'<strong>Tri County Womens League</strong> · Open to new players', her:"Philadelphia's oldest non-profit ⚽ club", pills:['WOMEN'],
   seasons:[['🍂','FALL','League games'],['❄️','WINTER','Indoor training'],['🌸','SPRING','League games'],['☀️','SUMMER','Training']]},
};
(async()=>{const b=await puppeteer.launch({headless:'new',args:['--no-sandbox']});const pg=await b.newPage();await pg.setViewport({width:1080,height:1080});
for(const [k,o] of Object.entries(cards)){const pg=await b.newPage();await pg.setViewport({width:1080,height:1080});await pg.setContent(card(o),{waitUntil:'load'});await pg.screenshot({path:path.join(OUT,k+'.png')});console.log(k)}
await b.close()})();
