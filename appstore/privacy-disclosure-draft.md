# App Store Privacy Disclosure Working Draft

This is a decision worksheet, not a final App Store Connect answer. Complete it from the archived binary and Apple’s then-current definitions.

## Current prototype observations

- No Soundloom account.
- No advertising or analytics SDK identified.
- Local recordings, transcripts, results, and settings are stored in app containers/preferences.
- Provider API keys are stored in Keychain.
- Apple Speech may receive/process recording audio for transcription.
- User-triggered AI organization sends transcript text to a configured third-party endpoint.
- No Soundloom-operated backend is currently present.

## Questions requiring a final determination

### Audio data

- Does Apple define audio processed through Speech as data collected by the developer or only by Apple under a platform service?
- Does any final third-party SDK or proxy receive the original recording?
- Is data retained beyond servicing the request?

### User content

- Are transcripts sent to third-party AI providers considered collected under the final App Store definition, even when sent directly with a user-provided key?
- Which purposes apply: app functionality, product personalization, developer advertising, analytics, or other?
- Is any data linked to identity or used for tracking?

### Diagnostics

- Does the final build include crash reporting, analytics, or support-log upload?
- Can logs contain filenames, endpoints, provider errors, or user-derived text?

## Expected direction, subject to verification

- Tracking: **No**.
- Advertising: **No**.
- Data sold: **No**.
- User content/audio: disclose conservatively if Apple’s current definitions treat Apple Speech or direct provider processing as developer/partner collection.
- Diagnostics: disclose only if the final binary transmits them.

## Required evidence

- Xcode privacy report from the archive.
- `PrivacyInfo.xcprivacy` contents from every app/extension/SDK target.
- Network capture listing all contacted domains.
- Final provider and SDK inventory.
- Written retention behavior for every endpoint.
- Final privacy policy in both languages.
