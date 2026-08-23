import Foundation

struct InspirationCard {
    let id: UUID
    let createdAt: Date
    let audioFileName: String
    let durationSeconds: Int
    let mode: SoundloomRecordingMode

    var markdown: String {
        let timestamp = ISO8601DateFormatter().string(from: createdAt)
        let title = "\(mode.title) · \(Self.titleFormatter.string(from: createdAt))"
        return """
        ---
        id: \(id.uuidString)
        created_at: \(timestamp)
        status: recorded
        mode: \(mode.rawValue)
        audio: \(audioFileName)
        duration_seconds: \(durationSeconds)
        ---

        # \(title)

        ## 原始录音

        [播放录音](\(audioFileName))

        ## 记录内容

        > 原始录音已保存。转写与 AI 整理可在后续处理步骤中补充。
        """
    }

    private static let titleFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "zh_CN")
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        return formatter
    }()
}

enum InspirationCardStoreError: LocalizedError {
    case cannotCreateDirectory
    case cannotWriteCard(String)

    var errorDescription: String? {
        switch self {
        case .cannotCreateDirectory:
            return "无法创建灵感卡目录"
        case .cannotWriteCard(let message):
            return "无法写入灵感卡：\(message)"
        }
    }
}

struct InspirationCardStore {
    private let fileManager: FileManager
    private let cardsDirectory: URL

    init(fileManager: FileManager = .default) {
        self.fileManager = fileManager
        let applicationSupport = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        self.cardsDirectory = applicationSupport.appendingPathComponent("InspirationCards", isDirectory: true)
    }

    @discardableResult
    func save(
        for audioURL: URL,
        startedAt: Date,
        stoppedAt: Date,
        mode: SoundloomRecordingMode = .quickCapture
    ) throws -> URL {
        do {
            try fileManager.createDirectory(at: cardsDirectory, withIntermediateDirectories: true)
        } catch {
            throw InspirationCardStoreError.cannotCreateDirectory
        }

        let card = InspirationCard(
            id: UUID(),
            createdAt: stoppedAt,
            audioFileName: audioURL.lastPathComponent,
            durationSeconds: max(0, Int(stoppedAt.timeIntervalSince(startedAt))),
            mode: mode
        )
        let cardURL = cardsDirectory.appendingPathComponent("\(card.id.uuidString).md")

        do {
            try card.markdown.write(to: cardURL, atomically: true, encoding: .utf8)
            return cardURL
        } catch {
            throw InspirationCardStoreError.cannotWriteCard(error.localizedDescription)
        }
    }
}
