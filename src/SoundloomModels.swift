import Foundation

enum SoundloomRecordingMode: String, CaseIterable, Codable, Identifiable, Sendable {
    case quickCapture
    case deepField

    var id: String { rawValue }

    var title: String {
        switch self {
        case .quickCapture: "灵感闪记"
        case .deepField: "深度现场"
        }
    }

    var subtitle: String {
        switch self {
        case .quickCapture: "想到就说，自动整理成一条清晰闪念。"
        case .deepField: "适合访谈、会议与持续事件，自动分段并提炼主题。"
        }
    }

    var systemImage: String {
        switch self {
        case .quickCapture: "sparkles"
        case .deepField: "waveform.path.ecg"
        }
    }
}

enum SoundloomRecordingSource: String, Codable, Sendable {
    case quickCaptureShortcut
    case inAppSession

    var title: String {
        switch self {
        case .quickCaptureShortcut: "快捷指令"
        case .inAppSession: "Soundloom"
        }
    }
}

enum SoundloomProcessingStatus: String, Codable, Equatable, Sendable {
    case saved
    case transcribing
    case readyForAI
    case processingAI
    case ready
    case failed

    var title: String {
        switch self {
        case .saved: "已保存"
        case .transcribing: "正在转写"
        case .readyForAI: "等待整理"
        case .processingAI: "正在整理"
        case .ready: "已整理"
        case .failed: "可重试"
        }
    }
}

enum SoundloomAIProvider: String, CaseIterable, Codable, Identifiable {
    case deepSeek
    case qwen
    case kimi
    case openAI
    case anthropic
    case gemini
    case openRouter

    var id: String { rawValue }

    var title: String {
        switch self {
        case .deepSeek: "DeepSeek"
        case .qwen: "通义千问"
        case .kimi: "Kimi"
        case .openAI: "OpenAI"
        case .anthropic: "Claude"
        case .gemini: "Gemini"
        case .openRouter: "OpenRouter"
        }
    }

    var defaultBaseURL: String {
        switch self {
        case .deepSeek: "https://api.deepseek.com"
        case .qwen: "https://dashscope.aliyuncs.com/compatible-mode/v1"
        case .kimi: "https://api.moonshot.cn/v1"
        case .openAI: "https://api.openai.com/v1"
        case .anthropic: "https://api.anthropic.com"
        case .gemini: "https://generativelanguage.googleapis.com/v1beta"
        case .openRouter: "https://openrouter.ai/api/v1"
        }
    }

    /// A user-editable default avoids hard-coding a provider's rapidly changing model catalogue.
    var suggestedModelID: String {
        switch self {
        case .deepSeek: "deepseek-chat"
        case .qwen: "qwen-plus"
        case .kimi: "moonshot-v1-8k"
        case .openAI: "gpt-4.1-mini"
        case .anthropic: "claude-sonnet"
        case .gemini: "gemini-2.5-flash"
        case .openRouter: "openrouter/auto"
        }
    }
}

struct SoundloomAIConfiguration: Codable, Equatable, Identifiable {
    let provider: SoundloomAIProvider
    var modelID: String
    var baseURL: String
    var isEnabled: Bool

    var id: SoundloomAIProvider { provider }

    init(provider: SoundloomAIProvider, modelID: String? = nil, baseURL: String? = nil, isEnabled: Bool = false) {
        self.provider = provider
        self.modelID = modelID ?? provider.suggestedModelID
        self.baseURL = baseURL ?? provider.defaultBaseURL
        self.isEnabled = isEnabled
    }
}

struct SoundloomInspiration: Codable, Equatable, Hashable, Sendable {
    var title: String
    var summary: String
    var keywords: [String]
}

struct SoundloomOutline: Codable, Equatable, Hashable, Sendable {
    var overview: String
    var timeline: [SoundloomTimelineItem]
    var topics: [String]
    var participants: [String]
    var todos: [String]
}

struct SoundloomTimelineItem: Codable, Equatable, Hashable, Identifiable, Sendable {
    let id: UUID
    var offsetSeconds: Int
    var title: String
    var detail: String

    init(id: UUID = UUID(), offsetSeconds: Int, title: String, detail: String) {
        self.id = id
        self.offsetSeconds = offsetSeconds
        self.title = title
        self.detail = detail
    }
}
