# Third-Party Notices / 第三方声明

**Last reviewed / 最后审核：2026-08-23**

This inventory describes the current prototype repository. It must be regenerated from the final Xcode project, resolved packages, linked binaries, models, fonts, and bundled assets before every public release.

本清单描述当前原型仓库。每次公开发布前，都必须根据最终 Xcode 工程、已解析依赖、链接二进制、模型、字体和随包资产重新生成并审核。

## Apple frameworks / Apple 系统框架

The public iPhone source imports Apple platform frameworks including SwiftUI, Foundation, Combine, AVFAudio, Speech, AppIntents, Security, and OSLog. These frameworks are supplied by Apple through Xcode and the operating system; they are not relicensed under this repository’s Apache-2.0 license.

公开的 iPhone 源码使用 SwiftUI、Foundation、Combine、AVFAudio、Speech、AppIntents、Security 和 OSLog 等 Apple 平台框架。它们由 Apple 通过 Xcode 和操作系统提供，不按本仓库 Apache-2.0 许可证重新授权。

Use of Apple SDKs, SF Symbols identifiers, App Store assets, and platform services is subject to Apple’s applicable agreements and guidelines.

Apple SDK、SF Symbols 标识、App Store 资产和平台服务的使用受 Apple 相关协议与指南约束。

## External AI services / 外部 AI 服务

Soundloom can be configured to contact third-party services, including DeepSeek, Alibaba Cloud DashScope/Qwen, Moonshot/Kimi, OpenAI, Anthropic, Google Gemini, and OpenRouter. These services are not bundled dependencies and are not part of Soundloom. Their names identify compatibility targets only. Users are responsible for the providers’ terms, privacy policies, accounts, and charges.

Soundloom 可配置连接 DeepSeek、阿里云 DashScope/通义千问、Moonshot/Kimi、OpenAI、Anthropic、Google Gemini 和 OpenRouter。这些服务不是随包依赖，也不属于 Soundloom；名称仅用于说明兼容目标。用户需自行遵守服务商条款、隐私政策、账号和费用规则。

## Reference material not for redistribution / 不用于重新分发的参考材料

The Emergence Lab working directory contains research inputs and audit screenshots from third-party products or pages. They are evidence, not Soundloom assets. In particular, external-reference images under `docs/audit/` and third-party social-post material must be reviewed and normally excluded when extracting the standalone public repository.

Emergence Lab 工作目录包含第三方产品或页面的调研输入和审计截图。这些内容是研究证据，不是 Soundloom 资产。提取独立公开仓库时，应审核并通常排除 `docs/audit/` 下的外部参考图和第三方社交平台材料。

## Maintainer-provided product assets / 维护者提供的产品素材

The official app icon under `assets/branding/` and the screenshots under `assets/screenshots/` were supplied by the project maintainer for repository presentation. They are product and brand materials, not source code, and are reserved under `TRADEMARKS.md`. Local AI-assisted icon and animation exploration workspaces are intentionally excluded from the public source set.

`assets/branding/` 中的正式 App 图标与 `assets/screenshots/` 中的截图由项目维护者提供，用于仓库展示。它们属于产品与品牌素材，不属于源代码，并受 `TRADEMARKS.md` 约束。本地 AI 辅助图标和动画探索工作区会被有意排除在公开源码集合之外。

## Current vendored dependencies / 当前随仓库依赖

No non-Apple package-manager dependency or third-party machine-learning model is vendored in the initial public iPhone source snapshot. This statement must be rechecked when the standalone Xcode project or any packages, binaries, models, fonts, or bundled resources are added.

首次公开的 iPhone 源码快照没有随仓库提供非 Apple 包管理依赖或第三方机器学习模型。添加独立 Xcode 工程、包、二进制、模型、字体或随包资源时，必须重新审核这一结论。

## Release requirement / 发布要求

The release build must provide an in-app acknowledgements screen or another accessible notice for every dependency whose license requires attribution or notice reproduction.

对于要求署名或随附许可证文本的依赖，发布版必须在 App 内提供鸣谢/许可证页面或其他可访问声明。
