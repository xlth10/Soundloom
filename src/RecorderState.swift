import Foundation

enum RecorderState: Equatable {
    case idle
    case recording
    case saved(URL)
    case failed(String)
}

enum RecorderEvent {
    case startRequested
    case stopRequested
    case saveSucceeded(URL)
    case operationFailed(String)
    case reset
}

struct RecorderStateMachine {
    private(set) var state: RecorderState = .idle

    mutating func reduce(_ event: RecorderEvent) {
        switch (state, event) {
        case (.idle, .startRequested):
            state = .recording
        case (.recording, .stopRequested):
            state = .idle
        case (.recording, .operationFailed(let message)), (.idle, .operationFailed(let message)):
            state = .failed(message)
        case (.idle, .saveSucceeded(let url)), (.recording, .saveSucceeded(let url)):
            state = .saved(url)
        case (.saved(_), .reset), (.failed(_), .reset):
            state = .idle
        default:
            break
        }
    }
}
