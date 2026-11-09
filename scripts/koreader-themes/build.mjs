// Draws Babel's Bookshelf themes and writes them into the KOReader plugin.
//
//   node scripts/koreader-themes/build.mjs
//
// drawing.js runs in Chromium (Playwright) to paint each piece on a canvas; this script writes
// every pack into babel.koplugin/themes/<id>/ and babel_themes.lua, the list the plugin installs
// from (with a version per pack, so an e-reader gets a redrawn pack again).
import { createHash } from "node:crypto";
import { mkdirSync, readFileSync, readdirSync, rmSync, statSync, writeFileSync } from "node:fs";
import { createRequire } from "node:module";
import { dirname, join, relative } from "node:path";
import { fileURLToPath } from "node:url";
import { crc32 } from "node:zlib";

const require = createRequire(import.meta.url);
const { chromium } = require("playwright");

const HERE = dirname(fileURLToPath(import.meta.url));
const PLUGIN = join(HERE, "../../api/src/babel_api/plugins/koreader/babel.koplugin");
const OUT = join(PLUGIN, "themes");

// accent: progress bar and bookmark; track: progress track; plank: the shelf's own colour.
const PACKS = [
  {
    id: "academia",
    folder: "Babel Cabinet de lecture",
    name: "Cabinet de lecture",
    description: "Walnut panelling in lamplight, a green banker's lamp and a stack of old books.",
    hero: "bankers-lamp",
    colours: { text: "#EFE4C8", accent: "#C9A865", track: "#4A3A28", panel: "#100B07", plank: "#4A2816" },
  },
  {
    id: "nebula",
    folder: "Babel Nebuleuse",
    name: "Nébuleuse",
    description: "A nebula sky, a silvery shelf with a glowing edge, crystals and a potion.",
    hero: "crystals",
    colours: { text: "#EEF2FF", accent: "#9FE3FF", track: "#2A3358", panel: "#080A1E", plank: "#A8ADC2" },
  },
  {
    id: "crypt",
    folder: "Babel Crypte",
    name: "Crypte",
    description: "Old stone by candlelight, an iron-bound shelf, a candelabrum and a grimoire.",
    hero: "candelabrum",
    colours: { text: "#E6DCCB", accent: "#A3232F", track: "#3A3236", panel: "#0A080A", plank: "#2A2018" },
  },
  {
    id: "arabesque",
    folder: "Babel Arabesque",
    name: "Arabesque",
    description: "Art nouveau stems and poppies, a gilded whiplash shelf, a Gallé vase and a Tiffany lamp.",
    hero: "tiffany-lamp",
    colours: { text: "#F1E6CC", accent: "#D6B46E", track: "#33463C", panel: "#121C17", plank: "#7A5430" },
  },
  {
    id: "emerald",
    folder: "Babel Emeraude",
    name: "Émeraude",
    description: "Art deco fans in green and gold, a black marble shelf, a fan lamp and champagne coupes.",
    hero: "fan-lamp",
    colours: { text: "#F3E6C4", accent: "#D4AF64", track: "#1E3A2E", panel: "#040C09", plank: "#1A1A1C" },
  },
];

function colours(c) {
  // The shelves are all dark, so the day and night sets are the same.
  const set = {
    text: c.text,
    "progress bar": c.accent,
    "progress track": c.track,
    bookmark: c.accent,
    panel: c.panel,
    "panel text": c.text,
    "selected shelf": c.accent,
    "selected shelf text": c.panel,
    page: c.panel,
    plank: c.plank,
  };
  return { day: set, night: { ...set } };
}

// Bookshelf reads where a plank end stops from a tEXt chunk "bookshelf" → "plank_end=N", which
// must come right after IHDR.
function withPlankEnd(png, end) {
  const data = Buffer.from(`bookshelf\0plank_end=${end}`, "latin1");
  const chunk = Buffer.alloc(12 + data.length);
  chunk.writeUInt32BE(data.length, 0);
  chunk.write("tEXt", 4, "latin1");
  data.copy(chunk, 8);
  chunk.writeUInt32BE(crc32(chunk.subarray(4, 8 + data.length)), 8 + data.length);
  const ihdrEnd = 8 + 8 + png.readUInt32BE(8) + 4;
  return Buffer.concat([png.subarray(0, ihdrEnd), chunk, png.subarray(ihdrEnd)]);
}

const decode = (url) => Buffer.from(url.slice(url.indexOf(",") + 1), "base64");

function walk(dir) {
  return readdirSync(dir).flatMap((f) => {
    const p = join(dir, f);
    return statSync(p).isDirectory() ? walk(p) : [p];
  });
}

const lua = (s) => `"${s.replaceAll("\\", "\\\\").replaceAll('"', '\\"')}"`;

const browser = await chromium.launch();
const page = await browser.newPage();
await page.setContent("<!doctype html><html><body></body></html>");
await page.addScriptTag({ content: readFileSync(join(HERE, "drawing.js"), "utf8") });

rmSync(OUT, { recursive: true, force: true });
const catalog = [];
for (const pack of PACKS) {
  const r = await page.evaluate((id) => renderTheme(id), pack.id);
  const root = join(OUT, pack.id);
  const theme = join(root, "theme");
  mkdirSync(theme, { recursive: true });
  writeFileSync(join(theme, "wallpaper.jpg"), decode(r.wallpaper));
  writeFileSync(join(theme, "plank.middle.png"), decode(r.middle));
  writeFileSync(join(theme, "plank.left.png"), withPlankEnd(decode(r.left), 70));
  writeFileSync(join(theme, "plank.right.png"), withPlankEnd(decode(r.right), 70));
  for (const [name, url] of Object.entries(r.ornaments)) writeFileSync(join(root, `${name}.png`), decode(url));
  const manifest = { name: pack.name, description: pack.description, shelf: "dark", hero: pack.hero };
  writeFileSync(join(theme, "theme.json"), `${JSON.stringify(manifest, null, 2)}\n`);
  writeFileSync(join(theme, "colours.json"), `${JSON.stringify(colours(pack.colours), null, 2)}\n`);

  const files = walk(root).map((p) => relative(root, p).split("\\").join("/")).sort();
  const digest = createHash("sha256");
  let size = 0;
  for (const f of files) {
    const bytes = readFileSync(join(root, f));
    digest.update(f);
    digest.update(bytes);
    size += bytes.length;
  }
  catalog.push({ pack, files, version: digest.digest("hex").slice(0, 12), size });
  console.log(`${pack.id}: ${files.length} files, ${Math.round(size / 1024)} KB`);
}
await browser.close();

const lines = [
  "-- The Bookshelf themes this plugin installs: written by scripts/koreader-themes/build.mjs, do not edit.",
  "-- Each is a folder of themes/ copied into Bookshelf's ornaments folder; version changes",
  "-- whenever a file of it does, so an e-reader gets the new drawing.",
  "return {",
];
for (const { pack, files, version, size } of catalog) {
  lines.push(
    "    {",
    `        id = ${lua(pack.id)},`,
    `        folder = ${lua(pack.folder)},`,
    `        name = ${lua(pack.name)},`,
    `        description = ${lua(pack.description)},`,
    `        version = ${lua(version)},`,
    `        size = ${size},`,
    "        files = {",
    ...files.map((f) => `            ${lua(f)},`),
    "        },",
    "    },",
  );
}
lines.push("}");
writeFileSync(join(PLUGIN, "babel_themes.lua"), `${lines.join("\n")}\n`);
