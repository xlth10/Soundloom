# 开源 iPhone 工具的 GitHub 发布方式调研

- 调研日期：2026-08-13
- 决策目标：为 Soundloom 选择一种既可供第三方审计和构建、又不泄露签名凭据、API Key、用户数据和发布控制权的 GitHub 开源方式。
- 当前假设：适合 Soundloom 的不是“把当前实验目录整体设为公开”，而是建立独立、可构建的产品仓库，将源码、构建说明、隐私材料和 App Store 元数据公开，将签名、商店凭据、真实数据和商业品牌控制留在仓库之外。

## 结论摘要

调研到的项目大致形成四种模式：

1. **完整产品源码开源**：提交可生成或直接打开的 Xcode 工程，提供许可证和本地构建入口，例如 WhisperBoard、NetNewsWire。
2. **隐私优先、模型按需下载**：代码和模型许可证写清楚，但大型模型不随 Git 仓库分发，例如 Diktafon。
3. **BYOK 产品与发布资料同库**：API Key 由用户输入并放入 Keychain，App Store 文案、审核说明、隐私与支持页面也纳入版本控制，例如 Scowld。
4. **源码可见但不是开源**：仓库公开且 App 已上架，但项目本身没有 LICENSE，第三方默认没有复制、修改和再分发许可，例如 shower-thoughts。

对 Soundloom 最合适的是组合 1–3，并明确避免模式 4 的许可证歧义。

## 案例对比

