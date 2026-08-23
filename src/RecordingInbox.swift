import Combine
import Foundation

struct RecordingInboxItem: Identifiable, Codable, Hashable, Sendable {
    let id: UUID
    let fileName: String
    let receivedAt: Date
    let durationSeconds: Int?
    var mode: SoundloomRecordingMode
    var source: SoundloomRecordingSource
    var processingStatus: SoundloomProcessingStatus
    var transcript: String?
    var inspiration: SoundloomInspiration?
    var outline: SoundloomOutline?

    init(
        id: UUID,
        fileName: String,
        receivedAt: Date,
        durationSeconds: Int?,
        mode: SoundloomRecordingMode = .quickCapture,
        source: SoundloomRecordingSource = .inAppSession,
        processingStatus: SoundloomProcessingStatus = .saved,
        transcript: String? = nil,
        inspiration: SoundloomInspiration? = nil,
        outline: SoundloomOutline? = nil
    ) {
        self.id = id
        self.fileName = fileName
        self.receivedAt = receivedAt
        self.durationSeconds = durationSeconds
        self.mode = mode
        self.source = source
        self.processingStatus = processingStatus
        self.transcript = transcript
        self.inspiration = inspiration
        self.outline = outline
    }

    private enum CodingKeys: String, CodingKey {
        case id, fileName, receivedAt, durationSeconds, mode, source, processingStatus, transcript, inspiration, outline
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decode(UUID.self, forKey: .id)
        fileName = try values.decode(String.self, forKey: .fileName)
        receivedAt = try values.decode(Date.self, forKey: .receivedAt)
        durationSeconds = try values.decodeIfPresent(Int.self, forKey: .durationSeconds)
        mode = try values.decodeIfPresent(SoundloomRecordingMode.self, forKey: .mode) ?? .quickCapture
        source = try values.decodeIfPresent(SoundloomRecordingSource.self, forKey: .source) ?? .inAppSession
        processingStatus = try values.decodeIfPresent(SoundloomProcessingStatus.self, forKey: .processingStatus) ?? .saved
        transcript = try values.decodeIfPresent(String.self, forKey: .transcript)
        inspiration = try values.decodeIfPresent(SoundloomInspiration.self, forKey: .inspiration)
        outline = try values.decodeIfPresent(SoundloomOutline.self, forKey: .outline)
    }
}

enum RecordingInboxError: LocalizedError, Equatable {
    case copyFailed(String)
    case indexWriteFailed(String)

    var errorDescription: String? {
        switch self {
        case .copyFailed(let message): return "无法保存录音：\(message)"
        case .indexWriteFailed(let message): return "无法更新录音索引：\(message)"
        }
    }
}

@MainActor
final class RecordingInbox: ObservableObject {
    @Published private(set) var items: [RecordingInboxItem] = []

    private let directory: URL
    private let indexURL: URL
    private let fileManager: FileManager

    init(fileManager: FileManager = .default, baseDirectory: URL? = nil) {
        self.fileManager = fileManager
        let defaultBase = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let base = baseDirectory ?? defaultBase
        directory = base.appendingPathComponent("Recordings", isDirectory: true)
        indexURL = directory.appendingPathComponent("index.json")
        try? self.fileManager.createDirectory(at: directory, withIntermediateDirectories: true)
        load()
    }

    @discardableResult
    func receive(fileURL: URL, metadata: [String: Any]?) throws -> RecordingInboxItem {
        guard fileManager.fileExists(atPath: fileURL.path),
              let attributes = try? fileManager.attributesOfItem(atPath: fileURL.path),
              (attributes[.size] as? NSNumber)?.intValue ?? 0 > 0 else {
            throw RecordingInboxError.copyFailed("源录音不存在或为空。")
        }
        let id = UUID()
        let destination = directory.appendingPathComponent("\(id.uuidString)-\(fileURL.lastPathComponent)")

        do {
            try fileManager.copyItem(at: fileURL, to: destination)
        } catch {
            throw RecordingInboxError.copyFailed(error.localizedDescription)
        }

        let duration = metadata?["durationSeconds"] as? Int
        let mode = SoundloomRecordingMode(rawValue: metadata?["mode"] as? String ?? "") ?? .quickCapture
        let source = SoundloomRecordingSource(rawValue: metadata?["source"] as? String ?? "") ?? .inAppSession
        let item = RecordingInboxItem(
            id: id,
            fileName: destination.lastPathComponent,
            receivedAt: Date(),
            durationSeconds: duration,
            mode: mode,
            source: source,
            processingStatus: .saved
        )
        items.insert(item, at: 0)
        do {
            try save()
        } catch {
            items.removeAll { $0.id == item.id }
            try? fileManager.removeItem(at: destination)
            throw RecordingInboxError.indexWriteFailed(error.localizedDescription)
        }

        try? fileManager.removeItem(at: fileURL)
        return item
    }

