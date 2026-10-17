# Blocklists

AdGuard-compatible DNS blocklists that completely block access to specific
services/companies.

| File | Blocks |
| --- | --- |
| `meta.txt` | All Meta services (Facebook, Instagram, Threads, Messenger, WhatsApp, Meta AI, Llama, Oculus/Quest, Workplace) |
| `meta-without-whatsapp.txt` | Meta services, but leaves WhatsApp fully working |
| `snapchat.txt` | Snap Inc. (Snapchat, Bitmoji, Snap Ads, Snap Kit) |
| `musk-tech-with-x.txt` | SpaceX (incl. Starlink), xAI (incl. Grok), X/Twitter and Tesla |
| `musk-tech.txt` | SpaceX, xAI and Tesla, but leaves X/Twitter fully working |

## Format

All rules use the AdGuard Adblock-style DNS syntax:

```
||example.com^
```

This blocks `example.com` **and all its subdomains**. It parses in every
AdGuard product: AdGuard Home, Private AdGuard DNS, AdGuard for
Windows/Mac/Android/iOS and the browser extensions (as a network filter).

Deliberately, no modifiers are used (no `$all`, `_all`, `$important`, …) — per
[AdGuard's DNS filtering rules](https://adguard-dns.io/kb/general/dns-filtering-syntax/),
DNS-level products **ignore any rule containing an unknown modifier**, so
plain `||domain^` is the only form guaranteed to work everywhere.

## Installation

- **AdGuard Home**: *Filters → DNS blocklists → Add blocklist*, point it at the
  raw file URL once the list is hosted (e.g. GitHub raw link to `meta.txt`).
- **AdGuard DNS (Private)**: *Settings → Custom lists → Add custom rule*.
- **AdGuard apps/extension**: *Settings → Filters → Custom → Add filter*.

To keep a single domain available, add an exception such as
`@@||cdn.instagram-embed-needed.com^` to AdGuard's custom rules; basic block
rules never override exceptions.

## Design notes

- Domain sets are derived from AdGuard Home's built-in blocked-services
  definitions (`AdguardTeam/AdGuardHome`,
  `internal/filtering/servicelist.go`: facebook, instagram, whatsapp,
  snapchat, and "X (formerly Twitter)") cross-checked with
  `Sinfonietta/hostfiles` social-hosts, then verified via DNS (DoH) and RDAP.
  Typosquat, parked and regional ccTLD variants are deliberately excluded:
  these lists block the real services, not lookalike domains.
- Both "without" variants are maintained as separate files rather than paired
  exception rules, so subscribing to exactly one list is enough.
- GIPHY (giphy.com) is **excluded**: it was acquired by Shutterstock and no
  longer counts as a Meta service.

`research/` contains the extraction sources and verification script used to
build the domain sets (`verify.sh doh` checks registration, `verify.sh rdap`
checks registrant data; both require network access via `curl`).