# Contributing to Soundloom / 参与 Soundloom

Soundloom welcomes carefully scoped contributions. The product is still stabilizing, so please discuss substantial work before implementing it.

Soundloom 欢迎边界清晰、经过验证的贡献。产品仍在收敛阶段，开始较大的工作前请先讨论。

## Before you start / 开始之前

1. Search existing issues and research notes.
2. Open an issue describing the user problem, proposed boundary, privacy impact, and validation plan.
3. Wait for maintainer agreement before starting a new feature, provider integration, data migration, or architectural refactor.

1. 先搜索现有 Issue 和调研记录。
2. 创建 Issue，说明用户问题、方案边界、隐私影响和验证方法。
3. 新功能、服务商接入、数据迁移或架构重构需先获得维护者确认。

Small typo, documentation-link, and narrowly scoped test fixes may be submitted directly.

小型错字、文档链接和边界明确的测试修复可以直接提交。

## Product constraints / 产品约束

Contributions must preserve these rules:

- no covert, ambient, or always-on recording;
- recording state must be clearly visible or audible;
- preserve source audio until the user deletes it or an explicitly documented policy applies;
- failure states must not pretend that recording, transfer, transcription, or AI processing succeeded;
- recordings stay local by default;
- external processing requires informed user action;
- no API keys, credentials, personal recordings, or real transcripts in commits or tests;
- core capture remains usable without an AI provider.

贡献必须保持以下规则：

- 不做隐蔽、环境常驻或始终开启的录音；
- 录音状态必须有清晰视觉或声音提示；
- 在用户删除或明确政策生效前保留原始音频；
- 录音、传输、转写或 AI 处理失败时，不得伪装成成功；
- 默认本地保存录音；
- 外部处理必须由用户知情并主动触发；
- commit 和测试中不得包含 API Key、凭据、真实录音或真实转写；
- 没有 AI 服务商时，核心记录能力仍应可用。

## Development workflow / 开发流程

- Create a focused branch from the current development branch.
- Keep one behavioral change per pull request.
- Add or update tests for state transitions, file handling, and privacy-sensitive behavior.
- Until the standalone iOS project is committed, describe the host target, Xcode version, device, and manual validation used for every source change.
- Update both English and Simplified Chinese public documentation when behavior changes.
- Update `PRIVACY.md`, `PRIVACY.zh-CN.md`, `THIRD_PARTY_NOTICES.md`, and App Store drafts when data handling or dependencies change.

- 从当前开发分支创建聚焦的功能分支。
- 每个 Pull Request 只处理一个行为变化。
- 为状态转换、文件处理和隐私敏感行为补充或更新测试。
- 独立 iOS 工程提交前，每次源码改动都应说明宿主 target、Xcode 版本、测试设备和人工验证步骤。
- 行为变化时同步更新英文和简体中文公开文档。
- 数据处理或依赖变化时，更新隐私政策、第三方声明和 App Store 草案。

## Pull request checklist / Pull Request 检查

- [ ] The issue and scope are linked.
- [ ] The change does not contain secrets or personal data.
- [ ] Recording consent and visibility remain explicit.
- [ ] Offline/error behavior is tested.
- [ ] New network requests are documented.
- [ ] New dependencies and models have verified licenses.
- [ ] English and Chinese documentation remain consistent.
- [ ] AI-assisted code or documentation has been reviewed by the contributor, and its use is disclosed in the PR.

## Commit and review expectations / Commit 与评审要求

Use clear, imperative commit subjects. Explain why the change is needed, not only what files changed. Contributors remain responsible for every submitted line, including AI-assisted work. Generated code must meet the same correctness, security, licensing, and maintainability standard as hand-written code.

Commit 标题应简洁明确，并使用动作语气。说明为什么需要改动，而不只是改了哪些文件。无论是否使用 AI，贡献者都对提交的每一行负责；生成代码必须达到与人工代码相同的正确性、安全性、许可证和可维护性标准。

## License / 许可证

By contributing, you agree that accepted code contributions may be distributed under the repository’s Apache-2.0 license. Do not contribute material you do not have the right to license. Brand assets are governed separately by `TRADEMARKS.md`.

提交贡献即表示你同意：被接受的代码贡献可按仓库的 Apache-2.0 许可证分发。请勿提交你无权授权的材料。品牌资产另受 `TRADEMARKS.md` 约束。