    func fileURL(for item: RecordingInboxItem) -> URL {
        directory.appendingPathComponent(item.fileName)
    }

    func update(_ item: RecordingInboxItem) throws {
        guard let index = items.firstIndex(where: { $0.id == item.id }) else { return }
        items[index] = item
        try save()
    }

    /// File copying and index persistence can be expensive for long recordings.
    /// Keep those operations off the main actor while preserving atomic index writes.
    @discardableResult
    func receiveInBackground(fileURL: URL, metadata: [String: Any]?) async throws -> RecordingInboxItem {
        let payload = ReceivePayload(
            durationSeconds: metadata?["durationSeconds"] as? Int,
            mode: SoundloomRecordingMode(rawValue: metadata?["mode"] as? String ?? "") ?? .quickCapture,
            source: SoundloomRecordingSource(rawValue: metadata?["source"] as? String ?? "") ?? .inAppSession
        )
        let directory = directory
        let indexURL = indexURL
        let existingItems = items
        let item = try await Task.detached(priority: .utility, operation: { @Sendable () throws -> BackgroundReceiveResult in
            let fileManager = FileManager.default
            guard fileManager.fileExists(atPath: fileURL.path),
                  let attributes = try? fileManager.attributesOfItem(atPath: fileURL.path),
                  (attributes[.size] as? NSNumber)?.intValue ?? 0 > 0 else {
                throw RecordingInboxError.copyFailed("源录音不存在或为空。")
            }

            let id = UUID()
            let destination = directory.appendingPathComponent("\(id.uuidString)-\(fileURL.lastPathComponent)")
            do {
                try fileManager.copyItem(at: fileURL, to: destination)
                let newItem = RecordingInboxItem(
                    id: id,
                    fileName: destination.lastPathComponent,
                    receivedAt: Date(),
                    durationSeconds: payload.durationSeconds,
                    mode: payload.mode,
                    source: payload.source,
                    processingStatus: .saved
                )
                let updatedItems = [newItem] + existingItems
                let data = try JSONEncoder().encode(updatedItems)
                do {
                    try data.write(to: indexURL, options: .atomic)
                } catch {
                    throw RecordingInboxError.indexWriteFailed(error.localizedDescription)
                }
                try? fileManager.removeItem(at: fileURL)
                return BackgroundReceiveResult(item: newItem, items: updatedItems)
            } catch let error as RecordingInboxError {
                throw error
            } catch {
                try? fileManager.removeItem(at: destination)
                throw RecordingInboxError.copyFailed(error.localizedDescription)
            }
        }).value
        items = item.items
        return item.item
    }

    func updateInBackground(_ item: RecordingInboxItem) async throws {
        guard let index = items.firstIndex(where: { $0.id == item.id }) else { return }
        var updatedItems = items
        updatedItems[index] = item
        let snapshot = updatedItems
        let indexURL = indexURL
        try await Task.detached(priority: .utility, operation: { @Sendable in
            let data = try JSONEncoder().encode(snapshot)
            try data.write(to: indexURL, options: .atomic)
        }).value
        items = snapshot
    }

    private func load() {
        guard let data = try? Data(contentsOf: indexURL),
              let decoded = try? JSONDecoder().decode([RecordingInboxItem].self, from: data) else { return }
        items = decoded
    }

    private func save() throws {
        let data = try JSONEncoder().encode(items)
        try data.write(to: indexURL, options: .atomic)
    }
}

private struct ReceivePayload: Sendable {
    let durationSeconds: Int?
    let mode: SoundloomRecordingMode
    let source: SoundloomRecordingSource
}

private struct BackgroundReceiveResult: Sendable {
    let item: RecordingInboxItem
    let items: [RecordingInboxItem]
}
