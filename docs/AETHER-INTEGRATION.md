# Aether OS integration

Aether is HTTP JSON only. There is no push channel from Aether to the phone,
so the phone is the initiator: it starts a sitting, polls it, and posts
departures. Aether reaching the phone is done with the shared "Aether Focus"
Focus mode plus a Shortcuts automation (see `SETUP-MAC.md`).

## Auth

Aether's only scheme is the `aether_session` cookie carrying the raw
`AETHER_AUTH_TOKEN`. The client sets `Cookie: aether_session=<token>` by hand and
URLSession cookie handling is off. If the token is unset on the server, no auth
is needed and the header is harmless.

## Routes used

| When | Call |
|---|---|
| host probe | `GET /api/session/active` (fallback `GET /api/health`) |
| session arms (phone placed) | `POST /api/session/start {"knowledgeObjectIds":[],"techniqueUsed":"lockdown-ios"}`; `409` means a sitting is already running and the phone rides along (`adopted`) |
| every 60 s while guarding | `GET /api/session/active`; `active: null` while linked ends the phone session (`aetherStopped`) |
| timer expires, phone started the sitting | `POST /api/session/stop {"durationMinutes":N,"selfReported":"lockdown-ios timer"}` |
| early exit, only if *Stop the Aether sitting on early exit* is on | same stop call |
| every departure | `POST /api/native/departures {"leftFor":"<his words, ≤200>","app":"<optional>"}` |

Departures and stops go through a durable outbox (`Application Support/Lockdown/outbox.json`)
with exponential backoff, drained on each poll and each foreground. A 4xx
other than 401/403 is treated as Aether refusing the content and the item is
dropped; anything else retries.

## Reachability

`127.0.0.1:8787` is the Mac itself. Configure hosts the phone can reach, in
priority order: LAN (`http://your-mac.local:8787`, requires
`NSAllowsLocalNetworking`, already set), Tailscale, then the public HTTPS host.
The first that answers is cached until a call fails.

## What is deliberately not done

- No new Aether routes or migrations. Everything above exists today.
- No `severity` or "minutes lost" on a departure; the record is his words and
  an optional app, matching Aether's own schema.
- No Web Push subscription. The PWA's push kinds are a closed set and adding
  one is Aether's decision.
