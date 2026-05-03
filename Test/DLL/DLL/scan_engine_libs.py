#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Painkiller Engine Library & Compiler Scanner
Scans PE files for: imported DLLs, version strings, compiler signatures, copyright
"""
import os, sys, re, struct, json, time
from collections import defaultdict
from pathlib import Path

# === КОНФИГ ===
DLL_DIR = r"C:\Users\tiamson\Desktop\PainEngine_Source\DLL"
DLLS_TO_SCAN = ["Engine.dll", "Engine2005.dll", "mss32.dll", "D3Dev.dll", "binkw32.dll"]  # добавь свои
MIN_STRING_LEN = 4
# === КОНЕЦ КОНФИГА ===

def read_pe_imports(filepath):
    """Extract imported DLLs and functions from PE file (basic parser)"""
    imports = defaultdict(list)
    try:
        with open(filepath, "rb") as f:
            data = f.read()
        if data[:2] != b"MZ":
            return imports
        # PE header offset
        pe_off = struct.unpack_from("<I", data, 0x3C)[0]
        if data[pe_off:pe_off+4] != b"PE\x00\x00":
            return imports
        # Optional header
        opt_off = pe_off + 0x18
        if struct.unpack_from("<H", data, opt_off)[0] == 0x20b:  # PE32+
            rva_off = opt_off + 0x70  # Import Table RVA (64-bit)
            img_base = struct.unpack_from("<Q", data, opt_off + 0x18)[0]
        else:  # PE32
            rva_off = opt_off + 0x5c
            img_base = struct.unpack_from("<I", data, opt_off + 0x1c)[0]
        import_rva = struct.unpack_from("<I", data, rva_off)[0]
        if not import_rva:
            return imports
        # Simple import table walk (may miss some edge cases)
        # For production use: use pefile library
        return imports  # placeholder - use pefile for full parsing
    except Exception as e:
        print(f"  [!] Error reading imports: {e}")
        return imports

def extract_strings(data, min_len=MIN_STRING_LEN):
    """Extract ASCII and UTF-16 strings from binary"""
    strings = set()
    # ASCII
    ascii_re = re.compile(rb"[\x20-\x7E]{%d,}" % min_len)
    for m in ascii_re.finditer(data):
        s = m.group().decode("ascii", errors="ignore").strip()
        if s and len(s) < 256:
            strings.add(s)
    # UTF-16LE
    utf16_re = re.compile(rb"(?:[\x20-\x7E]\x00){%d,}" % min_len)
    for m in utf16_re.finditer(data):
        try:
            s = m.group().decode("utf-16-le", errors="ignore").strip()
            if s and len(s) < 256:
                strings.add(s)
        except:
            pass
    return strings

def detect_compiler(strings, imports):
    """Heuristic compiler detection"""
    hints = []
    # MSVC signatures
    if any("msvcrt" in s.lower() or "msvcr" in s.lower() for s in strings):
        hints.append("MSVC CRT linked")
    if any("__CxxFrameHandler" in s or "_RTC" in s for s in strings):
        hints.append("MSVC SEH/RTC enabled")
    if any("libcpmt" in s.lower() or "MSVCP" in s for s in strings):
        hints.append("MSVC static C++ runtime")
    # GCC/MinGW
    if any("__gcc_" in s or "_Unwind" in s for s in strings):
        hints.append("GCC/MinGW runtime")
    # Delphi/Borland
    if any("BORLNDMM" in s or "System." in s for s in strings):
        hints.append("Delphi/Borland compiler")
    # DLL imports as hints
    dll_names = [dll.lower() for dll in imports.keys()]
    if "d3dx9_24.dll" in dll_names or "d3dx9_32.dll" in dll_names:
        hints.append("DirectX SDK Feb 2005 / Aug 2006")
    if "binkw32.dll" in dll_names:
        hints.append("Bink Video (RAD Game Tools)")
    if "mss32.dll" in dll_names:
        hints.append("Miles Sound System")
    return hints

def find_versions(strings):
    """Extract version-like patterns"""
    versions = defaultdict(list)
    patterns = {
        "Lua": r"Lua\s+(\d+\.\d+\.?\d*)",
        "Havok": r"[Hh]avok\s+([\d\.]+|\d{4})",
        "DirectX": r"Direct[Xx]\s+([\d\.]+[a-z]?)",
        "Bink": r"[Bb]ink\s+([\d\.]+)",
        "Miles": r"[Mm]iles\s+([\d\.]+)",
        "zlib": r"zlib\s+([\d\.]+)",
        "Copyright": r"\(c\)\s+(\d{4})",
        "Build": r"[Bb]uild\s+([\d\.]+)",
    }
    for s in strings:
        for lib, pattern in patterns.items():
            m = re.search(pattern, s, re.I)
            if m:
                versions[lib].append((s, m.group(1)))
    return versions

def scan_dll(filepath):
    """Scan single DLL and return structured findings"""
    print(f"Scanning: {os.path.basename(filepath)}")
    with open(filepath, "rb") as f:
        data = f.read()
    
    strings = extract_strings(data)
    imports = read_pe_imports(filepath)  # basic - extend with pefile if needed
    compiler_hints = detect_compiler(strings, imports)
    versions = find_versions(strings)
    
    # Categorize findings
    findings = defaultdict(list)
    for s in strings:
        if re.search(r"error|fail|assert|warning", s, re.I):
            findings["Error Messages"].append(s)
        if re.search(r"copyright|license|author", s, re.I):
            findings["Copyright/License"].append(s)
        if re.search(r"www\.|http://|https://", s):
            findings["URLs"].append(s)
        if re.search(r"dll|lib|\.sys|\.drv", s, re.I):
            findings["Referenced Files"].append(s)
    
    return {
        "file": os.path.basename(filepath),
        "size": len(data),
        "strings_count": len(strings),
        "compiler_hints": compiler_hints,
        "versions": {k: list(set(v)) for k, v in versions.items()},
        "findings": {k: list(set(v))[:10] for k, v in findings.items()},  # limit output
        "sample_strings": list(strings)[:20]  # preview
    }

def main():
    print("=== Painkiller Engine Library Scanner ===\n")
    results = []
    
    for dll in DLLS_TO_SCAN:
        path = os.path.join(DLL_DIR, dll)
        if not os.path.isfile(path):
            print(f"[!] Not found: {dll}")
            continue
        result = scan_dll(path)
        results.append(result)
        print(f"  ✓ Strings: {result['strings_count']}, Compiler: {result['compiler_hints']}\n")
    
    # Aggregate report
    report = {
        "scan_time": time.strftime("%Y-%m-%d %H:%M:%S"),
        "dlls_scanned": len(results),
        "summary": {},
        "details": results
    }
    
    # Aggregate versions across DLLs
    all_versions = defaultdict(set)
    all_compilers = set()
    for r in results:
        for lib, vers in r["versions"].items():
            all_versions[lib].update(v for _, v in vers)
        all_compilers.update(r["compiler_hints"])
    
    report["summary"]["detected_versions"] = {k: list(v) for k, v in all_versions.items()}
    report["summary"]["compiler_hints"] = list(all_compilers)
    report["summary"]["likely_third_party_libs"] = [
        "Lua 5.0.2", "Havok 2.x", "DirectX 9.0c", 
        "Miles Sound System", "Bink Video", "zlib"
    ]
    
    # Save report
    out_path = os.path.join(DLL_DIR, "engine_scan_report.json")
    with open(out_path, "w", encoding="utf-8") as f:
        json.dump(report, f, indent=2, ensure_ascii=False)
    
    # Print summary
    print("\n=== SUMMARY ===")
    print("Detected versions:")
    for lib, vers in report["summary"]["detected_versions"].items():
        print(f"  • {lib}: {vers}")
    print("\nCompiler hints:")
    for hint in report["summary"]["compiler_hints"]:
        print(f"  • {hint}")
    print(f"\nFull report saved to: {out_path}")

if __name__ == "__main__":
    if len(sys.argv) > 1:
        DLL_DIR = sys.argv[1]
    main()