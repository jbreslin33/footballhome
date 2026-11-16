// Mixin.into(Target, Source) — copy Source's methods onto Target.
//
// For a screen too big for one file (GameCenterScreen, split 2026-11-16):
// each part is written as a plain class whose methods use `this` as the
// screen, and is mixed into the screen's prototype.  Statics are copied onto
// the class too.  A part never uses `super` (it would point at the part,
// not the screen's parent) — the screen class itself keeps every override.
const Mixin = {
  into(Target, Source) {
    for (const name of Object.getOwnPropertyNames(Source.prototype)) {
      if (name === 'constructor') continue;
      if (Object.prototype.hasOwnProperty.call(Target.prototype, name)) {
        console.warn(`[mixin] ${Target.name}.${name} already defined — ${Source.name} skipped it`);
        continue;
      }
      Object.defineProperty(Target.prototype, name, Object.getOwnPropertyDescriptor(Source.prototype, name));
    }
    for (const name of Object.getOwnPropertyNames(Source)) {
      if (['length', 'name', 'prototype'].includes(name)) continue;
      if (Object.prototype.hasOwnProperty.call(Target, name)) continue;
      Object.defineProperty(Target, name, Object.getOwnPropertyDescriptor(Source, name));
    }
  },
};

window.Mixin = Mixin;
