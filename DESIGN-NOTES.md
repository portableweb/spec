# PortableWeb — Design Notes

**Status:** Non-normative. This is the decision log and seedbed for future
companion specifications (`STORAGE.md`, `SANDBOX.md`, the installed-lifecycle
spec). Nothing here is binding until it lands in a normative document, but
items marked **Decided** reflect settled design direction; items marked
**Candidate** are promising ideas awaiting a decision.

**Origin:** working sessions, 2026-07-24 (post-`-02` revision). Update this
file whenever a design discussion produces direction that has no normative
home yet.

---

## 1. Positioning: the verified gap (Decided)

Researched 2026-07-24 against the current landscape:

- **W3C MiniApp Packaging** — still a Working Draft; adoption concentrated
  in super-app platforms. Apps installed into a host platform; non-standard
  component models; no file-open lifecycle, no user-owned state.
- **Isolated Web Apps** — shipping in Chrome, but installable *only via
  enterprise admin policy* (ChromeOS; Windows from ~Chrome 150).
  Installation-first, signing-mandatory, centrally managed, Chromium-only.
- **webxdc (.xdc)** — closest living cousin: ZIP + HTML/JS, fully
  sandboxed, zero network, shared as chat attachments (Delta Chat; XMPP
  XEP-0491). But scoped to a chat container: state syncs via chat
  transport among chat members. An app *inside a chat*, not a document you
  keep. Treat as a potential ally/bridge target, not a rival.
- **WACZ** — succeeding in archival (Library of Congress-recognized), but
  preserves *recordings* for replay — a tape, not a runnable program.
- **TiddlyWiki** — 20+ years of proof that a single file which is both app
  and its own data is loved and kept. One application, not a format: no
  manifest, no sandbox, no viewer ecosystem.
- **HyperCard, Flash** — historical proof of demand for cherished
  interactive documents; both died of platform politics, not lack of
  demand (see ongoing Flashpoint/Ruffle preservation efforts).
- **"File over app" / local-first movement** — the cultural moment
  aligning with the format's ownership thesis.

**Conclusion:** the gap named by `-02` — direct-open, user-owned,
permission-labeled, *stateful* documents with an archival promise — is
empty. The existential risk is not a competitor; it is **viewer
distribution**. The zero-install web viewer is strategically load-bearing.

## 2. Adoption strategy (Decided direction)

**Canonical positioning sentence** (2026-07-25; reuse verbatim on every
public surface instead of improvising per-surface variants):

> People create documents in Word, spreadsheets in Excel, presentations
> in PowerPoint. Now anyone can create an application — by describing it
> to an AI in plain language. Those older categories have had their file
> formats for decades; applications created this way have none: nothing
> platform-independent, portable, immediately runnable, shareable like a
> document, and able to carry its user's data inside. PortableWeb
> (`.pweb`) is that format.

Short tagline variant: *Documents have `.docx`. Spreadsheets have
`.xlsx`. AI-created apps have `.pweb`.*

**For AI tools (the multiplier):**
- `pweb pack` must accept a *single HTML file* and synthesize a manifest —
  AI artifacts are usually one self-contained HTML document; wrapping must
  be one command.
- Ship an MCP server (`@portableweb/mcp`: pack, validate, unpack,
  inspect-manifest) so any MCP-capable agent is a pweb author.
- `AUTHORING.md` is the AI-facing spec (id/`userdata/` preservation on
  regeneration, manifest quick reference). Publish `llms.txt` on
  portableweb.org pointing at it.
- Pitch to AI vendors: "Export to .pweb" turns a hosted artifact
  (a liability) into a user-owned file.

**For people:**
- Double-click must just work; the no-viewer fallback is "drag it into
  portableweb.org/app". Nobody installs a viewer for the first file; they
  install it after the third.
- Market the permission label like nutrition facts: *"this file cannot
  phone home, spy, or change itself unless it says so on the label."*
- Lean into the heirloom category (albums, baby books, year-in-review
  gifts): zero competition, high emotional resonance, exercises embedded
  storage.

## 3. Storage: two fixed semantic stores (Decided direction)

Hybrid storage is the end-state, but as **two fixed semantic stores**, not
freeform named stores:

