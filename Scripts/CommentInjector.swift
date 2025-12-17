#!/usr/bin/env swift
import Foundation

struct Options {
    let root: URL
    let dryRun: Bool
    let reportPath: URL?
}

func parseOptions() -> Options {
    var rootPath = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
    var dryRun = false
    var reportPath: URL? = nil
    var i = 1
    let args = CommandLine.arguments
    while i < args.count {
        let arg = args[i]
        switch arg {
        case "--path":
            if i + 1 < args.count { rootPath = URL(fileURLWithPath: args[i+1]); i += 1 }
        case "--dry-run":
            dryRun = true
        case "--report":
            if i + 1 < args.count { reportPath = URL(fileURLWithPath: args[i+1]); i += 1 }
        default: break
        }
        i += 1
    }
    return Options(root: rootPath, dryRun: dryRun, reportPath: reportPath)
}

let opts = parseOptions()

let swiftCommentDocRegex = try! NSRegularExpression(pattern: "^\\s*(///|/\\*\\*)")
let structClassRegex = try! NSRegularExpression(pattern: "^\\s*(?:public|internal|private|fileprivate|open)?\\s*(?:final\\s+)?(struct|class)\\s+(\\w+)\\b")
let funcRegex = try! NSRegularExpression(pattern: "^\\s*(?:public|internal|private|fileprivate|open)?\\s*(?:mutating\\s+)?(?:static\\s+)?func\\s+(\\w+)\\s*\\(([^)]*)\\)\\s*(?:->\\s*([^\\{\\n]+))?")

struct Modification {
    let file: URL
    var addedLines: Int
    var preview: String
}

func hasDocCommentAbove(lines: [String], index: Int) -> Bool {
    var j = index - 1
    while j >= 0 {
        let line = lines[j]
        if line.trimmingCharacters(in: .whitespaces).isEmpty { j -= 1; continue }
        let range = NSRange(location: 0, length: line.utf16.count)
        return swiftCommentDocRegex.firstMatch(in: line, options: [], range: range) != nil
    }
    return false
}

func parseParams(_ params: String) -> [(String, String?)] {
    if params.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty { return [] }
    return params.split(separator: ",").map { part in
        let seg = part.trimmingCharacters(in: .whitespaces)
        let comps = seg.split(separator: ":", maxSplits: 1).map { String($0).trimmingCharacters(in: .whitespaces) }
        if comps.count == 2 { return (comps[0], comps[1]) } else { return (comps[0], nil) }
    }
}

func buildTypeDoc(kind: String, name: String) -> [String] {
    ["/// Type: \(kind) \(name)",
     "/// Purpose: Auto-generated documentation for \(name).",
     ""]
}

func buildFuncDoc(name: String, params: [(String, String?)], returns: String?) -> [String] {
    var lines: [String] = ["/// Summary: Auto-generated documentation for \(name)()"]
    if !params.isEmpty {
        lines.append("/// - Parameters:")
        for (pname, ptype) in params {
            if let t = ptype { lines.append("///   - \(pname): \(t) parameter.") }
            else { lines.append("///   - \(pname): Parameter.") }
        }
    }
    if let r = returns { lines.append("/// - Returns: \(r) value.") }
    lines.append("")
    return lines
}

func addInlineComments(lines: inout [String]) {
    for i in 0..<lines.count {
        let line = lines[i]
        if line.contains("guard ") || line.contains(" if ") || line.trimmingCharacters(in: .whitespaces).hasPrefix("if ") {
            if !line.contains("//") && line.count > 60 {
                lines.insert("// Explain complex branch: auto-generated inline comment.", at: i)
            }
        }
    }
}

func processFile(_ url: URL) -> Modification? {
    guard let data = try? Data(contentsOf: url), var text = String(data: data, encoding: .utf8) else { return nil }
    var lines = text.components(separatedBy: "\n")
    var added = 0
    var previewDiff = ""

    for idx in 0..<lines.count {
        let line = lines[idx]
        let nsLine = line as NSString
        let range = NSRange(location: 0, length: nsLine.length)

        if structClassRegex.firstMatch(in: line, options: [], range: range) != nil {
            if !hasDocCommentAbove(lines: lines, index: idx) {
                let match = structClassRegex.firstMatch(in: line, options: [], range: range)!
                let kind = nsLine.substring(with: match.range(at: 1))
                let name = nsLine.substring(with: match.range(at: 2))
                let doc = buildTypeDoc(kind: kind, name: name)
                lines.insert(contentsOf: doc, at: idx)
                added += doc.count
                previewDiff += "\nFILE: \(url.path)\nAdded type doc above line \(idx+1): \(kind) \(name)\n"
            }
            continue
        }

        if funcRegex.firstMatch(in: line, options: [], range: range) != nil {
            if !hasDocCommentAbove(lines: lines, index: idx) {
                let match = funcRegex.firstMatch(in: line, options: [], range: range)!
                let fname = nsLine.substring(with: match.range(at: 1))
                let params = match.range(at: 2).location != NSNotFound ? nsLine.substring(with: match.range(at: 2)) : ""
                let returns = match.range(at: 3).location != NSNotFound ? nsLine.substring(with: match.range(at: 3)).trimmingCharacters(in: .whitespaces) : nil
                let doc = buildFuncDoc(name: fname, params: parseParams(params), returns: returns)
                lines.insert(contentsOf: doc, at: idx)
                added += doc.count
                previewDiff += "\nFILE: \(url.path)\nAdded func doc above line \(idx+1): \(fname)\n"
            }
            continue
        }
    }

    addInlineComments(lines: &lines)

    if added == 0 { return nil }

    let newText = lines.joined(separator: "\n")
    if opts.dryRun {
        return Modification(file: url, addedLines: added, preview: previewDiff)
    } else {
        let backupURL = url.deletingPathExtension().appendingPathExtension("swift.bak")
        try? data.write(to: backupURL)
        try? newText.data(using: .utf8)?.write(to: url)
        return Modification(file: url, addedLines: added, preview: previewDiff)
    }
}

func collectSwiftFiles(in root: URL) -> [URL] {
    var results: [URL] = []
    let fm = FileManager.default
    let enumerator = fm.enumerator(at: root, includingPropertiesForKeys: nil, options: [.skipsHiddenFiles])
    while let item = enumerator?.nextObject() as? URL {
        if item.pathExtension == "swift" { results.append(item) }
    }
    return results
}

let files = collectSwiftFiles(in: opts.root)
var modifications: [Modification] = []
for f in files { if let m = processFile(f) { modifications.append(m) } }

var report = "CommentInjector Report\nRoot: \(opts.root.path)\nDryRun: \(opts.dryRun)\nModified files: \(modifications.count)\n"
for m in modifications { report += "- \(m.file.path) (+\(m.addedLines) lines)\n"; report += m.preview + "\n" }

print(report)
if let rp = opts.reportPath { try? report.data(using: .utf8)?.write(to: rp) }
