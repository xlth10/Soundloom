import AppIntents

@available(iOS 16.0, *)
enum VoiceMemoAppIntentsRegistration {
    /// Call once from the iPhone App's `@main App.init()`.
    static func register() {
        VoiceMemoShortcuts.updateAppShortcutParameters()
    }
}
