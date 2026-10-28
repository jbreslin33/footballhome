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
//     + club-year-round-post.png (the free all-programs post)
const puppeteer = require('puppeteer');
const fs = require('fs'), path = require('path');
const R = path.resolve(__dirname, '..', 'frontend', 'images');
const uri = p => 'data:image/' + (p.endsWith('.png') ? 'png' : 'jpeg') + ';base64,' + fs.readFileSync(p).toString('base64');
const crest = uri(R + '/teams/logos/lighthouse-1893.png');
const ppr = uri(R + '/leagues/phila-parks-rec.jpg');
const icsl = uri(R + '/leagues/icsl.png');
const epysa = uri(R + '/leagues/epysa.png');
const L = f => uri(R + '/leagues/' + f);
// League/federation badges in the header, left → right.  Wide marks get
// class wide so they fill the circle across instead of shrinking.
// Every card closes on US Soccer + FIFA (owner 2026-10-28: "for all we
// should have us soccer, fifa").
const FED = [[uri(R + '/leagues/ussoccer.png')], [uri(R + '/leagues/fifa.png'), 1]];
const badges = (list) => `<div class="badges${list.length + FED.length > 3 ? ' sm' : ''}">${[...list, ...FED].map(([src, wide]) => `<div class="badge"><img${wide ? ' class="wide"' : ''} src="${src}"></div>`).join('')}</div>`;
const OUT = path.join(R, 'posts');
const css = `*{margin:0;padding:0;box-sizing:border-box}body{width:1080px;height:1080px;overflow:hidden;font-family:'Segoe UI','Helvetica Neue',Arial,sans-serif;color:#fff}
.card{width:1080px;height:1080px;position:relative;background:radial-gradient(ellipse at 30% 20%,#1a3a8a 0%,#0d2247 45%,#060f25 100%);padding:60px}
.pattern{position:absolute;inset:0;opacity:.06;background-image:radial-gradient(#fff 1px,transparent 1px);background-size:22px 22px}
.gb{position:absolute;left:0;right:0;height:12px;background:#f5d442}.t{top:0}.b{bottom:0}
.header{display:flex;align-items:center;gap:24px;margin-top:8px}.header img{height:130px}
.club{font-size:30px;font-weight:900;letter-spacing:2px}.since{font-size:18px;color:#f5d442;font-weight:700;letter-spacing:4px}
.badge{margin-left:auto;height:110px;width:110px;border-radius:50%;border:4px solid #f5d442;background:#fff;display:flex;align-items:center;justify-content:center;overflow:hidden}.badge img{height:96px}
.badges{margin-left:auto;display:flex;gap:12px}.badges .badge{margin-left:0}.badge img.wide{height:auto;width:92px}.header:has(.badges.sm){gap:18px}.header:has(.badges.sm) .club{font-size:25px;white-space:nowrap}.header:has(.badges.sm) .since{font-size:15px;letter-spacing:3px;white-space:nowrap}.strip{display:flex;justify-content:space-between;margin-top:18px}.strip .badge{margin-left:0;height:96px;width:96px;border-width:3px}.strip .badge img{height:80px}.strip .badge img.wide{height:auto;width:80px}
.card.post .header{justify-content:center;margin-top:0}.card.post .seasons{margin-top:18px}.card.post .acts{margin-top:22px}.card.post .header img{height:112px}.card.post .hero{margin-top:14px}.card.post .yr{margin-top:12px}.card.post .pills.tight{row-gap:8px;margin-top:10px}
.card.post .venue{bottom:146px}.card.post .strip{position:absolute;left:60px;right:60px;bottom:34px;margin-top:0}
.card.post h1{font-size:90px;white-space:nowrap;margin-top:18px}.card.post h1 .ball{font-size:76px;vertical-align:6px}
.card.post .strip .badge img.wide{height:auto}
.badges.sm{gap:8px}.badges.sm .badge{height:84px;width:84px;border-width:3px}.badges.sm .badge img{height:70px}.badges.sm .badge img.wide{height:auto;width:70px}
.ballc{margin-left:auto;width:110px;height:110px;border-radius:50%;background:#0d2247;border:4px solid #f5d442;display:flex;align-items:center;justify-content:center;font-size:64px}
.hero{margin-top:26px;text-align:center}.kicker{font-size:28px;letter-spacing:14px;color:#f5d442;font-weight:800;text-transform:uppercase}
h1{font-size:112px;font-weight:900;line-height:.95;margin-top:14px;text-shadow:0 6px 24px rgba(0,0,0,.55)}h1 .a{color:#f5d442}
.sub{font-size:36px;font-weight:700;margin-top:22px}.sub strong{color:#f5d442}
.her{margin-top:16px;font-size:22px;font-weight:800;letter-spacing:1.5px;color:#f5d442;line-height:1.35}
.pills{display:flex;justify-content:center;gap:14px;margin-top:14px}.pill{background:rgba(245,212,66,.18);border:2px solid rgba(245,212,66,.55);color:#f5d442;padding:12px 26px;border-radius:999px;font-size:22px;font-weight:800;letter-spacing:1px}
.pills.tight{gap:10px;flex-wrap:wrap}.pills .brk{flex-basis:100%;height:0}.pills.tight .pill{padding:10px 16px;font-size:18px;white-space:nowrap;letter-spacing:.5px}.pill.price{background:#f5d442;border-color:#f5d442;color:#0a1628;font-weight:900}
.cta{margin-top:24px;background:#f5d442;color:#0a1628;border-radius:16px;padding:16px 24px;text-align:center}.cta .top{font-size:18px;font-weight:800;letter-spacing:3px}.cta .bot{font-size:28px;font-weight:900;margin-top:4px}
.yr{margin-top:20px;text-align:center;font-size:20px;font-weight:900;letter-spacing:6px;color:#f5d442}.seasons{display:flex;justify-content:center;gap:12px;margin-top:10px}.s{flex:1;background:rgba(255,255,255,.08);border:1px solid rgba(255,255,255,.2);border-radius:14px;padding:10px 6px;text-align:center;display:flex;flex-direction:column;justify-content:center}.s .i{font-size:30px}.s .l{font-size:19px;font-weight:900;letter-spacing:2px;margin-top:4px}.s .d{font-size:15px;opacity:.85;margin-top:2px}.s.now{background:rgba(245,212,66,.2);border:2px solid #f5d442}.s.now .l{color:#f5d442}
.acts{display:flex;justify-content:center;gap:12px;margin-top:12px}.act{flex:1;background:rgba(245,212,66,.14);border:2px solid rgba(245,212,66,.5);border-radius:14px;padding:12px 6px;text-align:center;font-size:22px;font-weight:900;letter-spacing:1px;color:#f5d442}.act .i{margin-right:8px}
.venue{position:absolute;bottom:44px;left:60px;right:60px;background:rgba(255,255,255,.1);border:3px solid rgba(245,212,66,.65);border-radius:20px;padding:16px 20px;text-align:center}
.venue .n{font-size:44px;font-weight:900;color:#f5d442}.venue .ad{font-size:30px;font-weight:700;margin-top:8px}`;
const card = (o) => `<!DOCTYPE html><html><head><meta charset="utf-8"><style>${css}</style></head><body><div class="card${o.strip ? ' post' : ''}"><div class="pattern"></div><div class="gb t"></div>
<div class="header"><img src="${crest}"><div><div class="club">LIGHTHOUSE 1893 SC</div><div class="since">EST. ${o.est} · PHILADELPHIA</div></div>${o.badge}</div>
<div class="hero"><div class="kicker">${o.kicker}</div><h1>${o.h1}</h1><div class="sub">${o.sub}</div><div class="her">${o.her}</div></div>
<div class="pills${o.pills.length>2?' tight':''}">${o.pills.map(p=>`<div class="pill">${p}</div>`).join('')}${o.pills.length>2?'<div class="brk"></div>':''}<div class="pill price">${PRICE}</div></div>
<div class="yr">FULL-YEAR PROGRAM</div><div class="seasons">${o.seasons.map(([i,l,d])=>`<div class="s"><div class="i">${i}</div><div class="l">${l}</div>${d?`<div class="d">${d}</div>`:""}</div>`).join("")}</div><div class="acts">${ACTS.map(l=>`<div class="act">${l}</div>`).join("")}</div>
${o.strip || ''}<div class="venue"><div class="n">LIGHTHOUSE SPORTS COMPLEX</div><div class="ad">199 East Erie Avenue · Philadelphia, PA</div></div>
<div class="gb b"></div></div></body></html>`;
// Header badges (owner 2026-10-28): youth ICSL + EPYSA + PPR; women EPSA +
// Tri County; men APSL + CASA + EPSA + US Soccer (FIFA left off).
// What the club does in every season — its own row, not per season
// (owner 2026-10-28: "League Games, Training, Tournaments in its own cube").
// Text only (owner 2026-10-28: "don't like target for training" — the
// season tiles carry the icons).
const ACTS = ['LEAGUE GAMES','TRAINING','TOURNAMENTS'];
// Cost up front (owner 2026-10-28: "$35/month uniform included") — the
// club-wide dues_policies rate; captions carry it via mig 789.
const PRICE = '$35/MONTH MEMBERSHIP · UNIFORM INCLUDED';
const ball = '<div class="ballc">⚽</div>';
const cards = {
 'youth-year-round-ad': {est:'1897', badge:badges([[icsl, 1], [epysa], [ppr]]), kicker:'Boys & Girls · Grades K–9', h1:'SOCCER <span class="a">ALL</span><br><span class="a">YEAR</span> ROUND', sub:'Join Anytime · <strong>All Skill Levels Welcome</strong>', her:"Philadelphia's oldest non-profit ⚽ club", pills:[],
   seasons:[['🍂','FALL',''],['❄️','WINTER','Indoor'],['🌸','SPRING',''],['☀️','SUMMER','']]},
 // Free organic post (owner 2026-10-28): every program on one card,
 // "registration links in bio" — not an ad, posted from #promotional-posts.
 'club-year-round-post': {est:'1893', badge:'', strip:`<div class="strip">${[[icsl, 1], [epysa], [ppr], [L('apsl.png')], [L('casa.png')], [L('epsa.png'), 1], [L('tcwsl.png')], ...FED].map(([src, wide]) => `<div class="badge"><img${wide ? ' class="wide"' : ''} src="${src}"></div>`).join('')}</div>`, kicker:'Registration links in bio', h1:'<span class="ball">⚽</span> <span class="a">ALL YEAR</span> ROUND', sub:'Join Anytime · <strong>All Skill Levels Welcome</strong>', her:"America's oldest active ⚽ club", pills:['MEN 16+','WOMEN 18+','BOYS &amp; GIRLS K–9'],
   seasons:[['🍂','FALL',''],['❄️','WINTER','Indoor'],['🌸','SPRING',''],['☀️','SUMMER','']]},
 'mens-year-round-ad': {est:'1893', badge:badges([[L('apsl.png')], [L('casa.png')], [L('epsa.png'), 1]]), kicker:"Men's Club", h1:'SOCCER <span class="a">ALL</span><br><span class="a">YEAR</span> ROUND', sub:'Join Anytime · <strong>All Skill Levels Welcome</strong>', her:"America's oldest active ⚽ club", pills:[],
   seasons:[['🍂','FALL',''],['❄️','WINTER','Indoor'],['🌸','SPRING',''],['☀️','SUMMER','']]},
 'womens-year-round-ad': {est:'1895', badge:badges([[L('epsa.png'), 1], [L('tcwsl.png')]]), kicker:"Women's Club", h1:'SOCCER <span class="a">ALL</span><br><span class="a">YEAR</span> ROUND', sub:'Join Anytime · <strong>All Skill Levels Welcome</strong>', her:"Philadelphia's oldest non-profit ⚽ club", pills:[],
   seasons:[['🍂','FALL',''],['❄️','WINTER','Indoor'],['🌸','SPRING',''],['☀️','SUMMER','']]},
};
(async()=>{const b=await puppeteer.launch({headless:'new',args:['--no-sandbox']});const pg=await b.newPage();await pg.setViewport({width:1080,height:1080});
for(const [k,o] of Object.entries(cards)){const pg=await b.newPage();await pg.setViewport({width:1080,height:1080});await pg.setContent(card(o),{waitUntil:'load'});await pg.screenshot({path:path.join(OUT,k+'.png')});console.log(k)}
await b.close()})();
