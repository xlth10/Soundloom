import SwiftUI

@available(iOS 16.0, *)
struct SoundloomHomeView: View {
    @ObservedObject var inbox: RecordingInbox
    @ObservedObject var aiSettings: AIConfigurationStore
    @State private var selectedMode: SoundloomRecordingMode = .quickCapture
    @State private var showingSettings = false

    /// The host app owns the actual foreground recording session.
    let startRecording: (SoundloomRecordingMode) -> Void

    var body: some View {
        NavigationStack {
            List {
                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Soundloom")
                            .font(.largeTitle.bold())
                            .tracking(-0.6)
                        Text("把声音织成脉络。")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 8)
                    .accessibilityElement(children: .combine)
                }
                .listRowBackground(Color.clear)

                Section("这次想记录什么？") {
                    ForEach(SoundloomRecordingMode.allCases) { mode in
                        Button {
                            selectedMode = mode
                        } label: {
                            ModeRow(mode: mode, isSelected: selectedMode == mode)
                        }
                        .buttonStyle(.plain)
                        .accessibilityAddTraits(selectedMode == mode ? .isSelected : [])
                    }
                }

                Section {
                    Button {
                        startRecording(selectedMode)
                    } label: {
                        Label("开始记录", systemImage: "mic.fill")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 7)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.indigo)
                    .accessibilityHint(selectedMode == .quickCapture ? "开始一段灵感闪记" : "开始一段深度现场记录")
                }
                .listRowBackground(Color.clear)

                Section("最近记录") {
                    if inbox.items.isEmpty {
                        if #available(iOS 17.0, *) {
                            ContentUnavailableView(
                                "还没有记录",
                                systemImage: "waveform",
                                description: Text("从一条灵感或一段现场开始。")
                            )
                        } else {
                            VStack(spacing: 8) {
                                Image(systemName: "waveform")
                                    .font(.title2)
                                Text("还没有记录")
                                    .font(.headline)
                                Text("从一条灵感或一段现场开始。")
                                    .font(.subheadline)
                                    .multilineTextAlignment(.center)
                            }
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 24)
                        }
                    } else {
                        ForEach(inbox.items) { item in
                            NavigationLink {
                                SoundloomRecordDetailView(item: item, inbox: inbox, aiSettings: aiSettings)
                            } label: {
                                RecordingRow(item: item)
                            }
                        }
                    }
                }
            }
            .listStyle(.insetGrouped)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingSettings = true
                    } label: {
                        Image(systemName: "slider.horizontal.3")
                    }
                    .accessibilityLabel("AI 与整理")
                }
            }
            .sheet(isPresented: $showingSettings) {
                SoundloomAISettingsView(store: aiSettings)
            }
        }
    }
}

@available(iOS 16.0, *)
private struct ModeRow: View {
    let mode: SoundloomRecordingMode
    let isSelected: Bool

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: mode.systemImage)
                .font(.title3)
                .foregroundStyle(isSelected ? .indigo : .secondary)
                .frame(width: 28)
            VStack(alignment: .leading, spacing: 4) {
                Text(mode.title).font(.headline)
                Text(mode.subtitle).font(.subheadline).foregroundStyle(.secondary)
            }
            Spacer(minLength: 8)
            Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                .foregroundStyle(isSelected ? AnyShapeStyle(Color.indigo) : AnyShapeStyle(.tertiary))
        }
        .padding(.vertical, 5)
    }
}

@available(iOS 16.0, *)
private struct RecordingRow: View {
    let item: RecordingInboxItem

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: item.mode.systemImage)
                .foregroundStyle(item.mode == .deepField ? .indigo : .orange)
                .frame(width: 24)
            VStack(alignment: .leading, spacing: 3) {
                Text(item.mode.title).font(.headline)
                Text("\(item.source.title) · \(item.processingStatus.title)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            if let seconds = item.durationSeconds {
                Text(Duration.seconds(seconds).formatted(.time(pattern: .minuteSecond)))
                    .font(.caption.monospacedDigit())
                    .foregroundStyle(.secondary)
            }
        }
    }
}

