import Combine
import Foundation
import Security

@MainActor
final class AIConfigurationStore: ObservableObject {
    @Published private(set) var configurations: [SoundloomAIConfiguration]
    @Published private(set) var activeProvider: SoundloomAIProvider

    private let defaults: UserDefaults
    private let configurationsKey = "soundloom.ai.configurations"
    private let activeProviderKey = "soundloom.ai.active-provider"

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        configurations = Self.loadConfigurations(from: defaults, key: configurationsKey)
        activeProvider = SoundloomAIProvider(rawValue: defaults.string(forKey: activeProviderKey) ?? "") ?? .deepSeek
    }

    var activeConfiguration: SoundloomAIConfiguration {
        configurations.first(where: { $0.provider == activeProvider }) ?? SoundloomAIConfiguration(provider: activeProvider)
    }

    func configuration(for provider: SoundloomAIProvider) -> SoundloomAIConfiguration {
        configurations.first(where: { $0.provider == provider }) ?? SoundloomAIConfiguration(provider: provider)
    }

    func save(_ configuration: SoundloomAIConfiguration, apiKey: String?) throws {
        if let index = configurations.firstIndex(where: { $0.provider == configuration.provider }) {
            configurations[index] = configuration
        } else {
            configurations.append(configuration)
        }
        if let apiKey, !apiKey.isEmpty {
            try SecureCredentialStore.save(apiKey, account: configuration.provider.rawValue)
        }
        persist()
    }

    func setActiveProvider(_ provider: SoundloomAIProvider) {
        activeProvider = provider
        defaults.set(provider.rawValue, forKey: activeProviderKey)
    }

    func hasAPIKey(for provider: SoundloomAIProvider) -> Bool {
        (try? SecureCredentialStore.read(account: provider.rawValue))?.isEmpty == false
    }

    func apiKey(for provider: SoundloomAIProvider) throws -> String {
        guard let key = try SecureCredentialStore.read(account: provider.rawValue), !key.isEmpty else {
            throw AIConfigurationError.missingAPIKey(provider.title)
        }
        return key
    }

    func removeConfiguration(for provider: SoundloomAIProvider) throws {
        configurations.removeAll { $0.provider == provider }
        try SecureCredentialStore.remove(account: provider.rawValue)
        if activeProvider == provider {
            activeProvider = .deepSeek
            defaults.set(activeProvider.rawValue, forKey: activeProviderKey)
        }
        persist()
    }

    private func persist() {
        guard let data = try? JSONEncoder().encode(configurations) else { return }
        defaults.set(data, forKey: configurationsKey)
    }

    private static func loadConfigurations(from defaults: UserDefaults, key: String) -> [SoundloomAIConfiguration] {
        guard let data = defaults.data(forKey: key),
              let saved = try? JSONDecoder().decode([SoundloomAIConfiguration].self, from: data) else {
            return [SoundloomAIConfiguration(provider: .deepSeek, isEnabled: true)]
        }
        return saved
    }
}

enum AIConfigurationError: LocalizedError {
    case missingAPIKey(String)

    var errorDescription: String? {
        switch self {
        case .missingAPIKey(let provider): "请先配置 \(provider) 的 API Key。"
        }
    }
}

enum SecureCredentialStore {
    private static let service = "com.soundloom.ai"

    static func save(_ value: String, account: String) throws {
        let data = Data(value.utf8)
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]
        SecItemDelete(query as CFDictionary)
        var addQuery = query
        addQuery[kSecValueData as String] = data
        let status = SecItemAdd(addQuery as CFDictionary, nil)
        guard status == errSecSuccess else { throw KeychainError(status: status) }
    }

    static func read(account: String) throws -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        if status == errSecItemNotFound { return nil }
        guard status == errSecSuccess,
              let data = item as? Data else { throw KeychainError(status: status) }
        return String(decoding: data, as: UTF8.self)
    }

    static func remove(account: String) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]
        let status = SecItemDelete(query as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else { throw KeychainError(status: status) }
    }
}

private struct KeychainError: LocalizedError {
    let status: OSStatus
    var errorDescription: String? { "无法更新安全凭据（状态码：\(status)）。" }
}
