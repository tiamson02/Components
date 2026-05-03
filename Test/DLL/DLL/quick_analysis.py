# @Category Analysis
# @description Quick analysis: imports, exports, sections, strings

import json

results = {
    "sections": [],
    "imports": [],
    "exports": [],
    "interesting_strings": []
}

# Sections
mem = currentProgram.getMemory()
for block in mem:
    results["sections"].append({
        "name": str(block.getName()),
        "start": hex(block.getStart().getOffset()),
        "end": hex(block.getEnd().getOffset()),
        "size": block.getSize(),
        "rwx": "%s%s%s" % ("R" if block.isRead() else "-", 
                           "W" if block.isWrite() else "-", 
                           "X" if block.isExecute() else "-")
    })

# Strings (interesting ones)
strings = currentProgram.getStringTable().getStrings()
keywords = ["GEngine", "World", "Script", "Physics", "Havok", "Lua", "DirectX", 
            "CreateFile", "socket", "WSA", "pak", "Save", "Load"]
for s in strings:
    val = s.getValue()
    if any(kw.lower() in val.lower() for kw in keywords):
        results["interesting_strings"].append({
            "address": hex(s.getAddress().getOffset()),
            "value": val[:100]
        })

# Save to file
out_path = r"C:\Users\tiamson\Desktop\PainEngine_Source\DLL\quick_analysis.json"
with open(out_path, "w") as f:
    json.dump(results, f, indent=2)

print("Analysis saved to: %s" % out_path)
print("Sections: %d" % len(results["sections"]))
print("Interesting strings: %d" % len(results["interesting_strings"]))