1. **Document data** (portable): the user's actual content. Lives in
   `userdata/` under the embedded model, or exports as `.pwebdata` under
   the external model. Travels with the file; is what strip-on-share
   strips; is what the user owns.
2. **Operational data** (never portable): tokens, credentials, caches,
   device-specific preferences. Always external, keyed to the runtime
   instance, never enters the file (secrets half is already MUST NOT in
   `-02`).

One-sentence rule for AI authors: *user content goes in document data;
secrets and caches go in operational data.*

Not "always embedded": embedded is the default for document-like content;
external remains correct for games/chatty tools (no atomic ZIP rewrite at
high frequency) and is the mandatory fallback for non-writable handles.

## 4. The three canonical exports (Decided direction)

The storage model determines what the file contains *by default*; the
viewer's export menu can always produce any combination:

| Export | From embedded model | From external model |
|---|---|---|
| **App only** ("pristine") | Strip `userdata/` | The file as-is |
| **App + my data** | The file as-is | Bake state into a snapshot bundle |
| **My data only** | Extract `userdata/` → `.pwebdata` | Export the store → `.pwebdata` |

"Extract the app from my journal" and "bake my save into the game file"
are the same mechanism in opposite directions. Every share flow is the
question: *which of these three do you want to hand over?* → Spec in
`STORAGE.md` as three canonical export operations, available regardless of
model.

## 5. Capability follows lifecycle; the background ladder (Decided direction)

Portable lifecycle stays inert-when-closed — that is the trust foundation
and the archival guarantee. App-like powers arrive only through the
installed lifecycle's explicit user action ("Add to my apps" — same mental
model as installing a PWA).

For installed bundles, grant the **least-powerful mechanism** that serves
each want, in rungs:

1. **Declarative occasions** — dates as data (manifest or schema-legible
   `userdata/` file), surfaced by the viewer or exported to the OS
   calendar as reminders. No code runs. Covers the anniversary album and
   most to-do reminders.
2. **Declarative background rules** — *"fetch this URL every N hours;
   notify if condition."* Data, not code: auditable, can't exfiltrate
   beyond its declaration, easy for AI to generate correctly, easy for a
   viewer to disclose honestly. Covers weather checkers and
   change-notifiers. (RSS-reader semantics, not daemon semantics.)
3. **Budgeted background tasks** — bundle JS run *by the viewer* in
   constrained windows (WorkManager/BGTaskScheduler-style). The viewer is
   the only real background process; bundles never become daemons.

Timeline: v0.4+/companion-spec territory. `-02` reserved the seams; no
re-architecting needed.

## 6. Instance identity: the binding ledger (Decided direction)

How grants/tokens survive file renames and moves without keying on paths
(worthless) or manifest `id` (shared by copies — prohibited by `-02`):

Each runtime-instance record stores:
- **A durable OS file reference** (load-bearing): security-scoped
  bookmarks (macOS/iOS), SAF persisted URIs (Android), file ID/inode+device
  elsewhere.
- **Content hash of the application region** (stable: the region is
  immutable).
- Package `id` + last-known path as hints only.

Resolution at open:
1. Durable reference resolves to this file → same instance (renames and
   same-volume moves invisible).
2. Reference mismatch, but hash+`id` match an instance whose original
   file still exists elsewhere → copy → **new instance**, nothing
   inherited.
3. Hash+`id` match an instance with a stale reference (cross-volume move,
   backup restore — indistinguishable from copy-then-delete) → default
   new instance, but offer user-mediated re-binding: *"This looks like
   your Field Journal. Reconnect its settings?"*

**Robustness principle:** only *re-obtainable* things (grants → re-prompt;
tokens → re-auth) are keyed to instance identity. Irreplaceable data
travels in or with the file (§3), so a lost binding is never catastrophic.

**Rejected:** writing an instance marker into the file — copies would
share identity (the exact bug), and silent mutation breaks hashes,
signatures, and archival integrity.

## 7. Installed lifecycle UX (Decided direction)

**Installation is registration, not transformation.** The viewer imports a
copy into its managed store and creates OS launch surfaces (icon,
shortcut). Opening:

1. **App icon / viewer launcher** → installed instance (primary; keeps
   background rules reliable regardless of where the file goes).