@available(iOS 16.0, *)
struct SoundloomRecordDetailView: View {
    @State private var item: RecordingInboxItem
    @ObservedObject var inbox: RecordingInbox
    @ObservedObject var aiSettings: AIConfigurationStore
    @State private var errorMessage: String?

    init(item: RecordingInboxItem, inbox: RecordingInbox, aiSettings: AIConfigurationStore) {
        _item = State(initialValue: item)
        self.inbox = inbox
        self.aiSettings = aiSettings
    }

    var body: some View {
        List {
            Section {
                Label(item.mode.title, systemImage: item.mode.systemImage)
                    .font(.title3.weight(.semibold))
                Text(item.mode == .deepField ? "让这段现场保留可追溯的脉络。" : "把这一刻留成一条清晰闪念。")
                    .foregroundStyle(.secondary)
                Label(item.processingStatus.title, systemImage: statusIcon)
                    .font(.subheadline)
                    .foregroundStyle(statusColor)
            }

            if item.mode == .deepField {
                DeepFieldOutlineSection(outline: item.outline)
            } else {
                InspirationSummarySection(transcript: item.transcript)
            }

            Section("完整转写") {
                Text(item.transcript ?? "原始记录已保存。配置 AI 后，Soundloom 可以继续为你整理这段声音。")
                    .foregroundStyle(item.transcript == nil ? .secondary : .primary)
                if item.transcript == nil {
                    Button("开始转写") {
                        transcribe()
                    }
                }
            }

            Section {
                if aiSettings.hasAPIKey(for: aiSettings.activeProvider) {
                    Button("用 \(aiSettings.activeProvider.title) 整理") {
                        organize()
                    }
                } else {
                    NavigationLink("配置 AI，让 Soundloom 帮你整理这段记录") {
                        SoundloomAISettingsView(store: aiSettings)
                    }
                }
            }
        }
        .navigationTitle("这段现场")
        .navigationBarTitleDisplayMode(.inline)
        .alert("暂时无法整理", isPresented: Binding(
            get: { errorMessage != nil },
            set: { if !$0 { errorMessage = nil } }
        )) {
            Button("好") { errorMessage = nil }
        } message: {
            Text(errorMessage ?? "")
        }
    }

    private var statusIcon: String {
        switch item.processingStatus {
        case .ready: "checkmark.circle.fill"
        case .failed: "exclamationmark.triangle.fill"
        case .processingAI, .transcribing: "circle.dotted"
        default: "archivebox.fill"
        }
    }

    private var statusColor: Color {
        switch item.processingStatus {
        case .ready: .green
        case .failed: .red
        case .processingAI, .transcribing: .indigo
        default: .secondary
        }
    }

    private func save() {
        try? inbox.update(item)
    }

    private func transcribe() {
        item.processingStatus = .transcribing
        save()
        let recordingURL = inbox.fileURL(for: item)
        Task {
            do {
                let text = try await SpeechTranscriptionService().transcribe(fileURL: recordingURL)
                await MainActor.run {
                    item.transcript = text
                    item.processingStatus = .readyForAI
                    save()
                }
            } catch {
                await MainActor.run {
                    item.processingStatus = .failed
                    save()
                    errorMessage = error.localizedDescription
                }
            }
        }
    }

    private func organize() {
        guard let transcript = item.transcript, !transcript.isEmpty else {
            errorMessage = "请先完成转写，再使用 AI 整理。"
            return
        }
        item.processingStatus = .processingAI
        save()
        let configuration = aiSettings.activeConfiguration
        Task {
            do {
                let apiKey = try aiSettings.apiKey(for: configuration.provider)
                let outline = try await AIProcessingService().organize(
                    transcript: transcript,
                    mode: item.mode,
                    configuration: configuration,
                    apiKey: apiKey
                )
                await MainActor.run {
                    item.outline = outline
                    item.processingStatus = .ready
                    save()
                }
            } catch {
                await MainActor.run {
                    item.processingStatus = .failed
                    save()
                    errorMessage = error.localizedDescription
                }
            }
        }
    }
}

@available(iOS 16.0, *)
private struct InspirationSummarySection: View {
    let transcript: String?

    var body: some View {
        Section("闪念内容") {
            Text(transcript ?? "尚未整理。原始声音已安全保存。")
                .foregroundStyle(transcript == nil ? .secondary : .primary)
        }
    }
}

