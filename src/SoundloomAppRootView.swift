import SwiftUI

/// Add this view to the existing iPhone App scene. It intentionally does not create another `@main App`.
@available(iOS 16.0, *)
struct SoundloomAppRootView: View {
    @StateObject private var inbox = RecordingInbox()
    @StateObject private var aiSettings = AIConfigurationStore()
    @ObservedObject private var recorder = VoiceMemoCoordinator.shared
    @State private var sessionMessage: String?

    var body: some View {
        Group {
            if recorder.isRecording, let startedAt = recorder.startedAt {
                SoundloomRecordingSessionView(
                    mode: recorder.activeMode,
                    startedAt: startedAt,
                    stop: stopRecording
                )
            } else {
                SoundloomHomeView(inbox: inbox, aiSettings: aiSettings) { mode in
                    Task { @MainActor in
                        sessionMessage = await recorder.startInAppSession(mode: mode)
                    }
                }
            }
        }
        .alert("Soundloom", isPresented: Binding(
            get: { sessionMessage != nil && !recorder.isRecording },
            set: { if !$0 { sessionMessage = nil } }
        )) {
            Button("好") { sessionMessage = nil }
        } message: {
            Text(sessionMessage ?? "")
        }
    }

    private func stopRecording() {
        sessionMessage = recorder.stopInAppSession()
    }
}

@available(iOS 16.0, *)
private struct SoundloomRecordingSessionView: View {
    let mode: SoundloomRecordingMode
    let startedAt: Date
    let stop: () -> Void

    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            Image(systemName: "waveform")
                .font(.system(size: 50, weight: .medium))
                .foregroundStyle(.indigo)
                .accessibilityHidden(true)
            Text(mode == .deepField ? "正在织入现场" : "正在织入灵感")
                .font(.title2.bold())
            TimelineView(.periodic(from: .now, by: 1)) { context in
                Text(Duration.seconds(max(0, Int(context.date.timeIntervalSince(startedAt)))).formatted(.time(pattern: .minuteSecond)))
                    .font(.system(size: 42, weight: .medium, design: .rounded).monospacedDigit())
                    .accessibilityLabel("已记录 \(max(0, Int(context.date.timeIntervalSince(startedAt)))) 秒")
            }
            Text(mode == .deepField ? "结束后会整理时间线、主题、参与者与待办。" : "结束后会保存原始声音，并整理成一条闪念。")
                .font(.subheadline)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
                .padding(.horizontal, 32)
            Spacer()
            Button(role: .destructive, action: stop) {
                Label("停止并保存", systemImage: "stop.fill")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
            }
            .buttonStyle(.borderedProminent)
            .tint(.red)
            .padding()
        }
        .navigationBarBackButtonHidden()
        .background(Color(.systemBackground))
    }
}
