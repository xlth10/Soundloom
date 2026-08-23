import Foundation
import Speech

@available(iOS 16.0, *)
enum SpeechTranscriptionError: LocalizedError {
    case notAuthorized
    case recognizerUnavailable
    case noResult

    var errorDescription: String? {
        switch self {
        case .notAuthorized:
            return "尚未获得语音识别权限"
        case .recognizerUnavailable:
            return "当前语言的语音识别不可用"
        case .noResult:
            return "没有识别到语音内容"
        }
    }
}

@available(iOS 16.0, *)
@MainActor
final class SpeechTranscriptionService {
    func transcribe(fileURL: URL, locale: Locale = Locale(identifier: "zh-CN")) async throws -> String {
        guard await SpeechRecognitionAuthorization.request() else {
            throw SpeechTranscriptionError.notAuthorized
        }

        guard let recognizer = SFSpeechRecognizer(locale: locale), recognizer.isAvailable else {
            throw SpeechTranscriptionError.recognizerUnavailable
        }

        let request = SFSpeechURLRecognitionRequest(url: fileURL)
        request.shouldReportPartialResults = false
        request.requiresOnDeviceRecognition = false

        return try await withCheckedThrowingContinuation { continuation in
            recognizer.recognitionTask(with: request) { result, error in
                if let error {
                    continuation.resume(throwing: error)
                    return
                }
                guard let result, result.isFinal else { return }
                let text = result.bestTranscription.formattedString.trimmingCharacters(in: .whitespacesAndNewlines)
                guard !text.isEmpty else {
                    continuation.resume(throwing: SpeechTranscriptionError.noResult)
                    return
                }
                continuation.resume(returning: text)
            }
        }
    }
}
