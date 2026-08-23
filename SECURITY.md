# Security Policy / 安全政策

## Supported versions / 支持版本

Soundloom has not yet published a stable release. Until the first release, only the latest development revision is considered for security fixes.

Soundloom 尚未发布稳定版本。在首次发布前，只评估和修复最新开发版本中的安全问题。

After releases begin, this table must be updated for every supported line:

| Version | Supported |
|---|---|
| Development preview | Best effort |

## Reporting a vulnerability / 报告漏洞

Do **not** open a public issue for vulnerabilities involving recordings, transcripts, authentication credentials, file access, network requests, privacy disclosures, or a bypass of recording indicators.

如果问题涉及录音、转写、认证凭据、文件访问、网络请求、隐私披露或绕过录音提示，请**不要**创建公开 Issue。

Report security and privacy vulnerabilities privately to [krystalwy10@gmail.com](mailto:krystalwy10@gmail.com) with the subject `Soundloom Security`. GitHub Private Vulnerability Reporting may also be used after it is enabled for the repository.

安全与隐私漏洞请私下发送至 [krystalwy10@gmail.com](mailto:krystalwy10@gmail.com)，邮件主题请使用 `Soundloom Security`。仓库启用 GitHub Private Vulnerability Reporting 后，也可以通过该渠道报告。

Include, where safe:

- affected revision or version;
- device and OS versions;
- reproduction steps or a minimal proof of concept;
- expected and observed behavior;
- privacy or data-exposure impact;
- suggested mitigation, if known.

在安全允许的情况下，请提供：受影响版本、设备与系统版本、复现步骤或最小证明、预期与实际行为、隐私或数据暴露影响，以及已知的缓解方案。

Do not attach real recordings, transcripts, API keys, certificates, provisioning profiles, or personal data. Use synthetic test data.

不要附加真实录音、转写、API Key、证书、Provisioning Profile 或个人信息。请使用合成测试数据。

## Response goals / 响应目标

The project aims to acknowledge private reports within 7 days, provide an initial assessment within 14 days, and coordinate disclosure after a fix is available. These are goals, not a service-level agreement.

项目目标是在 7 天内确认收到私密报告、14 天内给出初步评估，并在修复可用后协调披露。这些是工作目标，不构成服务等级协议。

## Scope / 范围

High-priority areas include:

- unintended recording or recording without a visible/audible indicator;
- exposure of local audio, transcripts, indexes, or Keychain credentials;
- sending data to an endpoint without informed user action;
- insecure custom endpoints or transport downgrade;
- path traversal, unsafe file imports, or overwrite of user data;
- sensitive values in logs, exports, crash reports, or Git history.

高优先级范围包括：意外录音或缺少提示、泄露本地音频/转写/索引/Keychain 凭据、未经用户知情主动操作发送数据、不安全服务地址或传输降级、文件导入路径问题、覆盖用户数据，以及日志/导出/崩溃报告/Git 历史中的敏感信息。
