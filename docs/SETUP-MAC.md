# Setting up on the Mac and the phone

## Requirements

- Xcode 16 or newer (the project targets iOS 18).
- `brew install xcodegen`.
- A free Apple ID is enough for this build. Limits that follow from that:
  - the app stops launching **7 days** after install; rebuild and run from Xcode again;
  - at most 3 sideloaded apps on the phone, 10 App IDs per week;
  - no Screen Time / Family Controls, so no app blocking. Paying for the
    Developer Program ($99/yr) lifts all three; app blocking is a later milestone.

## First build

```sh
make gen
make open
```

In Xcode: select the `Lockdown` target, Signing & Capabilities, choose your
personal team. Or put `DEVELOPMENT_TEAM = <your team id>` in
`Config/Local.xcconfig` (gitignored) and XcodeGen will pick it up.

Plug the phone in, pick it as the run destination, Run. First launch on the
phone: Settings > General > VPN & Device Management, trust the developer.

## First run on the phone (milestone 2, the go/no-go)

1. Open Calibration. Tap **Start streaming**. Samples / s should read about 20.
2. Put the phone face down on the desk. *Anchored* should read YES within a second.
3. Lock the phone with the side button. Wait 30 s. Unlock. Did *Samples / s* stay near 20?
4. Repeat with the silent switch on, and once with Low Power Mode on.
5. Record `desk`, `pickup` and `bump` traces; they appear in the Files app under
   Lockdown. Copy them into `Packages/LockdownCore/Tests/Fixtures/motion/`.

If samples stop while locked, turn on **Keep screen on during a session** in
Settings and use the app in the foreground. That is the fallback the design
allows for; the classifier and everything else are unchanged.

## Aether OS

Settings > Aether OS. Hosts are tried in order; the phone cannot reach
`127.0.0.1`, so use the Mac's LAN name (`http://your-mac.local:8787`), a
Tailscale name, or the HTTPS host in front of the VPS. Paste the value of
`AETHER_AUTH_TOKEN` as the token. **Test connection** tells you which host answered.

Or from a Shortcut / QR code: `lockdown://config?base=http://your-mac.local:8787,https://aether.example&token=SECRET`.

## Shortcuts and automations

The app exposes four App Intents: Start Lockdown (minutes, source), End
Lockdown, Lockdown Status, Log a Departure. Siri phrases are registered
automatically ("Start lockdown in Lockdown").

- **NFC tag on the desk:** Shortcuts > Automation > NFC > scan the tag > *Run Immediately* > action **Start Lockdown**, source *NFC tag*.
- **Back Tap:** Settings > Accessibility > Touch > Back Tap > pick a shortcut that runs Start Lockdown.
- **Aether Focus (Mac to phone):** in the Shortcuts app on the phone, Automation > Focus > "Aether Focus" (the Focus your `Aether Focus On` Mac shortcut sets) > *When turned on* > *Run Immediately* > **Start Lockdown**, source *Aether Focus*. Add a second one for *When turned off* > **End Lockdown**, source *Aether Focus*. A session started this way ends without an appeal when the Focus turns off.

  For that to reach the phone, the Focus needs *Share Across Devices* on
  (Settings > Focus). Note that Aether only flips the Focus automatically when
  its `focus-mode` automation has been earned; until then the Focus button in
  Aether's UI on the Mac is the trigger.

## URL scheme

```
lockdown://start?minutes=50&origin=nfc
lockdown://stop
lockdown://departure?leftFor=water&app=Messages
lockdown://config?base=...&token=...
lockdown://panic
```
