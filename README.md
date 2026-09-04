# Lockdown

A personal iPhone app that makes phone-based procrastination expensive during
study. Phone goes face down on the desk; lift it and it screams until it is
back. Every pickup and every early exit is logged as a *departure* and sent to
[Aether OS](https://github.com/calvindean49-ai/aether-os), whose `departures`
table is the instrument for deciding what to do about procrastination next.

It is a nudge with teeth, not enforcement: put the phone back and the alarm
stops; ending early is allowed through an appeal step that costs a typed
phrase or a cooldown. There is no app blocking in this build (that needs the
paid Apple Developer Program, see `docs/SETUP-MAC.md`).

## Layout

| Path | What |
|---|---|
| `Packages/LockdownCore` | Pure Swift: session state machine, motion classifier, departures, Aether client, outbox. `swift test` runs anywhere. |
| `App/Lockdown` | The iOS app: SwiftUI, CoreMotion, AVFoundation, App Intents, URL scheme. |
| `project.yml` | XcodeGen spec. The `.xcodeproj` is generated and not committed. |
| `docs/SETUP-MAC.md` | Building, signing on a free account, Shortcuts / NFC / Focus automations. |
| `docs/AETHER-INTEGRATION.md` | Which Aether routes are used, auth, network reachability. |

## Build

On the Mac:

```sh
brew install xcodegen
make test      # LockdownCore unit tests
make gen       # generate Lockdown.xcodeproj
make open      # open in Xcode, pick your team, run on the phone
```

CI (`.github/workflows/ios.yml`) runs the same on `macos-latest`.

## Control surface

- **App Intents / Siri / Shortcuts / NFC / Back Tap:** Start Lockdown, End Lockdown, Lockdown Status, Log a Departure.
- **URL scheme:** `lockdown://start?minutes=50`, `lockdown://stop`, `lockdown://departure?leftFor=…`, `lockdown://config?base=…&token=…`, `lockdown://panic`.
- **Aether OS:** the phone opens a sitting when it arms, polls it every minute, and posts departures. A Shortcuts automation on the shared "Aether Focus" Focus mode can start and end sessions from the Mac. Details in the docs.

## Status

Milestone 1 (core + skeleton + CI) is authored. Milestones 2 to 5 (motion
spike, session + alarm, control surface, Aether) are authored but not yet run
on a phone. The motion-while-locked behaviour is unverified on current iOS
hardware; the Calibration screen exists to measure it first.
