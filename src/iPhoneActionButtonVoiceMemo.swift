import AVFAudio
import AppIntents
import Combine
import Foundation
import OSLog
import Speech

@MainActor
final class VoiceMemoCoordinator: NSObject, AVAudioRecorderDelegate, ObservableObject {
    static let shared = VoiceMemoCoordinator()

    private(set) var recorder: AVAudioRecorder?
    private(set) var startedAt: Date?
    @Published private(set) var isRecording = false
    @Published private(set) var activeMode: SoundloomRecordingMode = .quickCapture
    private let fileManager = FileManager.default
    private let cardStore = InspirationCardStore()
    private let logger = Logger(subsystem: "DoubleTapMemo", category: "VoiceCueShortcut")
    private var nextInvocationID = 0

    private override init() {
        super.init()
    }

    func toggle() async -> String {
        nextInvocationID += 1
        let invocationID = nextInvocationID
        logger.info("toggle requested invocation=\(invocationID, privacy: .public) recorderPresent=\(self.recorder != nil, privacy: .public)")

        if recorder != nil {
            let message = stop()
            logger.info("toggle completed invocation=\(invocationID, privacy: .public) action=stop")
            return message
        }
        activeMode = .quickCapture
        let message = await start(invocationID: invocationID)
        logger.info("toggle completed invocation=\(invocationID, privacy: .public) action=start")
        return message
    }

    /// App-owned recording is deliberately separate from the system-owned Shortcut recording flow.
    func startInAppSession(mode: SoundloomRecordingMode) async -> String {
        guard recorder == nil else { return "正在记录中" }
        activeMode = mode
        nextInvocationID += 1
        let message = await start(invocationID: nextInvocationID)
        return message
    }

    func stopInAppSession() -> String {
        stop()
    }

    private func start(invocationID: Int) async -> String {
        do {
            let session = AVAudioSession.sharedInstance()
            guard Self.hasRecordPermission else {
                logger.error("permission denied invocation=\(invocationID, privacy: .public)")
                return "请先打开 VoiceCue 并允许麦克风权限"
            }

            try session.setCategory(.playAndRecord, mode: .spokenAudio, options: [.allowBluetoothHFP, .defaultToSpeaker])
            logSession(session, invocationID: invocationID, phase: "before-activation")
            try await activate(session, invocationID: invocationID)

            let directory = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
                .appendingPathComponent("VoiceMemos", isDirectory: true)
            try fileManager.createDirectory(at: directory, withIntermediateDirectories: true)
            let url = directory.appendingPathComponent("memo-\(Int(Date().timeIntervalSince1970)).m4a")
            let settings: [String: Any] = [
                AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                AVSampleRateKey: 44_100,
                AVNumberOfChannelsKey: 1,
                AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
            ]

            let recorder = try AVAudioRecorder(url: url, settings: settings)
            recorder.delegate = self
            guard recorder.record() else {
                try? session.setActive(false)
                return "无法开始录音"
            }
            self.recorder = recorder
            startedAt = .now
            isRecording = true
            return activeMode == .deepField ? "已开始深度现场记录" : "已开始灵感闪记"
        } catch {
            let nsError = error as NSError
            logger.error("audio start failed invocation=\(invocationID, privacy: .public) domain=\(nsError.domain, privacy: .public) code=\(nsError.code, privacy: .public) message=\(nsError.localizedDescription, privacy: .public)")
            try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
            if nsError.domain == NSOSStatusErrorDomain {
                return "无法开始录音：麦克风正被通话、Siri 或其他音频占用，请稍后再试"
            }
            return "开始录音失败：\(error.localizedDescription)"
        }
    }

