# App Review Notes — Draft / App 审核说明草案

> Replace all unresolved fields and verify every step against the submitted build.

## Product boundary

Soundloom records only after an explicit user action. It does not perform ambient, covert, or always-on recording. Active recording is shown in the foreground recording interface with a visible stop-and-save control.

## Suggested review path

1. Launch Soundloom on iPhone.
2. Grant Microphone permission when requested.
3. Select “灵感闪记” (Inspiration Quick Capture) or “深度现场” (Deep Field), matching the current interface labels.
4. Start recording, speak a short synthetic test phrase, then stop and save.
5. Open the saved entry.
6. Grant Speech Recognition permission and request transcription.
7. Verify the recording and transcript remain visible in the local inbox.

## Optional AI organization

The app does not include a production API key. Core recording and storage do not require one. If optional AI organization is enabled in the submitted build, provide Apple with a safe, restricted review credential through App Store Connect’s private review fields—not in this repository—or provide a review mode that returns deterministic synthetic data without representing it as a live provider result.

Never place a review credential in Git, screenshots, public notes, or the app binary.

## Data-handling disclosure

- Recordings are stored in the local app container.
- Apple Speech transcription may use Apple’s speech-recognition service; this build does not guarantee offline recognition.
- Optional AI organization sends transcript text, not the original audio, to the user-configured endpoint after explicit action.
- Provider API keys are stored in Keychain.

## Required before submission

```text
Review contact name:
Review phone:
Review email: krystalwy10@gmail.com
Demo credential delivery method (if needed):
Known limitations in submitted build:
```
