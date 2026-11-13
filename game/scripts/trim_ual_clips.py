#!/usr/bin/env python3
"""trim_ual_clips.py — keep only the named animation clips (and the node tree they drive) from a glTF
binary, for frontend/game-assets/ual/ (G5.105 viewer locomotion). No meshes, no skins, no materials.

    python3 -I game/scripts/trim_ual_clips.py <in.glb> <out.glb> Clip1 Clip2 ...

Source pack: Quaternius "Universal Animation Library" Standard (CC0 1.0). FH original."""
import json, struct, sys

def main(src, dst, names):
    b = open(src, 'rb').read()
    jl = struct.unpack('<I', b[12:16])[0]; j = json.loads(b[20:20 + jl])
    o = 20 + jl; bl = struct.unpack('<I', b[o:o + 4])[0]; bin_ = b[o + 8:o + 8 + bl]
    anims = [a for a in j['animations'] if a['name'] in names]
    missing = set(names) - {a['name'] for a in anims}
    if missing: sys.exit(f"missing clips: {sorted(missing)}")
    out = bytearray(); views = []; accs = []; amap = {}
    def take(i):
        if i in amap: return amap[i]
        a = dict(j['accessors'][i]); v = j['bufferViews'][a['bufferView']]
        nc = {'SCALAR': 1, 'VEC2': 2, 'VEC3': 3, 'VEC4': 4}[a['type']]; size = 4 * nc
        st = v.get('byteStride', size); start = v.get('byteOffset', 0) + a.get('byteOffset', 0)
        while len(out) % 4: out.append(0)
        off = len(out)
        for k in range(a['count']): out.extend(bin_[start + k * st:start + k * st + size])
        views.append({'buffer': 0, 'byteOffset': off, 'byteLength': a['count'] * size})
        a['bufferView'] = len(views) - 1; a.pop('byteOffset', None); a.pop('sparse', None)
        accs.append(a); amap[i] = len(accs) - 1
        return amap[i]
    for a in anims:
        for s in a['samplers']: s['input'] = take(s['input']); s['output'] = take(s['output'])
    nodes = [{k: v for k, v in n.items() if k in ('name', 'children', 'translation', 'rotation', 'scale')} for n in j['nodes']]
    scene = j['scenes'][j.get('scene', 0)]
    g = {'asset': {'version': '2.0', 'generator': 'FH trim_ual_clips.py (Quaternius UAL, CC0)'},
         'scene': 0, 'scenes': [{'nodes': scene['nodes']}], 'nodes': nodes, 'animations': anims,
         'accessors': accs, 'bufferViews': views, 'buffers': [{'byteLength': len(out)}]}
    js = json.dumps(g, separators=(',', ':')).encode()
    while len(js) % 4: js += b' '
    while len(out) % 4: out.append(0)
    total = 12 + 8 + len(js) + 8 + len(out)
    with open(dst, 'wb') as f:
        f.write(struct.pack('<III', 0x46546C67, 2, total))
        f.write(struct.pack('<II', len(js), 0x4E4F534A)); f.write(js)
        f.write(struct.pack('<II', len(out), 0x004E4942)); f.write(out)
    print(f"{dst}: {len(anims)} clips, {total} bytes")

if __name__ == '__main__':
    main(sys.argv[1], sys.argv[2], sys.argv[3:])
