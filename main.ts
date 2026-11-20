// The roblox-brainrot-01 entry for Rotting Brain (Node 22, standard library only): a 3D Roblox brainrot
// game. game.rbxl is the place saved from Roblox Studio and src/ mirrors its scripts in the Rojo layout.
// The program hands the entry in: it copies game.rbxl, src/, screenshots/ and PLAY.json from beside this
// file to /output and writes /output/dossier.json, the summary the judge reads, with the vendored make.fun
// library.
//
// Every name under /output starts with a letter, a digit or _ and holds only letters, digits, . _ and -: the
// grader fails an entry whose output holds any other, so a file such as .gitkeep or .DS_Store copied in fails it.
// So src/ and screenshots/ are copied without any name that starts with a dot, at any depth.
//
// Outside the grader's container, MAKEFUN_OUTPUT_DIR stands in for /output:
//   mkdir -p out && MAKEFUN_OUTPUT_DIR=out node main.ts

import { copyFileSync, cpSync, existsSync, mkdirSync, readdirSync, statSync, writeFileSync } from 'node:fs';
import { basename, extname, join } from 'node:path';
import { fileURLToPath } from 'node:url';
import { buildDossier } from './vendor/makefun-roblox.ts';

const here = fileURLToPath(new URL('.', import.meta.url));
const out = process.env.MAKEFUN_OUTPUT_DIR ?? '/output';

/** cpSync's filter: leave out every file and directory whose name starts with a dot (.gitkeep, .DS_Store, .git). */
const notDotted = (path: string): boolean => !basename(path).startsWith('.');

copyFileSync(join(here, 'game.rbxl'), join(out, 'game.rbxl'));
copyFileSync(join(here, 'PLAY.json'), join(out, 'PLAY.json'));
cpSync(join(here, 'src'), join(out, 'src'), { recursive: true, filter: notDotted });
mkdirSync(join(out, 'screenshots'), { recursive: true });
if (existsSync(join(here, 'screenshots'))) cpSync(join(here, 'screenshots'), join(out, 'screenshots'), { recursive: true, filter: notDotted });

const shots = readdirSync(join(here, 'screenshots')).filter((name) => !name.startsWith('.'));
if (shots.length < 3 || shots.length > 4) {
  process.stderr.write(`screenshots/: ${shots.length} files, must hold 3 or 4\n`);
  process.exit(1);
}
for (const name of shots) {
  const ext = extname(name).toLowerCase();
  if (ext !== '.png' && ext !== '.jpg' && ext !== '.jpeg') {
    process.stderr.write(`screenshots/${name}: must end in .png, .jpg or .jpeg\n`);
    process.exit(1);
  }
  const bytes = statSync(join(here, 'screenshots', name)).size;
  if (bytes > 262144) {
    process.stderr.write(`screenshots/${name}: ${bytes} bytes, must be at most 262144\n`);
    process.exit(1);
  }
}

// The scorer's own caps (reference/gate.json): only text_max_bytes shapes the bytes; the others refuse an entry the
// scorer would refuse (more than 4 screenshots or one over 256 KiB; a place of more than 500000 instances, whose
// scripts' sources come to over 8 MiB or whose scripts' paths come to over 1048576 characters, in all).
writeFileSync(
  join(out, 'dossier.json'),
  buildDossier(out, { text_max_bytes: 65536, screenshots: { max: 4, max_bytes: 262144 }, max_instances: 500000, scripts_max_source_bytes: 8388608, scripts_max_path_chars: 1048576 }),
);
