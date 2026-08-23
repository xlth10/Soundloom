import Foundation

enum RecordingEngineState: Equatable {
    case idle
    case recording
    case failed(String)
}

struct RecordingSession: Equatable {
    let startedAt: Date
    let mode: SoundloomRecordingMode
}

struct RecordedAudio: Equatable {
    let fileURL: URL
    let durationSeconds: Int
}

@MainActor
protocol RecordingEngine: AnyObject {
    var state: RecordingEngineState { get }

    func requestPermission() async -> Bool
    func start(mode: SoundloomRecordingMode) async throws -> RecordingSession
    func stop() async throws -> RecordedAudio
    func discard() async
}

enum RecordingEngineError: LocalizedError {
    case permissionDenied
    case alreadyRecording
    case notRecording
    case couldNotCreateRecorder
    case emptyRecording

    var errorDescription: String? {
        switch self {
        case .permissionDenied: "没有获得麦克风权限。请在系统设置中允许 Soundloom 使用麦克风。"
        case .alreadyRecording: "已经有一段录音正在进行。"
        case .notRecording: "当前没有正在进行的录音。"
        case .couldNotCreateRecorder: "无法创建录音器，请检查麦克风和录音目录。"
        case .emptyRecording: "录音文件为空或不可读，未保存这段记录。"
        }
    }
}
