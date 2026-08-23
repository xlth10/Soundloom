# Public Release Checklist / 公开发布检查清单

This is a blocking checklist. A checked documentation item does not prove the binary behaves correctly; verification evidence is required.

这是阻塞式检查清单。文档勾选不等于二进制行为正确，必须保留验证证据。

## A. Ownership and identity / 权利与身份

- [ ] Legal developer/publisher name confirmed.
- [ ] Monitored support and privacy contact configured.
- [ ] Standalone GitHub repository owner and URL confirmed.
- [ ] Soundloom name and icon ownership reviewed.
- [ ] Third-party reference screenshots and social-post materials excluded from the public repository unless redistribution rights are documented.
- [ ] Apache-2.0 and brand policy approved by the legal owner.
- [ ] `LICENSE` text compared against the current official Apache-2.0 text in a network environment that verifies HTTP status and non-empty content.

## B. Initial iPhone source publication / iPhone 源码首次公开

- [ ] README clearly states that the initial repository is an iPhone source snapshot without a standalone Xcode project.
- [ ] Every public `src/` file belongs to the iPhone product scope; deferred non-iPhone implementations are excluded.
- [ ] iOS host-target integration steps and required capabilities are documented.
- [ ] A complete iOS `.xcodeproj` or generated-project definition is committed before the first versioned release.
- [ ] The future complete project builds from a fresh clone without the maintainer’s signing identity.
- [ ] Core capture works without any AI API key.
- [ ] Local signing overrides are ignored by Git.
- [ ] Minimum Xcode and iOS versions are explicit once the standalone project is added.
- [ ] CI performs an unsigned iPhone Simulator build and tests once the standalone project exists.
- [ ] Local build caches, dependency installs, private audit evidence, and generated working directories are excluded.

## C. Recording behavior / 录音行为

- [ ] Every recording entry point requires explicit action.
- [ ] Every active recording has a clear visual and/or audible indicator.
- [ ] No app-open, background wake, Shortcut, or Action Button path starts covert recording.
- [ ] Interruption, phone call, Siri, route change, low storage, and permission-denied paths are tested.
- [ ] Original audio survives processing failure.

## D. Privacy and data control / 隐私与数据控制

- [ ] Delete one recording and all derived data.
- [ ] Erase all recordings, indexes, transcripts, organized results, and exports.
- [ ] Remove every saved API key from the UI.
- [ ] Reinstall and upgrade behavior for Keychain and app-container data verified.
- [ ] Apple Speech local/server behavior accurately disclosed.
- [ ] AI requests are user-triggered and match `DATA_FLOW.md`.
- [ ] Custom endpoints require HTTPS or show an explicit security warning.
- [ ] Logs contain no sensitive content, credentials, headers, or provider response bodies.
- [ ] Privacy policy available in-app and at a stable public URL.
- [ ] App Store privacy answers match all targets and providers.
- [ ] Valid `PrivacyInfo.xcprivacy` included where required.

## E. Dependencies and content rights / 依赖与内容权利

- [ ] Swift Package Manager/CocoaPods/XCFramework inventory captured.
- [ ] Model and font sources, versions, hashes, and licenses recorded.
- [ ] Required notices accessible in-app.
- [ ] No copied third-party code, screenshots, text, brands, or generated assets with unclear rights.
- [ ] `THIRD_PARTY_NOTICES.md` matches the archive.

## F. App Store readiness / App Store 准备

- [ ] Apple Developer Program membership active.
- [ ] Bundle IDs, App IDs, capabilities, entitlements, and signing configured.
- [ ] Required Xcode/platform SDK version confirmed on submission day.
- [ ] Microphone and Speech Recognition purpose strings localized.
- [ ] App icon and screenshots for every submitted platform meet current specifications.
- [ ] Support URL and Privacy Policy URL live.
- [ ] Age rating, export compliance, content rights, pricing, and availability completed.
- [ ] Mainland China distribution and filing requirements decided separately.
- [ ] Reviewer notes include a complete test path and safe test configuration.
- [ ] Internal and external TestFlight validation complete.

## G. Initial GitHub source publication / GitHub 首次源码公开

- [ ] Secrets and private share-link parameters scanned before the first commit.
- [ ] Generated media workspaces, `node_modules`, Derived Data, user recordings, and third-party audit screenshots excluded.
- [ ] `README`, privacy policies, support, security, contribution, license, brand policy, and notices reviewed.
- [ ] Both languages describe the same behavior.
- [ ] README screenshots are owned or authorized for repository use and contain no unintended personal data.
- [ ] Source-only and not-yet-buildable limitations are visible near the top of both README languages.
- [ ] GitHub repository visibility, default branch, issue policy, and Private Vulnerability Reporting configured.

## H. Versioned GitHub Release / 带版本的 GitHub Release

- [ ] Secrets scanned across the full Git history.
- [ ] `CHANGELOG.md` finalized.
- [ ] Version tag points to the reviewed source commit.
- [ ] GitHub Release explains changes, privacy changes, requirements, and known issues.
- [ ] No certificates, profiles, credentials, real recordings, or private audit artifacts attached.

## Unresolved identity fields / 尚未确定的身份字段

Do not replace these with invented values. Record the final values here before release:

```text
Legal developer name:
GitHub owner/repository:
Support URL:
Support email: krystalwy10@gmail.com
Privacy URL:
Security-reporting channel: krystalwy10@gmail.com (`Soundloom Security`)
Official bundle identifiers:
App Store product URL:
Copyright year/owner:
```
