import fs from 'node:fs';
import path from 'node:path';
import katex from 'katex';
import { marked } from 'marked';

const SRC = process.argv[2];
const OUTDIR = process.argv[3];
const src = fs.readFileSync(SRC, 'utf8');

// Split the paper from the sealed claim map.
const splitAt = src.indexOf('## §B');
if (splitAt < 0) throw new Error('could not find §B split point');
const paperMd = src.slice(0, splitAt).replace(/---\s*---\s*$/, '').trimEnd();
const keyMd = src.slice(splitAt);

marked.setOptions({ gfm: true, breaks: false });

function render(md) {
  // Pull maths out before markdown parsing, put it back after.
  const store = [];
  const stash = (tex, display) => {
    const i = store.length;
    store.push(katex.renderToString(tex, {
      displayMode: display, throwOnError: false, strict: false,
    }));
    return `@@KTX${i}@@`;
  };
  let text = md
    .replace(/\$\$([\s\S]+?)\$\$/g, (_, tex) => stash(tex.trim(), true))
    .replace(/\$([^$\n]+?)\$/g, (_, tex) => stash(tex.trim(), false));
  let html = marked.parse(text);
  html = html.replace(/@@KTX(\d+)@@/g, (_, i) => store[Number(i)]);
  return html;
}

const css = `
@page { size: A4; margin: 18mm 16mm 16mm 16mm; }
* { box-sizing: border-box; }
body {
  font: 11.5pt/1.55 "Georgia","Times New Roman",serif;
  color: #111; margin: 0; -webkit-print-color-adjust: exact;
}
h1 { font-size: 19pt; margin: 0 0 4pt; letter-spacing: -0.01em; }
h2 { font-size: 14pt; margin: 22pt 0 8pt; padding-bottom: 4pt;
     border-bottom: 1.5px solid #111; break-after: avoid; }
h3 { font-size: 12pt; margin: 16pt 0 6pt; break-after: avoid; }
p { margin: 0 0 9pt; }
strong { font-weight: 700; }
hr { border: 0; border-top: 1px solid #ccc; margin: 14pt 0; }
ul, ol { margin: 0 0 9pt; padding-left: 20pt; }
li { margin-bottom: 4pt; }
table { border-collapse: collapse; width: 100%; margin: 10pt 0 14pt;
        font-size: 9.5pt; break-inside: avoid; }
th, td { border: 1px solid #bbb; padding: 5pt 7pt; text-align: left;
         vertical-align: top; }
th { background: #f0f0f0; font-weight: 700; }
code { font-family: "SFMono-Regular",Consolas,monospace; font-size: 9.5pt;
       background: #f2f2f2; padding: 1px 4px; border-radius: 2px; }
.katex { font-size: 1.05em; }
.katex-display { margin: 10pt 0; }

/* Keep a question and its maths together on one page. */
.q { break-inside: avoid; page-break-inside: avoid; }

.rubric { background: #f6f6f4; border-left: 3px solid #555;
          padding: 9pt 12pt 1pt; margin: 0 0 14pt; font-size: 10.5pt;
          break-inside: avoid; }
.rubric p:last-child { margin-bottom: 9pt; }
.sealed { text-align: center; border: 2px solid #111; padding: 12pt;
          margin: 0 0 18pt; font-weight: 700; font-size: 12pt; }
.foot { margin-top: 20pt; padding-top: 6pt; border-top: 1px solid #ccc;
        font-size: 8.5pt; color: #666; }
`;

function page(title, bodyHtml, footNote) {
  return `<!doctype html><html><head><meta charset="utf-8">
<title>${title}</title>
<link rel="stylesheet" href="katex.min.css">
<style>${css}</style></head><body>
${bodyHtml}
<div class="foot">${footNote}</div>
</body></html>`;
}

// Wrap each numbered question so it does not split across a page break.
function groupQuestions(html) {
  return html.replace(
    /(<p><strong>\d+\.[\s\S]*?)(?=<hr>|<div class="foot">|$)/g,
    (m) => `<div class="q">${m}</div>`
  );
}

// The instructions block at the top of the paper, highlighted.
function highlightRubric(html) {
  const start = html.indexOf('<p><strong>Cold.');
  const end = html.indexOf('<hr>', start);
  if (start < 0 || end < 0) return html;
  return html.slice(0, start) + '<div class="rubric">' +
         html.slice(start, end) + '</div>' + html.slice(end);
}

fs.mkdirSync(OUTDIR, { recursive: true });
fs.copyFileSync(
  path.join('node_modules/katex/dist/katex.min.css'),
  path.join(OUTDIR, 'katex.min.css')
);
fs.cpSync('node_modules/katex/dist/fonts', path.join(OUTDIR, 'fonts'),
          { recursive: true });

const paperHtml = page(
  'Layer 0 Diagnostic — Further Pure, Paper 1',
  highlightRubric(groupQuestions(render(paperMd))),
  'Layer 0 Diagnostic · Further Pure Paper 1 · 22 September 2026 · ' +
  'the claim map is in the separate KEY document — do not open it until marked.'
);

const keyHtml = page(
  'Layer 0 Diagnostic — Further Pure, Paper 1 — KEY',
  '<h1>Further Pure Paper 1 — Claim Map</h1>' +
  '<div class="sealed">DO NOT OPEN UNTIL THE PAPER IS FINISHED<br>' +
  'AND YOUR SOLID / RUSTY / GAP PREDICTIONS ARE WRITTEN DOWN</div>' +
  render(keyMd),
  'Layer 0 Diagnostic · Further Pure Paper 1 · claim map and marking guidance.'
);

fs.writeFileSync(path.join(OUTDIR, 'paper.html'), paperHtml);
fs.writeFileSync(path.join(OUTDIR, 'key.html'), keyHtml);
console.log('wrote paper.html and key.html to', OUTDIR);
