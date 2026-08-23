# Soundloom Data Flow / Soundloom 数据流

**Status / 状态：Development preview / 开发预览**<br>
**Reviewed / 审核日期：2026-08-23**

This document maps the current prototype behavior to its storage and network boundaries. It supports privacy review; it is not a substitute for testing the final binary.

本文把当前原型行为映射到存储与网络边界，用于隐私审核，但不能替代对最终二进制的测试。

## Capture and storage / 捕捉与存储

| Stage / 阶段 | Data / 数据 | Location / 位置 | Network / 网络 |
|---|---|---|---|
| iPhone capture/import | Audio file, duration, mode, source | iPhone `Documents/VoiceMemos` or `Documents/Recordings` | No external network request by Soundloom |
| Inbox index | Filename, date, duration, mode, source, processing state, transcript, outline | Local JSON file in the iPhone app container | None |
| Inspiration card | Structured local record referencing the source audio | iPhone app storage | None |
| Provider settings | Provider, model, base URL, enabled state | Local `UserDefaults` | None until processing |
| API key | Provider credential | Apple Keychain | Sent only as authorization to the configured provider when processing |

## Transcription / 转写

The current `SpeechTranscriptionService` uses `SFSpeechURLRecognitionRequest` and sets `requiresOnDeviceRecognition = false`.

当前 `SpeechTranscriptionService` 使用 `SFSpeechURLRecognitionRequest`，并设置 `requiresOnDeviceRecognition = false`。

Consequences / 影响：

- Apple may process recording audio through its speech-recognition service.
- Availability and behavior may vary by device, locale, network, and Apple service status.
- The UI must not describe this version as guaranteed offline transcription.
- If a future release requires on-device recognition, the code, fallback behavior, supported languages, privacy policy, and App Store disclosures must all change together.

- Apple 可能通过其语音识别服务处理录音。
- 可用性和行为会受设备、语言、网络及 Apple 服务状态影响。
- 当前版本的 UI 不应宣称“保证离线转写”。
- 如果未来强制设备端识别，代码、降级方式、支持语言、隐私政策和 App Store 披露必须同步更新。

## AI organization / AI 整理

AI organization is user-triggered. The current request sends the transcript, a mode-specific system instruction, model identifier, and API authorization header to the configured endpoint. It does not intentionally attach the original audio file.

AI 整理由用户主动触发。当前请求会把转写文本、与记录模式相关的系统指令、模型标识和 API 授权头发送到已配置地址，不会故意附加原始音频。

Implemented OpenAI-compatible adapters / 已实现 OpenAI 兼容适配：

- DeepSeek
- Qwen through DashScope
- Kimi through Moonshot
- OpenAI
- OpenRouter

Represented but not yet implemented with provider-specific formats / 已展示但尚未实现专用格式：

- Anthropic
- Gemini

## Deletion gaps / 删除缺口

The storage layer can remove provider credentials, but the current public UI does not expose a complete delete-recording, erase-all-data, and remove-credential flow. This is a release blocker and must be tested across app upgrades and reinstall behavior.

存储层可以移除服务商凭据，但当前界面尚未提供完整的删除单条录音、清空全部数据和移除凭据流程。这是发布阻塞项，并且需要覆盖 App 升级和重新安装行为进行测试。

## Logging / 日志

The iPhone recorder may log audio-session state, route types, invocation identifiers, and error descriptions through Apple unified logging. Release verification must confirm that no recording content, transcript, API key, authorization header, filesystem path containing user data, or provider response body is logged.

iPhone 录音实现可能通过 Apple 统一日志记录音频会话状态、路由类型、调用标识和错误说明。发布验证必须确认日志中不存在录音内容、转写、API Key、授权头、包含用户数据的文件路径或服务商响应正文。

## Release verification / 发布验证

- Inspect the final privacy report and `PrivacyInfo.xcprivacy` from the archived app.
- Capture network traffic in controlled test accounts and confirm every domain.
- Test denied and revoked permissions.
- Test airplane mode, provider timeout, invalid certificates, and invalid API keys.
- Verify deletion of audio, index entries, transcripts, organized results, exports, and Keychain credentials.
- Compare the binary’s behavior with both privacy-policy languages and App Store privacy answers.

- 检查归档 App 的隐私报告和 `PrivacyInfo.xcprivacy`。
- 使用受控测试账号抓取网络流量并确认所有域名。
- 测试拒绝及撤销权限。
- 测试飞行模式、服务商超时、无效证书和错误 API Key。
- 验证音频、索引、转写、整理结果、导出与 Keychain 凭据的删除。
- 对照中英文隐私政策和 App Store 隐私回答检查最终二进制行为。
