import Foundation

/// A local, deterministic first-pass organizer. It keeps the app useful even
/// when no cloud AI key is configured and never transmits transcript text.
struct LocalRecordingOrganizer {
    func inspiration(from transcript: String) -> SoundloomInspiration {
        let sentences = splitSentences(transcript)
        let titleSource = sentences.first ?? transcript
        let title = String(titleSource.prefix(26)).trimmingCharacters(in: .whitespacesAndNewlines)
        let summary = String(sentences.prefix(3).joined(separator: " ").prefix(240))
        return SoundloomInspiration(
            title: title.isEmpty ? "未命名灵感" : title,
            summary: summary.isEmpty ? "这段录音尚未识别出可整理的文字。" : summary,
            keywords: keywords(in: transcript, limit: 5)
        )
    }

    func outline(from transcript: String) -> SoundloomOutline {
        let sentences = splitSentences(transcript)
        let timeline = sentences.prefix(8).enumerated().map { offset, sentence in
            SoundloomTimelineItem(
                offsetSeconds: offset * 20,
                title: String(sentence.prefix(32)),
                detail: sentence
            )
        }
        let todoCandidates: [String] = sentences.filter { sentence in
            let normalized = sentence.lowercased()
            return normalized.contains("待办") || normalized.contains("需要") || normalized.contains("todo") || normalized.contains("下一步")
        }
        let todos = Array(todoCandidates.prefix(5))
        return SoundloomOutline(
            overview: String(sentences.prefix(3).joined(separator: " ").prefix(300)),
            timeline: timeline,
            topics: keywords(in: transcript, limit: 6),
            participants: [],
            todos: todos
        )
    }

    private func splitSentences(_ text: String) -> [String] {
        text
            .components(separatedBy: CharacterSet(charactersIn: "。！？!?\n"))
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
    }

    private func keywords(in text: String, limit: Int) -> [String] {
        let words = text
            .components(separatedBy: CharacterSet.alphanumerics.inverted)
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { $0.count >= 2 && $0.count <= 18 }
        var counts: [String: Int] = [:]
        for word in words where !Self.stopWords.contains(word.lowercased()) {
            counts[word, default: 0] += 1
        }
        return counts
            .sorted { lhs, rhs in lhs.value == rhs.value ? lhs.key < rhs.key : lhs.value > rhs.value }
            .prefix(limit)
            .map(\.key)
    }

    private static let stopWords: Set<String> = ["这个", "那个", "然后", "我们", "你们", "因为", "所以", "就是", "可以", "一个", "一下"]
}
