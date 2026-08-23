# Soundloom Release Process / Soundloom 发布流程

This process separates open-source publication from Apple binary distribution.

本流程将开源源码发布与 Apple 二进制分发分开管理。

## Version relationship / 版本关系

```text
Git tag v1.2.0
├── GitHub Release: source snapshot, notes, known issues, checksums/SBOM if produced
└── App Store version 1.2.0
    ├── TestFlight build 120
    └── App Store build 123
```

The marketing version should match the GitHub release tag. Apple build numbers may increase for TestFlight and review retries without creating a new public source version, provided the source revision is recorded.

营销版本应与 GitHub Release tag 对应。TestFlight 或审核重试时，Apple build number 可以递增而不创建新的公开源码版本，但必须记录对应 commit。

## 1. Freeze scope / 冻结范围

- Move completed entries from `CHANGELOG.md` into the target version.
- Confirm that no behavior or privacy change remains undocumented.
- Freeze provider endpoints and model defaults for the build.
- Identify the exact source commit.

## 2. Verify source / 验证源码

- Clone into a clean directory.
- Add only a local signing-team override.
- For the initial source-only preview, confirm that both README languages disclose the missing standalone iOS project and that only iPhone source files are included.
- Before a versioned release, build the complete iPhone target without provider API keys.
- Run unit, integration, and UI tests.
- Run formatting/static analysis.
- Scan the entire Git history for credentials and personal data.
- Audit resolved dependencies, bundled models, fonts, and licenses.

## 3. Verify privacy and security / 验证隐私与安全

- Complete every item in `PUBLIC_RELEASE_CHECKLIST.md`.
- Verify microphone and speech-recognition permission text in both languages.
- Confirm visible/audible recording indicators in every entry point.
- Confirm the actual domains contacted by the archived binary.
- Verify individual deletion, erase-all, credential removal, and export behavior.
- Update `PRIVACY*`, `DATA_FLOW.md`, `THIRD_PARTY_NOTICES.md`, and App Store privacy answers.

## 4. TestFlight / TestFlight 测试

- Archive with the required Xcode and platform SDK versions.
- Upload to App Store Connect.
- Complete export-compliance information.
- Run internal testing first, then external testing if appropriate.
- Test the submitted build on supported physical iPhone models.
- Record the build number, source commit, test devices, and sign-off evidence.

## 5. GitHub Release / GitHub 发布

1. Merge the release commit.
2. Create an annotated tag such as `v1.0.0`.
3. Create a GitHub Release with:
   - user-visible changes;
   - privacy or data-handling changes;
   - minimum iOS and device requirements;
   - known limitations;
   - App Store/TestFlight availability;
   - source archive, SBOM, notices, or checksums when available.
4. Do not attach signing certificates, provisioning profiles, API keys, App Store Connect keys, or an unsigned `.ipa` presented as a normal installation method.

## 6. App Store submission / App Store 提交

- Copy reviewed fields from `appstore/` into App Store Connect.
- Provide a reviewer path that works without exposing production credentials.
- Confirm screenshots show actual released behavior and visible recording state.
- Submit the selected build and retain manual release control for the first version.

## 7. After release / 发布后

- Verify the live product page, privacy links, support links, and supported iPhone compatibility.
- Publish the final GitHub Release URL in project metadata.
- Monitor crashes, privacy reports, security messages, and user feedback.
- If behavior differs materially from disclosure, pause distribution or disable the affected feature until corrected.

## Release record template / 发布记录模板

```text
Version:
Git tag:
Source commit:
App Store build:
Xcode / SDK:
Test devices:
Privacy policy revision:
Third-party notice revision:
Reviewer:
Known issues:
Release decision:
```