@available(iOS 16.0, *)
private struct DeepFieldOutlineSection: View {
    let outline: SoundloomOutline?

    var body: some View {
        Section("现场脉络") {
            if let outline {
                Text(outline.overview)
                if !outline.timeline.isEmpty {
                    NavigationLink("时间线（\(outline.timeline.count)）") {
                        List(outline.timeline) { entry in
                            VStack(alignment: .leading) {
                                Text(Duration.seconds(entry.offsetSeconds).formatted(.time(pattern: .minuteSecond)))
                                    .font(.caption.monospacedDigit())
                                    .foregroundStyle(.secondary)
                                Text(entry.title).font(.headline)
                                Text(entry.detail).foregroundStyle(.secondary)
                            }
                        }
                        .navigationTitle("时间线")
                    }
                }
                OutlineTags(title: "主题", values: outline.topics)
                OutlineTags(title: "参与者", values: outline.participants)
                OutlineTags(title: "待办", values: outline.todos)
            } else {
                Text("转写完成后，Soundloom 会在这里整理时间线、主题、参与者与待办。")
                    .foregroundStyle(.secondary)
            }
        }
    }
}

@available(iOS 16.0, *)
private struct OutlineTags: View {
    let title: String
    let values: [String]

    var body: some View {
        if !values.isEmpty {
            LabeledContent(title) {
                Text(values.joined(separator: "、"))
                    .multilineTextAlignment(.trailing)
            }
        }
    }
}

@available(iOS 16.0, *)
struct SoundloomAISettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var store: AIConfigurationStore

    var body: some View {
        NavigationStack {
            List {
                Section("当前整理模型") {
                    ForEach(SoundloomAIProvider.allCases) { provider in
                        Button {
                            store.setActiveProvider(provider)
                        } label: {
                            HStack {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(provider.title).foregroundStyle(.primary)
                                    Text(store.configuration(for: provider).modelID)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                Spacer()
                                if store.activeProvider == provider {
                                    Image(systemName: "checkmark")
                                        .foregroundStyle(.indigo)
                                }
                            }
                        }
                    }
                }

                Section("服务商配置") {
                    ForEach(SoundloomAIProvider.allCases) { provider in
                        NavigationLink(provider.title) {
                            AIProviderConfigurationView(store: store, provider: provider)
                        }
                    }
                }

                Section("隐私") {
                    Text("录音始终优先保存在本机；只有在你发起整理时，才会发送必要的转写文本。")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("AI 与整理")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完成") { dismiss() }
                }
            }
        }
    }
}

@available(iOS 16.0, *)
private struct AIProviderConfigurationView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var store: AIConfigurationStore
    let provider: SoundloomAIProvider

    @State private var modelID = ""
    @State private var baseURL = ""
    @State private var apiKey = ""
    @State private var isEnabled = true
    @State private var errorMessage: String?

    var body: some View {
        Form {
            Section {
                SecureField("API Key", text: $apiKey)
                TextField("默认模型", text: $modelID)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                DisclosureGroup("高级设置") {
                    TextField("Base URL", text: $baseURL)
                        .textInputAutocapitalization(.never)
                        .keyboardType(.URL)
                        .autocorrectionDisabled()
                }
                Toggle("用于整理记录", isOn: $isEnabled)
            } footer: {
                Text("密钥保存在此设备的 Keychain 中，不会写入录音或导出文件。")
            }

            if let errorMessage {
                Section { Text(errorMessage).foregroundStyle(.red) }
            }
        }
        .navigationTitle(provider.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("保存") { save() }
            }
        }
        .onAppear {
            let configuration = store.configuration(for: provider)
            modelID = configuration.modelID
            baseURL = configuration.baseURL
            isEnabled = configuration.isEnabled
        }
    }

    private func save() {
        let configuration = SoundloomAIConfiguration(
            provider: provider,
            modelID: modelID.trimmingCharacters(in: .whitespacesAndNewlines),
            baseURL: baseURL.trimmingCharacters(in: .whitespacesAndNewlines),
            isEnabled: isEnabled
        )
        do {
            try store.save(configuration, apiKey: apiKey)
            dismiss()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