| 项目 | 与 Soundloom 的相似性 | 仓库/构建方式 | 许可证 | App Store 与 GitHub 的关系 | 最值得借鉴 | 局限 |
|---|---|---|---|---|---|---|
| [WhisperBoard](https://github.com/Saik0s/Whisperboard) | iOS 录音、导入/导出、Whisper 本地转写 | SwiftUI/TCA；提交 Tuist 项目描述和 Makefile，README 指示 clone → `make` → Xcode | GPL-3.0；字体另用 SIL OFL | 仓库主页没有可核实的 GitHub Release 或 App Store 分发说明 | 用单一命令生成工程；主代码与字体许可证分开；模型可在 App 内下载 | README 很短，未展示成熟的贡献、安全和发布治理；GPL 对官方 App 与闭源衍生版本的策略要求更高 |
| [Diktafon](https://github.com/jaromiru/diktafon) | 录音、离线转写、离线摘要、隐私优先 | Flutter 多平台；固定 Flutter/NDK/Java 版本；公开 build/test 命令和端到端流程 | MIT；在 [LICENCE.md](https://github.com/jaromiru/diktafon/blob/main/LICENCE.md) 逐项列出 vendored 引擎、字体、VAD 和运行时模型许可证 | iOS 通过 App Store；GitHub Releases 主要给 Android/Linux，并给二进制校验和与构建来源证明 | 大模型不进仓库/安装包，运行时下载；许可证清单覆盖代码、字体、模型和包；真实 AI 测试可通过本地模型路径启用 | 公开 README 中的 iOS 从源码构建步骤不如 Android/Linux 完整；跨平台结构与 Soundloom 的原生 Swift 架构不同 |
| [Scowld](https://github.com/apoorvdarshan/scowld) | 原生 SwiftUI、语音输入、多 AI 服务商、BYOK、Keychain | `ios/Scowld.xcodeproj` 可直接打开；同一仓库包含 iOS App、网站和公开资产 | MIT；第三方 avatar 前端也标注 MIT | 仓库链接 App Store；[APPSTORE.md](https://github.com/apoorvdarshan/scowld/blob/main/APPSTORE.md) 版本化保存名称、描述、关键词、隐私/支持 URL 和 Reviewer Notes | API Key 不随包分发，用户在 App 内输入并存 Keychain；README 清楚说明什么数据发往用户选择的服务商；贡献和安全政策单列 | 多种云端服务使隐私声明和供应商条款复杂；仓库内品牌资产是否也受 MIT 许可需要项目方进一步明确 |
| [shower-thoughts](https://github.com/kilsekddd/shower-thoughts) | iOS push-to-talk、Whisper 本地转写、无账号/无网络 | Flutter；提交 `ios/`、原生 whisper bridge、PRD、架构、测试、App Store 文案与截图；约 77 MB 模型被 gitignore | **项目自身无 LICENSE**；只列明第三方组件的许可证 | README 记录 App Review 与上线日期；App Store 素材和隐私政策与源码同库 | 发布材料可审计；明确保存/删除音频策略；把大模型排除出 Git；产品、架构和发布状态写得很透明 | 公开源码不等于开源。没有许可证时，第三方默认无权复制、修改或分发；不应照搬其“开源”表述 |
| [NetNewsWire](https://github.com/Ranchero-Software/NetNewsWire) | 不是语音工具，但代表成熟的原生 iOS/macOS 开源治理 | 完整 Xcode 工程、共享模块、测试计划、构建脚本；本地 `DeveloperSettings.xcconfig` 覆盖团队 ID、组织 ID 和签名 | MIT，另有 CONTRIBUTING 和 Code of Conduct | 官方 App Store 构建由维护者控制；公开构建在缺少私有 API Key 时会禁用部分服务 | 签名配置不修改共享 `.xcodeproj`；没有密钥仍能构建核心 App；贡献前先讨论，避免无效 PR；明确 LLM 贡献披露和质量责任 | 体量和治理成本远高于个人项目，不适合第一天全部照搬 |

## 各项目实际怎样“开源”

### 1. 仓库提交的是可构建产品，而不是零散 Swift 文件

WhisperBoard 提交 Tuist 的 `Project.swift`/`Workspace.swift` 和 Makefile，由 `make` 安装工具、生成工程并打开 Xcode。NetNewsWire 则直接提交完整 Xcode 工程、各平台目录、共享模块和测试计划。这两种方式都满足同一个目标：新贡献者不需要自己猜 target membership、bundle 关系或依赖配置。

Soundloom 当前只有 `src/*.swift`，缺少正式 `.xcodeproj`/`.xcworkspace`、targets、Info.plist、entitlements 和隐私清单，因此目前属于“源码片段可读”，还不是“第三方可复现构建”的开源产品。

### 2. 公开开发配置，私藏发布身份与凭据

NetNewsWire 的 README 给出了很成熟的做法：仓库保持干净，开发者在仓库相邻目录创建未提交的 `DeveloperSettings.xcconfig`，覆盖 `DEVELOPMENT_TEAM`、组织标识、签名方式和 provisioning 配置。缺少官方私有 API Key 时，公开构建仍能运行，只是禁用对应服务。

这比把个人 Team ID 写死在 Xcode 工程，或要求贡献者修改 `.pbxproj` 更稳妥。Soundloom 可以采用：

```text
Config/
├── Base.xcconfig              # 提交
├── Debug.xcconfig             # 提交
├── Release.xcconfig           # 提交，不含秘密
└── LocalOverrides.xcconfig    # gitignore
```

官方 App Store 签名、App Store Connect API Key、证书、provisioning profiles 和 CI secrets 只放在 Apple/GitHub 的密钥系统，不进入 Git 历史。

### 3. 大模型不是普通源码依赖

Diktafon 把依赖拆成四类：vendored C/C++ 引擎、仓库内字体/VAD、运行时下载的 Whisper/Qwen 模型、包管理器下载的 Flutter 依赖；每类都在许可证文件中说明来源和许可。WhisperBoard也允许用户在 App 中选择和下载 Whisper 模型。shower-thoughts 则把约 77 MB 模型 gitignore，但在 App 内提供开源许可证页面。

Soundloom 如果以后加入 WhisperKit、whisper.cpp 或本地 LLM，应同时回答：

- 模型是否进入 Git、Git LFS、App 包，还是首次运行下载？
- 下载地址、SHA-256、模型版本和许可证如何固定？
- 模型损坏、下载中断、设备空间不足如何恢复？
- App 内在哪里查看第三方许可证？

第一版更建议使用 Apple Speech，避免在开源和上架的第一阶段同时承担大型模型分发问题。

### 4. BYOK 不代表可以省略隐私说明

Scowld 的 README 不只说“Key 存 Keychain”，还明确说明语音、prompt、可选图片和生成文本会直接发送给用户选定的服务商；其 App Store 文案和审核说明也保存于仓库。Reviewer Notes 会解释 App 没有内置免费 Key、审核员如何配置和验证完整流程。

这正适合 Soundloom 当前的 AI provider 设计。应公开说明：

- Key 由用户提供并保存在 Keychain；
- 原始录音是否离开设备；
- 哪一步发送转写文本、发送给哪个 provider；
- 用户如何删除 Key、本地音频和结构化结果；
- 无 Key 时哪些功能仍可使用。

### 5. App Store 是官方二进制渠道，GitHub 是源码与协作渠道

在这些案例中，iOS 的官方安装普遍指向 App Store。GitHub Releases 即使存在，也主要用于变更记录或可侧载的 Android/Linux/macOS 工件，而不是给普通 iPhone 用户分发 `.ipa`。原因包括 Apple 签名、设备授权、更新和审核渠道。

因此 Soundloom 不需要把“GitHub 开源”和“GitHub 分发 iPhone 二进制”绑定在一起。推荐关系是：

```text
GitHub main/tag            App Store Connect
源码、测试、文档            官方签名 Archive
隐私政策、发布文案    ───→  TestFlight / App Review
Issues、PR、Security        面向用户的正式二进制
```

### 6. 许可证决定它是不是开源

shower-thoughts 很透明地公开全部源码和发布材料，却明确没有项目 LICENSE，并要求打算 fork、修改或再分发的人先联系作者。这属于 source-available，不满足通常意义上的开源授权。

Soundloom 必须在公开仓库前选择许可证，并处理品牌边界：

- 如果仓库只放一个笼统的 Apache-2.0 或 MIT LICENSE，却没有说明素材边界，代码、图标、文案和截图的授权范围容易产生歧义；
- 如果希望保留 `Soundloom` 名称、App 图标和商店截图，应在 README/TRADEMARKS 中明确它们不随代码许可证授权，或把品牌资产移出开源仓库；
- 第三方字体、模型、框架和参考素材继续遵循各自许可证，不能用项目总许可证覆盖。

## 对 Soundloom 的推荐开源模型

推荐采用“**Apache-2.0 代码 + 品牌保留 + App Store 官方构建**”模式：

```text
soundloom/
├── Soundloom.xcodeproj
├── Apps/
│   ├── iPhone/
│   └── Watch/
├── Packages/SoundloomCore/
├── Tests/
├── Config/
│   ├── Base.xcconfig
│   └── LocalOverrides.xcconfig.example
├── docs/
│   ├── architecture.md
│   ├── privacy.md
│   └── release-process.md
├── appstore/
│   ├── metadata.zh-Hans.md
│   ├── metadata.en.md
│   └── review-notes.md
├── LICENSE                 # Apache-2.0
├── TRADEMARKS.md           # 名称、图标和商店素材边界
├── THIRD_PARTY_NOTICES.md
├── CONTRIBUTING.md
├── SECURITY.md
├── CODE_OF_CONDUCT.md
└── README.md
```

### 第一次公开前的最小门槛

1. 全新 clone 后，不使用作者证书和 API Key，也能构建并运行核心 iPhone/Watch 流程。
2. `LocalOverrides.xcconfig`、证书、profiles、`.env`、录音、转写和真实日志均被忽略。
3. README 明确最低 Xcode/iOS/watchOS、设备限制、构建命令和不可用能力。
4. LICENSE、THIRD_PARTY_NOTICES 和品牌边界没有冲突。
5. App 内可以查看隐私政策、第三方许可证和删除数据入口。
6. GitHub Actions 至少执行格式检查、单元测试和无签名 simulator build；App Store 上传工作流可保持私有或仅由维护者触发。
7. tag 与 App Store 版本对应，例如 `v1.0.0` 对应商店 `1.0.0`，build number 仍由发布系统递增。

## 证据强度与未确认项

- **高置信度**：许可证、仓库结构、README 构建方式、模型分发说明、BYOK/Keychain 说明、App Store 文案同库做法，均来自项目官方仓库。
- **中置信度**：各项目完整的内部 App Store 自动化方式。公开仓库通常不会暴露签名 secrets，且部分项目没有公开 iOS 发布 workflow，因此不能从“没有公开 workflow”推断其一定是手工上传。
- **尚未确认**：WhisperBoard 是否仍有当前有效的 App Store 版本；本报告不把它作为已上架案例，只把它作为原生 iOS 开源构建案例。

## 来源

访问日期均为 2026-08-13。

- [WhisperBoard 官方仓库](https://github.com/Saik0s/Whisperboard)：GPL-3.0、Tuist/Makefile、构建步骤、字体许可证、模型下载能力。
- [WhisperBoard Makefile](https://github.com/Saik0s/Whisperboard/blob/main/Makefile)：工程生成、App Store 配置和静态分析入口。
- [Diktafon 官方仓库](https://github.com/jaromiru/diktafon)：App Store、构建/测试、模型策略、GitHub Releases 和来源证明。
- [Diktafon LICENCE.md](https://github.com/jaromiru/diktafon/blob/main/LICENCE.md)：MIT 与第三方引擎、字体、VAD、运行时模型许可证。
- [Scowld 官方仓库](https://github.com/apoorvdarshan/scowld)：原生 Xcode 项目、BYOK、Keychain、隐私模型、MIT、贡献和安全政策。
- [Scowld APPSTORE.md](https://github.com/apoorvdarshan/scowld/blob/main/APPSTORE.md)：App Store 字段、隐私文案和 Reviewer Notes。
- [shower-thoughts 官方仓库](https://github.com/kilsekddd/shower-thoughts)：仓库布局、隐私政策、App Store 素材、模型 gitignore 和缺少项目 LICENSE 的明确说明。
- [NetNewsWire 官方仓库](https://github.com/Ranchero-Software/NetNewsWire)：完整 Xcode 工程、测试计划、MIT、签名配置覆盖和无私钥构建降级。
- [NetNewsWire CONTRIBUTING.md](https://github.com/Ranchero-Software/NetNewsWire/blob/main/CONTRIBUTING.md)：先讨论后 PR、代码质量要求、LLM 使用披露。