2. **Double-clicking the original file** → viewer recognizes it via the
   binding ledger (application-region hash + package `id`): same version →
   open the installed app; newer file → offer update; always a quiet
   "open as document instead" option.

**Uninstall** removes registrations, rules, tokens, and the managed copy
(offering a data export first) — the original file is untouched and fully
functional.

> **The file outlives the installation.** Uninstalling a native app takes
> your stuff with it; uninstalling a pweb app leaves you holding the
> document you always had. No other platform can say that.

## 8. Shim vs. custom API: the decision rules (Decided)

Restating "standard interface, viewer-controlled implementation" as
enforceable rules (2026-07-25):

1. **If a standard web API exists, it MUST be the only bundle-facing
   surface.** Passthrough vs. document-start shim is a per-platform
   implementation detail that MUST be behaviorally indistinguishable to
   the bundle, except for degradations disclosed via the runtime profile
   (iOS camera fps is the canonical example). Denial always uses the
   standard web error for that API — no novel error types.
2. **No `pweb.store`.** A custom storage API was an early design and was
   explicitly superseded: standard `localStorage`/IndexedDB backed by
   the viewer store is what makes stock HTML and AI artifacts valid
   bundles with zero porting.
3. **`pweb.*` is reserved for capabilities with no web equivalent** —
   today only `.pwebdata`/snapshot export triggering and runtime-profile
   reading (`viewer_info`); later possibly peers/COMMS. Feature-
   detectable; bundles MUST work when absent (Core-class injects
   nothing).
4. **Background work gets neither a shim nor a runtime API.** The web
   equivalent (Service Workers) is permanently refused; background wants
   are served declaratively (§5 ladder). If rung 3 ever ships, it is a
   manifest-declared entry point the viewer invokes — not a
   bundle-callable API.
5. **Shims are compatibility, never security.** Enforcement lives below
   the content layer (CSP + webRequest, partition isolation, permission
   handlers). No security property may depend on a shim surviving.
6. **Uniformity beats native convenience:** Electron/Android storage is
   shimmed even though the engine could own it, so `.pwebdata` export
   and the embedded `userdata/` round-trip behave identically on every
   platform.

Per-capability verdicts: storage = always shim; camera/mic/geo/
notifications/clipboard = standard API, passthrough where the platform
allows, shim where it forces (all three mobile-WebView notification and
clipboard paths are shims); network = enforcement layer, not a shim;
fullscreen/pointer-lock/gamepad/audio/canvas/WASM/workers = engine
passthrough; file import/export = standard pickers, viewer-mediated.

## 9. Web viewer: isolation tiers and the wildcard-subdomain target (Decided direction)

A web viewer is a sandbox built inside the browser's sandbox, where the
only real isolation unit is the origin. Three viable designs, in
increasing strength (2026-07-25):

1. **Opaque-origin sandboxed iframe + postMessage storage broker** (the
   originally parked architecture). `sandbox="allow-scripts"` gives
   browser-enforced viewer↔bundle isolation, but opaque origins get no
   persistent storage by design — localStorage/IDB are shimmed at
   document-start over postMessage to a broker in the viewer origin
   (namespaced by `event.source`, never payload-claimed identity;
   preload-map + write-behind for sync localStorage). Resource serving
   needs blob-map URL rewriting (SWs cannot control opaque-origin
   iframes). Works everywhere; weakest ergonomics.

2. **Dedicated sandbox origin + session service worker** (the current
   portableweb-viewer.github.io + portableweb-sandbox.github.io
   experiment). Viewer posts bundle bytes cross-origin; sandbox SW
   serves `/bundle/<sessionId>/*` from per-session UUID-named IDB with
   injected guards and CSP. Viewer↔bundle isolation is hard (true
   cross-origin). **Bundle↔bundle isolation is soft** — all bundles
   share one origin, so it rests on injected guards, which are shims,
   and shims are never security (§8.5).

3. **Wildcard subdomain per bundle — the target.**
   `<hash>.sandbox.portableweb.org`, where `<hash>` is a digest of the
   application region (deterministic → same bundle → same origin → its
   storage persists across opens). Every bundle gets a real origin, so
   the browser natively provides bundle↔bundle isolation, per-bundle
   persistent storage (no shim at all), and per-bundle permission
   prompts. This is the web-tier mirror of the -02 synthetic-origin
   requirement (caveat: origin derives from bundle identity, not
   viewer-assigned instance identity — copies share state on the web
   tier; acceptable, disclosable degradation).

