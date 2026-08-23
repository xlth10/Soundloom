import Speech

@available(iOS 16.0, *)
enum SpeechRecognitionAuthorization {
    static var isAuthorized: Bool {
        SFSpeechRecognizer.authorizationStatus() == .authorized
    }

    static func request() async -> Bool {
        switch SFSpeechRecognizer.authorizationStatus() {
        case .authorized:
            return true
        case .notDetermined:
            break
        case .denied, .restricted:
            return false
        @unknown default:
            return false
        }

        let status = await withCheckedContinuation { continuation in
            SFSpeechRecognizer.requestAuthorization { status in
                continuation.resume(returning: status)
            }
        }
        return status == .authorized
    }
}
