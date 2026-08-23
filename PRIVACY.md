# Soundloom Privacy Policy — Development Preview

[简体中文](PRIVACY.zh-CN.md) · English

**Effective date:** Not yet effective<br>
**Last updated:** August 23, 2026

This document describes the current Soundloom development prototype. It is a release candidate for review, not yet a published App Store privacy policy. It must be updated with the legal developer identity, contact address, final app behavior, and App Store distribution details before public release.

## Summary

Soundloom is designed to keep recordings and derived notes in the app’s local containers by default. It does not require a Soundloom account and the prototype does not include advertising, analytics, or tracking SDKs.

Two processing paths may send data off the device:

1. Apple’s Speech framework may process audio through Apple’s speech-recognition service because the current prototype does not require on-device recognition.
2. If you explicitly request AI organization, Soundloom sends the transcript and a processing instruction to the AI provider and endpoint you configured.

## Data handled by Soundloom

### Recordings

When you start recording on iPhone, Soundloom creates an audio file in the local app container. Audio imported through a supported iPhone system entry point is copied into the local recording inbox.

Soundloom does not intentionally upload the original recording to the AI organization providers configured in the app. Apple Speech may access the recording when you request transcription, as described below.

### Transcripts and organized results

Transcripts, processing status, summaries, timelines, topics, participant labels, and to-do items are stored locally with the recording index. These fields may contain personal or sensitive information derived from what was recorded.

### AI provider credentials and settings

API keys entered in Soundloom are stored in Apple Keychain. Provider name, model identifier, endpoint, enabled state, and active-provider selection are stored in local app preferences. Soundloom does not intentionally include API keys in recordings, exports, or AI request bodies.

### Diagnostics

The prototype may write technical audio-session and failure information to Apple’s unified logging system. The code is intended not to log recording contents, transcripts, or API keys. Release builds must be audited again before distribution.

## When data leaves the device

### Apple Speech transcription

The current transcription request sets `requiresOnDeviceRecognition` to `false`. Depending on the device, selected language, network, service availability, and Apple’s implementation, recording audio and related recognition data may be processed by Apple. Apple’s handling is governed by Apple’s terms and privacy policies.

Do not assume that transcription is offline merely because the recording is stored locally.

### Optional AI organization

Soundloom sends data to an AI provider only after you select an entry and request organization. The request currently includes:

- the transcript;
- an instruction describing the selected recording mode and the requested JSON structure;
- the model identifier required by the selected provider.

The request is sent directly from the device to the configured endpoint using the API key you provided. The provider may retain, process, or use that data under its own terms and privacy policy. Soundloom does not control a third-party provider’s retention practices. Review the provider’s policy before submitting sensitive text.

The currently represented providers are DeepSeek, Qwen/DashScope, Kimi/Moonshot, OpenAI, Anthropic, Gemini, and OpenRouter. Not every represented provider has an implemented request adapter in the current prototype.

## Permissions

Soundloom may request:

- **Microphone access** to create recordings;
- **Speech Recognition access** to transcribe recordings.

You can change microphone and speech-recognition permissions in system Settings. Revoking permission prevents the related feature but does not automatically delete existing files.

## Retention and deletion

The development prototype retains recordings, indexes, transcripts, and organized results locally until they are removed by app behavior, app-container removal, or the operating system.

The current prototype does **not** yet provide a complete in-app control for deleting an individual recording or erasing all local data. This is a known release blocker. Do not publish this policy as an App Store policy until the deletion flow has been implemented and verified.

API-key removal exists at the storage layer, but the public release must verify that users can reach it from the interface. Keychain items may follow operating-system behavior that differs from ordinary app-container files, including across reinstallation. The release version must provide an explicit credential-removal control.

## Accounts, tracking, and sales of data

The current prototype:

- does not require a Soundloom account;
- does not contain advertising SDKs;
- does not intentionally track users across apps or websites;
- does not sell personal data;
- does not operate a Soundloom server that receives recordings or transcripts.

Third-party AI providers are separate services selected and configured by the user.

## Recording other people

Audio recording laws and consent requirements vary by location and context. You are responsible for obtaining any required consent and for using Soundloom lawfully. Soundloom is not designed for covert recording, telephone interception, or continuous surveillance.

## Children

Soundloom is not directed to children, and the prototype does not knowingly collect information from children through a Soundloom-operated service. Recorded content can nevertheless contain information about other people; use appropriate care and consent.

## Security

Soundloom uses Apple’s app sandbox for local files, Keychain for provider credentials, and encrypted HTTPS endpoints when configured with `https://` URLs. No method of storage or transmission is completely secure. Custom endpoints are controlled by the user; using an insecure or untrusted endpoint can expose data.

## Changes

This policy will change as the iPhone app gains a standalone Xcode project, deletion controls, finalized transcription behavior, distribution details, or additional services. Material privacy changes should be documented in release notes and reflected in App Store privacy disclosures.

## Contact

For privacy questions or requests concerning the development repository, email [krystalwy10@gmail.com](mailto:krystalwy10@gmail.com). Do not send real recordings, transcripts, API keys, or other sensitive personal data unless a secure exchange method has first been agreed.