**Wildcard mechanics (one-time setup, zero per-bundle administration):**
one DNS record (`*.sandbox.portableweb.org` CNAME) matches every label
at query time — nothing is ever registered per bundle; one stateless
static host serves the same portal+SW shell for any `Host:` header
(client JS reads `location.hostname`); the browser mints isolation by
name comparison alone (origin = scheme/host/port tuple). The server
never sees bundle content — bytes arrive via cross-origin postMessage
and live only in each user's browser, per origin.

**Three real to-dos:**
- Wildcard TLS for `*.sandbox.portableweb.org` (free Let's Encrypt
  DNS-01; Caddy automates). Cloudflare gotcha: free Universal SSL covers
  only one level (`*.portableweb.org`), not `*.sandbox.…` — terminate
  TLS yourself or pay for Advanced Certificate Manager.
- **Public Suffix List submission for `sandbox.portableweb.org`**
  (required, not optional): cookie scoping is laxer than origin scoping
  — without PSL, a hostile bundle can set `Domain=sandbox.…` cookies
  readable by every other bundle's subdomain. PSL entry makes each
  subdomain its own site (why github.io is listed). Free PR, takes
  weeks — submit early.
- A host that answers any subdomain (GitHub Pages cannot; a small
  Caddy/nginx box, Cloudflare Workers, or Cloud Run behind an LB with
  the wildcard cert can). Workload ≈ three static files.

**Limits no web design escapes** (all already handled by -02): storage
durability is best-effort (`navigator.storage.persist()` is a request)
→ `.pwebdata` export matters most on this tier; no embedded write-back
(File System Access is Chromium-only and revocable) → embedded-model
bundles run under the external fallback with export offered (-02 §7.6);
no file association outside installed-PWA Chromium. The web viewer is a
permanent partial-module viewer — Core + M-STORAGE with disclosed
reduced durability — which the conformance model embraces by design.

**Offline constraint (2026-07-25):** with the viewer installed as a PWA,
a *previously-opened* bundle opens offline reliably — its subdomain's SW
intercepts navigation before DNS or network are consulted. A *brand-new*
bundle cannot open offline on its subdomain: no DNS cache entry, no
cached portal, and — fundamentally — no service worker, since SW
registrations are origin-scoped with no wildcard and cannot be
pre-installed for unvisited origins. Not fixable; design around it:

- **Hybrid tiering:** online → per-bundle subdomain (tier 3), which also
  primes that origin for future offline opens; offline + new bundle →
  fall back to the shared sandbox origin (tier 2), whose SW is
  pre-installed once at viewer-install time via the existing
  `ensureSandboxSW` hidden-iframe pattern. Active tier disclosed via the
  runtime profile.
- **Storage must not split across tiers:** broker all web-tier storage
  to the viewer origin's per-bundle store regardless of execution tier —
  the §8.6 uniformity principle applied to the web. Subdomains then
  provide execution and permission isolation only; `.pwebdata` export,
  embedded-model round-trip, and tier switching stay uniform. (This
  gives up design 3's "no storage shim" elegance but keeps its two
  irreplaceable wins: browser-enforced execution isolation and
  per-bundle permission prompts.)

**Strategic note:** the zero-install web viewer is the answer to the
viewer-distribution problem (§1) — the format's real existential risk.
Design 2 stays the working experiment; design 3 is the destination that
turns the web viewer from a demo into a conforming viewer.

## 10. Candidates (raised, not yet decided)

- Manifest `installable` hint so AI authors can declare app-intent and
  viewers can offer installation proactively (installation itself remains
  a user action per `-02` §4.2).
- Occasions schema shape (own manifest key vs. schema-legible `userdata/`
  file vs. embedded iCalendar).
- Whether declarative background rules (rung 2) belong to a constrained
  *portable* extension or strictly to the installed lifecycle.
  Current lean: installed only — inert-when-closed is worth protecting
  absolutely.
- webxdc bridge/interop exploration (shared sandboxing philosophy;
  chat-distribution channel for .pweb or vice versa).
