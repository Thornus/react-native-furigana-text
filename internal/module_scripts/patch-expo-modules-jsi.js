#!/usr/bin/env node
const fs = require('fs');
const path = require('path');

const TARGETS = [
  path.join(process.cwd(), 'node_modules', 'expo-modules-jsi', 'apple', 'Sources', 'ExpoModulesJSI-Cxx', 'include', 'RuntimeScheduler.h'),
];

const REPLACEMENTS = [
  {
    from: 'SWIFT_RETURNS_RETAINED RuntimeScheduler(void *scheduler, ScheduleFn fn) noexcept',
    to: 'RuntimeScheduler(void *scheduler, ScheduleFn fn) noexcept',
  },
  {
    from: 'SWIFT_RETURNS_RETAINED RuntimeScheduler() {}',
    to: 'RuntimeScheduler() {}',
  },
];

let patched = 0;
for (const target of TARGETS) {
  if (!fs.existsSync(target)) {
    continue;
  }
  let contents = fs.readFileSync(target, 'utf8');
  let changed = false;
  for (const { from, to } of REPLACEMENTS) {
    if (contents.includes(from)) {
      contents = contents.replace(from, to);
      changed = true;
    }
  }
  if (changed) {
    fs.writeFileSync(target, contents, 'utf8');
    patched++;
    console.log(`patched: ${path.relative(process.cwd(), target)}`);
  }
}
if (patched === 0) {
  console.log('patch-expo-modules-jsi: nothing to patch (already applied or target missing)');
}