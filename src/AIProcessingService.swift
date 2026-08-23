import Foundation

@available(iOS 16.0, *)
enum AIProcessingError: LocalizedError {
    case unsupportedProvider(SoundloomAIProvider)
    case invalidEndpoint
    case badResponse
    case providerError(String)
    case invalidOutline

    var errorDescription: String? {
        switch self {
        case .unsupportedProvider(let provider): return "\(provider.title) 的请求格式暂未接入；配置仍会安全保留。"
        case .invalidEndpoint: return "AI 服务地址无效。"
        case .badResponse: return "AI 服务没有返回可读取的结果。"
        case .providerError(let message): return "AI 服务返回错误：\(message)"
        case .invalidOutline: return "AI 返回的内容无法整理成记录脉络。"
        }
    }
}

@available(iOS 16.0, *)
struct AIProcessingService {
    func organize(
        transcript: String,
        mode: SoundloomRecordingMode,
        configuration: SoundloomAIConfiguration,
        apiKey: String
    ) async throws -> SoundloomOutline {
        guard configuration.provider.usesOpenAICompatibleAPI else {
            throw AIProcessingError.unsupportedProvider(configuration.provider)
        }
        guard let baseURL = URL(string: configuration.baseURL) else { throw AIProcessingError.invalidEndpoint }
        let endpoint = baseURL.appendingPathComponent("chat/completions")

        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.timeoutInterval = 60
        request.httpBody = try JSONEncoder().encode(OpenAICompatibleRequest(
            model: configuration.modelID,
            messages: [
                .init(role: "system", content: systemPrompt(for: mode)),
                .init(role: "user", content: transcript)
            ],
            responseFormat: .init(type: "json_object")
        ))

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse else { throw AIProcessingError.badResponse }
        guard (200...299).contains(http.statusCode) else {
            let message = String(data: data, encoding: .utf8) ?? "HTTP \(http.statusCode)"
            throw AIProcessingError.providerError(message)
        }
        let completion = try JSONDecoder().decode(OpenAICompatibleResponse.self, from: data)
        guard let content = completion.choices.first?.message.content else { throw AIProcessingError.badResponse }
        return try decodeOutline(from: content)
    }

    private func systemPrompt(for mode: SoundloomRecordingMode) -> String {
        let modeInstruction = mode == .deepField
            ? "这是一段多主题、多人或持续发生的现场记录。"
            : "这是一条单一想法或临时提醒。"
        return """
        你是 Soundloom 的记录整理助手。\(modeInstruction)
        只能返回 JSON 对象，不要 Markdown，不要解释。JSON 必须符合：
        {
          "overview": "两到三句中文概览",
          "timeline": [{"offsetSeconds": 0, "title": "简短标题", "detail": "对应内容"}],
          "topics": ["主题"],
          "participants": ["参与者或角色"],
          "todos": ["待办"]
        }
        不要编造转写中没有出现的事实。没有信息的数组返回空数组。
        """
    }

    private func decodeOutline(from content: String) throws -> SoundloomOutline {
        let cleaned = content
            .replacingOccurrences(of: "```json", with: "")
            .replacingOccurrences(of: "```", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        struct RawOutline: Decodable {
            let overview: String
            let timeline: [RawTimeline]
            let topics: [String]
            let participants: [String]
            let todos: [String]
        }
        struct RawTimeline: Decodable {
            let offsetSeconds: Int
            let title: String
            let detail: String
        }
        guard let data = cleaned.data(using: .utf8),
              let decoded = try? JSONDecoder().decode(RawOutline.self, from: data) else {
            throw AIProcessingError.invalidOutline
        }
        return SoundloomOutline(
            overview: decoded.overview,
            timeline: decoded.timeline.map {
                SoundloomTimelineItem(offsetSeconds: $0.offsetSeconds, title: $0.title, detail: $0.detail)
            },
            topics: decoded.topics,
            participants: decoded.participants,
            todos: decoded.todos
        )
    }
}

@available(iOS 16.0, *)
private extension SoundloomAIProvider {
    var usesOpenAICompatibleAPI: Bool {
        switch self {
        case .deepSeek, .qwen, .kimi, .openAI, .openRouter: true
        case .anthropic, .gemini: false
        }
    }
}

@available(iOS 16.0, *)
private struct OpenAICompatibleRequest: Encodable {
    struct Message: Encodable {
        let role: String
        let content: String
    }

    struct ResponseFormat: Encodable {
        let type: String
    }

    let model: String
    let messages: [Message]
    let responseFormat: ResponseFormat

    enum CodingKeys: String, CodingKey {
        case model, messages
        case responseFormat = "response_format"
    }
}

@available(iOS 16.0, *)
private struct OpenAICompatibleResponse: Decodable {
    struct Choice: Decodable {
        struct Message: Decodable { let content: String? }
        let message: Message
    }
    let choices: [Choice]
}