    private func activate(_ session: AVAudioSession, invocationID: Int) async throws {
        do {
            try session.setActive(true)
            logger.info("audio session activated invocation=\(invocationID, privacy: .public) attempt=1")
        } catch {
            logActivationFailure(error, session: session, invocationID: invocationID, attempt: 1)
            try await Task.sleep(nanoseconds: 250_000_000)
            logSession(session, invocationID: invocationID, phase: "before-retry")
            do {
                try session.setActive(true)
                logger.info("audio session activated invocation=\(invocationID, privacy: .public) attempt=2")
            } catch {
                logActivationFailure(error, session: session, invocationID: invocationID, attempt: 2)
                throw error
            }
        }
    }

    private func logSession(_ session: AVAudioSession, invocationID: Int, phase: String) {
        let inputs = session.currentRoute.inputs.map { $0.portType.rawValue }.joined(separator: ",")
        let outputs = session.currentRoute.outputs.map { $0.portType.rawValue }.joined(separator: ",")
        logger.info("audio session snapshot invocation=\(invocationID, privacy: .public) phase=\(phase, privacy: .public) category=\(session.category.rawValue, privacy: .public) mode=\(session.mode.rawValue, privacy: .public) otherAudio=\(session.isOtherAudioPlaying, privacy: .public) silencedHint=\(session.secondaryAudioShouldBeSilencedHint, privacy: .public) inputs=\(inputs, privacy: .public) outputs=\(outputs, privacy: .public)")
    }

    private func logActivationFailure(_ error: Error, session: AVAudioSession, invocationID: Int, attempt: Int) {
        let nsError = error as NSError
        logger.error("audio start failed invocation=\(invocationID, privacy: .public) attempt=\(attempt, privacy: .public) domain=\(nsError.domain, privacy: .public) code=\(nsError.code, privacy: .public) message=\(nsError.localizedDescription, privacy: .public)")
        logSession(session, invocationID: invocationID, phase: "activation-failed")
    }

    private static var hasRecordPermission: Bool {
        if #available(iOS 17.0, *) {
            return AVAudioApplication.shared.recordPermission == .granted
        }
        return AVAudioSession.sharedInstance().recordPermission == .granted
    }

    private func stop() -> String {
        guard let recorder, let startedAt else {
            self.recorder = nil
            return "当前没有正在进行的录音"
        }

        let audioURL = recorder.url
        recorder.stop()
        self.recorder = nil
        self.startedAt = nil
        isRecording = false
        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)

        do {
            let cardURL = try cardStore.save(for: audioURL, startedAt: startedAt, stoppedAt: .now, mode: activeMode)
            return activeMode == .deepField
                ? "已停止录音，现场记录已保存：\(cardURL.lastPathComponent)"
                : "已停止录音，灵感闪记已保存：\(cardURL.lastPathComponent)"
        } catch {
            return "录音已保存，但灵感卡生成失败：\(error.localizedDescription)"
        }
    }

    nonisolated func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Error?) {
        Task { @MainActor [weak self] in
            self?.recorder = nil
            self?.startedAt = nil
            self?.isRecording = false
        }
    }
}

@available(iOS 16.0, *)
struct ToggleVoiceMemoIntent: AppIntent {
    static let title: LocalizedStringResource = "切换语音闪记"
    static let description = IntentDescription("第一次按下开始录音，再次按下停止录音并生成灵感卡。")
    static var openAppWhenRun = false

    func perform() async throws -> some IntentResult & ProvidesDialog {
        if !SpeechRecognitionAuthorization.isAuthorized {
            let authorized = await SpeechRecognitionAuthorization.request()
            guard authorized else {
                return .result(dialog: "请允许 VoiceCue 使用语音识别，然后再次按下操作按钮")
            }
        }

        let message = await VoiceMemoCoordinator.shared.toggle()
        return .result(dialog: IntentDialog(stringLiteral: message))
    }
}

@available(iOS 16.0, *)
struct VoiceMemoShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: ToggleVoiceMemoIntent(),
            phrases: [
                "用 \(.applicationName) 切换语音闪记",
                "用 \(.applicationName) 开始或停止语音闪记"
            ],
            shortTitle: "切换语音闪记",
            systemImageName: "mic.badge.plus"
        )
    }
}
