#!/usr/bin/env python3
# scan_exes.py - Standalone PE scanner for x86 executables
import os, sys, struct, json, re

def scan_exe(filepath):
    with open(filepath, 'rb') as f:
        data = f.read()
    if len(data) < 0x200 or data[:2] != b'MZ':
        return None
    pe_off = struct.unpack_from('<I', data, 0x3C)[0]
    if data[pe_off:pe_off+4] != b'PE\x00\x00':
        return None

    # COFF Header
    machine = struct.unpack_from('<H', data, pe_off+4)[0]
    num_sections = struct.unpack_from('<H', data, pe_off+6)[0]
    timestamp = struct.unpack_from('<I', data, pe_off+8)[0]
    
    # Optional Header (assume PE32 for x86)
    opt_off = pe_off + 24
    magic = struct.unpack_from('<H', data, opt_off)[0]
    if magic != 0x10b:  # Not PE32
        return None
    
    opt_header_size = struct.unpack_from('<H', data, opt_off+16)[0]
    entry_rva = struct.unpack_from('<I', data, opt_off+0x10)[0]
    img_base = struct.unpack_from('<I', data, opt_off+0x1C)[0]
    entry_point = img_base + entry_rva
    
    # Sections
    sec_off = opt_off + opt_header_size
    sections = []
    for i in range(num_sections):
        off = sec_off + i * 40
        name = data[off:off+8].split(b'\x00')[0].decode('ascii', errors='ignore')
        vsize = struct.unpack_from('<I', data, off+8)[0]
        rva = struct.unpack_from('<I', data, off+12)[0]
        char = struct.unpack_from('<I', data, off+36)[0]
        sections.append({
            'name': name,
            'rva': hex(rva),
            'vsize': vsize,
            'executable': bool(char & 0x20000000),
            'writable': bool(char & 0x80000000)
        })

    # Strings filtering
    strings = set()
    ascii_re = re.compile(rb'[\x20-\x7E]{4,}')
    for m in ascii_re.finditer(data):
        s = m.group().decode('ascii', errors='ignore').strip()
        if 4 < len(s) < 128:
            strings.add(s)
            
    keywords = ['engine.dll', 'winmain', 'game', 'render', 'physics', 'lua', 
                'directx', 'pak', 'save', 'level', 'config', 'options', 'autoexec']
    interesting = sorted([s for s in strings if any(k in s.lower() for k in keywords)])

    return {
        'file': os.path.basename(filepath),
        'size': len(data),
        'timestamp': timestamp,
        'image_base': hex(img_base),
        'entry_point': hex(entry_point),
        'sections': sections,
        'interesting_strings': interesting[:40]
    }

def main():
    target_dir = sys.argv[1] if len(sys.argv) > 1 else '.'
    results = []
    for f in sorted(os.listdir(target_dir)):
        if f.lower().endswith('.exe'):
            path = os.path.join(target_dir, f)
            res = scan_exe(path)
            if res:
                results.append(res)
                print(f"✓ {res['file']} | Entry: {res['entry_point']} | Base: {res['image_base']} | Secs: {len(res['sections'])}")
    
    out_path = 'exe_scan_report.json'
    with open(out_path, 'w') as out:
        json.dump(results, out, indent=2, ensure_ascii=False)
    print(f"\n📄 Saved to {out_path}")

if __name__ == '__main__':
    main()