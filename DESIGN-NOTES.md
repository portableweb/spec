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

- **TODO (v0.2): document-data allowlist for the embedded model.**
  Mechanism for §3's two-store split. Under `storage.model: "embedded"`,
  only keys the manifest lists are document data and enter `userdata/`;
  everything else is operational data and stays external.

  ```json
  "storage": {
    "model": "embedded",
    "document": { "localStorage": ["notes", "issues.*"], "indexedDB": ["journal"] }
  }
  ```

  Replaces the earlier `private` key-marker idea (a denylist): a key the
  author forgets to list fails safe (not embedded, still persisted
  externally) instead of silently leaking a token into a shared file —
  consistent with default-deny. Open points for the spec text: pattern
  grammar (current lean: exact name or trailing-`*` prefix only, no
  globs); IndexedDB granularity (database vs. object store); whether an
  embedded bundle with no allowlist is valid (lean: yes, embeds nothing,
  viewer may say so on first open); ignore-vs-preserve for `userdata/`
  keys no longer allowlisted (reference viewer: ignored, dropped on next
  commit); fixture-pairing entries (grant path, unlisted key never in
  file, malformed allowlist tolerated). Lands in MANIFEST.md §6 + the
  companion STORAGE spec. `-02` is unpublished, so its storage section
  (models table, hybrid-declarations paragraph) can be rewritten to match
  rather than carrying compatibility shims. Reference implementation:
  `viewer` `packages/electron/src/embedded-store.ts` (localStorage and
  IndexedDB).

  *One storage mode (implemented in the reference viewer 2026-10-24;
  spec text not yet updated).* Drop `model`; the
  allowlist alone decides. Every bundle has both stores; an empty or
  absent list behaves like today's `external`, a non-empty list makes
  the file self-updating. Keep `"storage": "none"` as a shorthand for
  "persist nothing" (archival/kiosk). Reject a bare `"*"` (it would bring
  the token leak back). The first-open disclosure ("this document saves
  your entries inside itself") and the degradation rule then key off a
  non-empty list. Because `-02` is unpublished, no deprecated `model`
  mapping is needed.

  *Note: binary data (photos, video, user-uploaded files).*
  - `localStorage` is strings only; base64 works but costs ~33% and is
    preloaded/rewritten whole. Not the path for media.
  - The interface for binary is IndexedDB with `Blob`/`ArrayBuffer`
    values (built — see below). Allowlist granularity should reach
    object stores (`"journal/photos"`) so content and cache can share a
    database.
  - Embedded layout: each blob is its own entry,
    `userdata/blobs/<sha256>`, STORED (media is already compressed);
    `userdata/store.json` references blobs by hash. Content-addressed
    blobs are immutable, so most commits touch only `store.json`.
  - External layout: blobs as individual files beside the store
    document, never inlined into its JSON.
  - Large-data write strategy: whole-file atomic rewrite does not scale
    to GB-sized bundles. Promote append-with-compaction (new entries + a
    new central directory appended, periodic compaction to a clean copy)
    from MAY toward SHOULD above a size threshold; define crash-safety
    for the append path.
  - ZIP64: required for >4 GB archives or entries; CONTAINER.md must say
    whether viewers MUST support it (reference writer currently refuses).
  - Uploads: `<input type="file">` → `File` → IndexedDB is the standard
    path; reading user-picked files is `M-FILE-IMPORT` and must be gated
    by the manifest (Electron shows its picker independently of the
    permission handler).
  - Sharing: strip-on-share must show the user-data size; "send this
    travel journal" can mean gigabytes.

  *IndexedDB + blobs (implemented in the reference viewer 2026-10-25;
  spec text not yet written).* Decided by building it:
  - Granularity is the object store: `"indexedDB": ["journal/entries",
    "journal/*"]`. The database name must be literal (`"*"`, `"*/*"` and
    wildcard databases are rejected — the same token leak as a bare
    `"*"`), so content and caches can share a database.
  - No IndexedDB reimplementation: the bundle uses the platform's real
    IndexedDB (isolated per bundle); the viewer *observes* committed
    transactions on listed stores and *restores* them from the file before
    the bundle's `open` succeeds. The file is the source of truth for
    listed stores; schema (keyPath, autoIncrement, indexes) travels with
    the records and is recreated on a new machine.
  - Values are stored as tagged JSON (`{"$t": "date" | "blob" | "bytes" |
    "map" | "set" | …}`); Blobs become `{"$t": "blob", "sha256", "type",
    "size"}` with the bytes in `userdata/blobs/<sha256>` (the viewer
    re-hashes what the page sends; unreferenced blobs are dropped on
    commit). `.pwebdata` carries blobs as base64 under `blobs`.
  - Open: a transaction spanning listed and unlisted stores is split (only
    the listed part persists in the file) — spec should say whether that's
    acceptable or a validation warning; read-only files restore but keep no
    changes (localStorage falls back to viewer storage; IndexedDB doesn't
    yet); `<input type="file">` is not gated in the reference viewer —
    decide whether `M-FILE-IMPORT` needs a declaration or is always
    allowed (it is user-initiated, like a drop).
  - Demo: `portableweb-demos/photo-journal` (camera + microphone + blobs).

- **Network: optional site lists (`origins`) for `internet.read` /
  `internet.write`.** MANIFEST.md §7 and `-02` reserve origin allowlists
  for the runtime spec; the W3C CG draft (`internet.read` = "reads from
  declared domains") and `CLAUDE.md` §5/§10 assume them. Proposal, in the
  existing object form:

  ```json
  "permissions": {
    "internet.read":  { "justification": "Loads issues", "origins": ["https://api.github.com", "https://*.githubusercontent.com"] },
    "internet.write": { "justification": "Files issues", "origins": ["https://api.github.com"] }
  }
  ```

  - **Optional.** Absent ⇒ any http(s) site (today's meaning). Required
    lists would rule out legitimate "fetch the URL you type" bundles
    (readers, API explorers). A list lets the viewer enforce *and*
    disclose precisely ("Only: api.github.com") instead of "can access the
    internet".
  - **Grammar (CSP-like, so one list feeds both enforcement and CSP):**
    `https://host`, `https://*.host` (subdomains only, not the apex),
    explicit `:port`, scheme omitted ⇒ `https`. No paths, queries,
    credentials or other wildcards; a bare `"*"` is rejected (omit the
    list instead). `http` entries also match `https` on the same host
    (CSP semantics); `ws:`/`wss:` match as `http:`/`https:`.
  - **Bad entries fail closed:** invalid entries are dropped with a
    diagnostic; if none remain, no site is allowed (the author meant to
    restrict). The bundle still opens.
  - **write ⊇ read** holds per site: a site in the write list is readable
    even if absent from the read list; a write-without-list grant makes
    reads unrestricted too.
  - **Grants are scoped to the list.** The viewer stores what each grant
    covered; if a bundle (same `id`, e.g. an update) later declares a
    different list, the old grant is not in force and the user is asked
    again ("You allowed this before, but it now asks for different
    sites"). Prevents silent widening by updates.
  - Unchanged by a list: remote scripts and frames stay blocked under any
    grant (the bundle's code is the code in the file); CORS, mixed content
    and cookies follow the web engine.

  *Reference implementation (2026-10-25, experimental):* `viewer`
  `packages/core/src/origins.ts` (grammar, matching), `network.ts`
  (request check + CSP), `permissions.ts` (prompt text, scope re-ask);
  Electron prompt, Pack window "Only these sites", Validate output.

  Open points: (a) ~~ask `internet.write` per use or once on open~~ —
  settled 2026-10-25: once on open (see the next entry); (b) ~~CORS
  bypass~~ — decided 2026-10-25 (Oms): **sites in an explicit, granted
  `origins` list are CORS-allowed** for that bundle, like a native app;
  "any site" grants keep browser CORS, so a bundle can't use the viewer to
  read servers that rely on CORS to stay unreadable (intranet,
  localhost). Needed by real services that expect non-browser clients —
  e.g. GitHub's OAuth device-flow endpoints send no CORS headers.
  Reference: core `isCorsRelaxed` / `relaxedCorsHeaders`; Electron sets
  `Access-Control-Allow-Origin: <bundle origin>` on those responses and
  turns a non-2xx preflight into 204. A listed site also becomes readable
  with the user's cookies for that site in the bundle's own partition
  (not the user's browser cookies); (c) re-ask on any list change vs. only
  on widening (implemented: any change — simpler, rare); (d) IP literals
  and `localhost` in published bundles; (e) lands in MANIFEST.md §7 and
  the I-D's permissions section, or the companion runtime spec as the
  current text says.

- **When permissions are asked: on open (current) vs. first use.**
  *Direction (Oms, 2026-10-25):* once a `.pweb` is open it is on its own
  — no viewer interface in between. So all permission questions happen
  **before** the bundle runs, on open; the bundle's window is the
  bundle's alone afterwards. Implemented that way in the reference
  viewer (one prompt on first open; again only for newly declared
  capabilities or a changed site list; changes via the viewer's menu).

  *Candidate, not adopted — first-use prompting (Android/browser style).*
  The viewer would hold the first request to a declared capability (the
  first fetch to a listed site, the first `getUserMedia`) and prompt
  then, once per capability, covering the whole declared site list.
  Technically feasible: Electron's `onBeforeRequest` and permission
  handlers can defer their answer, so the page's `fetch`/promise simply
  waits; the CSP would carry the *declared* ceiling and the request hook
  the user's decision. Parallel requests queue behind one prompt; a
  caller's own timeout may fire while it is up. Android's
  `shouldInterceptRequest` can block similarly; iOS cannot intercept
  http(s) in WKWebView, so it would need JS wrappers for
  fetch/XHR/WebSocket, with images/media blocked until granted. Pros:
  in-context asks, bundles that never use a capability never prompt, one
  model for internet/camera/location. Rejected for now because it puts
  viewer UI on top of a running bundle.

  Consequences of the on-open direction to keep in view:
  - Camera, microphone, geolocation, Bluetooth are also decided on open
    (grant ⇒ `getUserMedia` etc. resolve without a viewer prompt), not
    when first used. Browsers and OSes normally prompt at use; the
    disclosure on open has to carry the weight.
  - After a deny, nothing in the window tells the user why something
    fails (the bundle sees only standard failures). A viewer-drawn "off
    for this bundle · Change" bar was proposed and is likewise not
    adopted; the recovery path is the viewer's menu (Electron: Tools ▸
    Permissions for This Bundle). Authoring guidance (AUTHORING.md)
    should tell authors to handle network/capability failures with a
    visible message.

- **Viewer chrome: no menus on bundle windows; manage from Home.**
  *Candidate (Oms, 2026-10-25) — may or may not be done.* Extends "once
  open, a bundle is on its own": bundle windows carry no viewer menu (on
  Windows/Linux Electron draws the app menu inside every window today);
  everything bundle-related moves to the viewer's Home window.
  - Home: Open…, Pack Folder…, a **"Your bundles"** list (title, file,
    last opened) → Open · Permissions… · Export (app only / app + my
    data / my data only) · Validate · Unpack · Clear Viewer Data · Show
    in folder; **Manage a .pweb file…** for a file not seen yet; Clear
    All Viewer Data set apart.
  - Fits the storage model: grants and viewer data are per bundle, not
    per window, so bundles can be managed without being open.
  - Needs: a small index in the viewer store (title + last-known file per
    bundle; the store keeps only ids today) — file-needing actions ask to
    locate a moved file; on Windows a single-instance lock so launching
    PortableWeb again brings Home forward (also stops a second viewer
    launching per double-click).
  - Home layout (Oms, 2026-10-26; built in Electron the same day): three
    sections, each action with a line icon (inline SVG, no CDN).
    1. **Your .pweb files:** Open a .pweb file (the main action);
       Permissions; Clear your content from a file — removes only what
       the user created or saved in the bundle (`userdata/`), never the
       published app. It changes the file and can't be undone, so it
       confirms and offers to save a copy first; refused while the file
       is open, when it has no saved content, or when it's read-only.
    2. **For advanced users** — people creating .pweb content themselves
       or with AI tools: Pack, Unpack, Validate.
    3. **PortableWeb viewer** (viewer-specific, at the bottom like
       settings): Clear data for a bundle — the viewer store for one
       bundle (sign-ins, caches, settings, unlisted keys, permission
       answers); never travels with the file; the bundle is asked for
       permissions again on next open. Reset the viewer — the same for
       every bundle; .pweb files are never changed.
    Until the "Your bundles" list exists, per-bundle actions ask for a
    .pweb first.
  - Deferred for the list: a **Recent** list on Home (each row: icon or
    thumbnail, title, version, last opened, ⋯ menu with the per-bundle
    actions) replaces the pick-a-file step; row icon comes from the
    manifest `icon`, or a manifest `thumbnail` once that exists (open
    question in the project context).
  - macOS still has the global menu bar (not on the window): keep
    PortableWeb ▸ Quit, **Edit** (⌘C/⌘V/⌘Z only work through Edit-menu
    items — removing it breaks copy/paste in bundles), Window ▸ Show
    Home. DevTools/reload as shortcuts in development builds only.
  - Trade-off: recovering from a denied permission now always goes
    through Home (consistent with the on-open permission direction above).
  - **Per-bundle variant (Oms, 2026-10-25):** instead of (or before)
    changing the default, a bundle's manifest may ask a specific viewer
    not to show its menus on that bundle's windows — a viewer-specific
    custom field, ignored by every other viewer (unknown keys are
    tolerated, B4). Shape to decide; lean: a namespaced extension object
    keyed by the viewer's id so fields from different viewers can't
    collide, e.g.
    `"extensions": { "org.portableweb.viewer": { "menu": false } }`
    (a prefixed top-level key such as `"x-portableweb-viewer"` is the
    alternative). Always a *hint*: it can hide in-window menus, never the
    platform essentials (macOS menu bar with Quit/Edit, a way back to
    Home), and never affects permissions or sandboxing. Would live under
    the general `extensions` field (next entry).

- **One generic field for custom data: `extensions`.**
  *Candidate (Oms, 2026-10-25).* A single top-level manifest field under
  which every non-standard field goes, so organizations, tools and
  viewers can add their own data without colliding with each other or
  with future spec fields. Use cases: an organization classifying its
  bundles (`internal` / `external`, department, retention), a viewer's
  hints (the menu hint above), authoring tools recording what generated
  the bundle, catalogs/archives adding their own metadata.

  ```json
  "extensions": {
    "com.acme":               { "classification": "internal", "department": "finance" },
    "org.portableweb.viewer": { "menu": false },
    "ai.example.generator":   { "model": "…", "prompt_id": "…" }
  }
  ```

  Proposed rules:
  - Keys are **reverse-domain namespaces** of whoever defines the
    contents (same form as `id`), so two parties never collide; values
    are JSON objects whose contents the namespace owner defines.
  - The spec defines the container only, never keys inside it; future
    standard fields go at the top level, never in `extensions`. That is
    the guarantee a reserved home gives and unknown-field tolerance alone
    does not (a custom `menu` today could collide with a standard
    `menu` tomorrow).
  - Viewers **MUST** ignore namespaces they don't understand; tools
    **MUST** preserve the whole object when repackaging (today:
    MANIFEST.md §12 says SHOULD for both, `-02` says MUST ignore /
    SHOULD preserve — reconcile to MUST).
  - **Never security-relevant.** Nothing in `extensions` can grant a
    permission, relax the sandbox, or be trusted as a statement of fact:
    anyone can edit a manifest. An org's `"classification": "internal"`
    is a label, not an access control — until signing (planned ~v0.3)
    can attest who wrote it, and even then the policy is the org's, not
    the format's.
  - The published JSON Schema must allow `extensions` with arbitrary
    namespaced objects (and keep top-level tolerance for unknown fields,
    or deliberately tighten it — decide together).
  - Validate/Pack may *show* extensions (e.g. "com.acme:
    classification = internal") but never fail on them; a namespace
    that isn't reverse-domain form gets a warning.

  Open: field name (`extensions` vs `x` vs `meta`); whether to keep
  tolerating stray top-level unknown fields once `extensions` exists
  (lean: keep tolerating — never break old bundles — but recommend
  `extensions` for anything new); size guidance; whether well-known
  namespaces (e.g. a shared classification vocabulary) are ever
  registered somewhere.

- **Removing and restoring document data: both a stripped copy and an
  in-place wipe, always with a backup; plus `.pwebdata` import.**
  *Candidate (Oms, 2026-10-25) — settles the open question "does 'remove
  my content' mean a fresh stripped export or an in-place wipe?" as
  "both"; not built yet.*
  - **Stripped copy** (exists): File ▸ Export App Only — original untouched;
    for sharing a fresh copy (§4).
  - **In-place wipe**: Tools ▸ *Remove My Data from This File…* —
    confirmation lists what goes (the allowlisted keys, their size); the
    viewer **first saves the current document data as a `.pwebdata`**
    beside the file (automatic backup), then rewrites the file with an
    empty `userdata/` region (same atomic write path) and reloads the
    bundle's windows. Why guarded: for document-like bundles the data *is*
    the document, the rewrite has no undo, and a running bundle may not
    expect its data to vanish (reload avoids that).
  - **Import** (§4's opposite direction): File ▸ *Import My Data
    (.pwebdata)…* into the open bundle —
    1. validate the `.pwebdata`;
    2. `bundle_id` mismatch ⇒ warn, Cancel default ("This data is from
       *X*; you're importing into *Y*");
    3. only keys matching this bundle's `storage.document` list are
       imported; others are listed and skipped (an import can never put
       operational data — tokens — into the file);
    4. **replace** the current document data, after saving it as a
       `.pwebdata` backup (so a wrong import is undoable);
    5. atomic write + reload;
    6. read-only file ⇒ say so and offer Export App + My Data to a new
       `.pweb` instead of failing silently.
  - Together: *start over* = Remove (auto-backup); *undo* = Import the
    backup; *move my data into a fresh or newer copy of the app* = open the
    new `.pweb`, Import from the old one's export.
  - Open: merge vs. replace on import (lean: replace only — merge
    semantics are app-specific); backup naming/location (lean: beside the
    file, `<name> (data backup <date>).pwebdata`, falling back to a save
    dialog if that folder isn't writable); IndexedDB/blobs once document
    data can include them (same flows, larger backups); whether the
    viewer-only store gets an equivalent import (lean: no — operational
    data is re-obtainable by design).
  - Built first on Home (Electron, 2026-10-26) as *Clear your content
    from a file* (core `clearDocumentContent`): refused while the file is
    open in a window (instead of reloading it); read-only file ⇒ says so;
    the backup is offered, not automatic — *Save a Copy First…* writes a
    full `.pweb` copy (keeps IndexedDB blobs too, which a `.pwebdata`
    backup can't yet). Automatic `.pwebdata` backup is still the target.

- **Bundle detection: is this the bundle the viewer already knows?**
  *Candidate (Oms, 2026-10-26) — design note only, not decided.* The
  viewer keys everything it keeps (viewer store, grants, "don't ask again"
  sites) by manifest `id`. That breaks when a different file arrives with
  an `id` the viewer has seen:
  - two unrelated bundles share an `id` (AI tools and templates reuse
    `com.example.app`; a fork keeps its parent's `id`);
  - a hostile bundle copies a known `id` to inherit another bundle's
    sign-in tokens and permission answers — the serious case;
  - a copy of the same bundle (sent to a friend, duplicated to try
    something) should not share sign-ins or answers with the original
    (§6);
  - a new *version* of the same bundle should keep them.
  **Proposal (Oms):** the first time the viewer opens a bundle it writes
  a viewer-generated unique id into a custom manifest field (e.g.
  `"extensions": { "org.portableweb.viewer": { "instance": "<uuid>" } }`);
  later opens compare it to tell new from existing.
  Points to weigh before deciding:
  - §6 already looked at an instance marker written into the file and
    rejected it: every copy carries the same marker, so copies still look
    like the original (the bug it should fix), and a hostile bundle can
    copy the marker as easily as the `id`.
  - `manifest.json` is in the application region, which the viewer
    promises never to change (byte-for-byte copy, CONTAINER.md §7);
    editing it changes the app's content hash and would break signing
    (v0.3/v0.4) and archival checks. A marker would at least have to live
    in `userdata/`, and read-only files couldn't get one at all.
  - What §6 relies on instead, without touching the file: a durable OS
    file reference (bookmark / file ID) plus a **hash of the application
    region** next to the `id`. Same `id` + different hash = a different
    app or a new version → treat as new and ask (*"This says it's Field
    Journal, but it isn't the copy you used before. Use its own data, or
    reconnect yours?"*); same hash + different file reference = a copy →
    new instance (§6 step 2).
  - Telling a new version from an impostor needs something the impostor
    can't copy: signing (planned v0.3/v0.4). Until then, same `id` with a
    different hash should never inherit tokens silently.
  - Home "Your bundles" list (above) would show these per instance, not
    per `id`.
  - Open: whether any marker in `userdata/` is still useful as a hint
    (e.g. to link a moved file back faster) when the hash and OS reference
    are the real checks.

- **Frameless, transparent windows (desktop).** *Candidate (Oms,
  2026-10-25) — not built.* Lets content float on the desktop with no
  window chrome — photo books, albums, desk widgets (Oms built a similar
  floating coffee-cup timer before). Fits "once open, the bundle is on its
  own."
  - Manifest: window hints beside the existing ones (MANIFEST.md §9), e.g.
    `"viewport": { "preferred_width": 900, "preferred_height": 700,
    "frame": false, "transparent": true }`. Hints: a viewer that can't do
    it ignores them and opens a normal window.
  - Authoring: page background must be transparent (`html, body
    { background: transparent }`); draggable regions via
    `-webkit-app-region: drag`; the bundle should draw its own close/hide
    control. Platform close keys still work (⌘W/⌘Q, Alt+F4).
  - Electron: `frame: false`, `transparent: true`, transparent
    `backgroundColor`. Limits: clicks on see-through pixels still hit the
    window rectangle (click-through needs `setIgnoreMouseEvents` with
    forwarding); Windows can't edge-resize transparent windows (prefer a
    fixed size); Linux needs a compositor or shows black.
  - **Safety:** frameless + transparent can imitate system UI (fake login
    or alert). Treat it like a permission — "*Album* wants to appear
    without a window frame" in the on-open prompt; declined ⇒ normal
    window. Never always-on-top, never covering the whole screen.
  - Desktop only; on phones content is full-screen anyway (next entry).

- **Viewport hints on phones and tablets.** *Open — spec silent.*
  MANIFEST.md §9 calls the sizes window hints that viewers "may respect or
  override"; nothing defines what a mobile viewer does with them (and the
  Android/iOS shells don't have their WebView glue yet). There is no
  window on a phone: the bundle gets the screen. Proposed rules:
  - `preferred_width` / `preferred_height`: ignored on phones (the screen
    is the size). Tablets in a windowed/split mode: same as desktop.
  - `min_width` / `min_height` become the **layout floor**: if the screen
    is narrower than `min_width`, lay the page out at `min_width` CSS px
    and scale it down to fit (what `<meta name="viewport"
    content="width=…">` does on the web), rather than cropping or
    scrolling sideways; optionally tell the user "designed for a larger
    screen". No `min_width` ⇒ the bundle's own `<meta name="viewport">` and
    responsive CSS decide, exactly as on the web.
  - `resizable`: meaningless on phones; ignored.
  - A new optional **`orientation`** hint (`any` | `portrait` |
    `landscape`, as in the Web App Manifest) — a 1200 × 800 album could
    ask for landscape; viewers may lock or just suggest rotating.
  - Authoring guidance (AUTHORING.md): set `min_width` only when the
    layout truly can't go narrower — a desktop-sized `min_width` turns a
    responsive bundle into a shrunken one on phones (the GitHub Issues
    demo's `min_width: 900` would be scaled to ~40 % on a phone although
    its CSS stacks below 980 px; drop `min_width` or lower it for mobile).

- **Files the viewer can't write back to.** *Candidate (2026-10-26).*
  There is no "read-only .pweb" in the format; this is about the file on
  disk: locked in Finder, read-only permissions, a write-protected USB
  stick, a mounted `.dmg`, a read-only network share. A bundle with a
  document-data list (`storage.document`) can't save into such a file.
  Reference viewer today: localStorage document keys fall back to viewer
  storage for the session (the degradation rule); IndexedDB stores are
  restored from the file but changes are not kept — the file stays the
  source of truth, so the next open shows the file's state again. Options:
  - (a) Same fallback for IndexedDB: keep listed stores in viewer storage
    while the file is unwritable, and stop restoring them from the file
    until it becomes writable (then: which wins — the file or the viewer
    copy?).
  - (b) Say so on open, together with the permission prompt (fits "once
    open, nothing in between"): "This file can't be saved to — changes
    won't be kept in it. [Save a Copy…] [Open Anyway]". Save a Copy writes
    a writable copy and opens that.
  - Possibly both: (b) as the honest default, (a) so "Open Anyway" doesn't
    silently lose work.
  - Spec text: whether viewers MUST tell the user when document data
    can't be saved, and whether the degradation rule covers IndexedDB.

- **Nearby communication (`nearby`) — offline, device to device.**
  *Experimental; prototype in the reference viewer 2026-10-26; spec text
  not written.* Copies of a bundle on nearby computers find each other and
  exchange messages with no internet, router or server (Bluetooth LE first;
  other links later behind the same API). No web standard covers this
  (Web Bluetooth is central-only and device-oriented), so it is a custom,
  optional, permission-controlled API: `navigator.portableweb.nearby`
  (`host` / `discover` / `connect`; session events `peerrequest`,
  `peerconnected`, `peerdisconnected`, `message`; JSON messages ≤ 60 KB).
  Present only when granted — its presence is the feature check.
  Decided while building it:
  - **Host-based star** first: one host, joiners connect to it; the host
    relays at application level. Not Bluetooth Mesh. `maxPeers` is a
    request; the viewer caps it (7 now) and reports what it allows.
  - **BLE roles are internal**: the API never mentions central/peripheral;
    a transport contract (`NearbyTransport`: advertise, scan, connect,
    send chunks) hides them. The wire format (chunk header, bounded
    reassembly) is shared so all viewers interoperate.
  - **Consent**: "Connect with nearby devices" is asked on open like every
    capability. Each join then shows a 4-digit code on both screens,
    derived by the viewer from the connection's key exchange (ECDH P-256 →
    HKDF; AES-256-GCM per direction, replay-protected); the host accepts in
    the bundle's own UI. A bundle can't fake the code; nothing moves before
    the host accepts. No viewer dialog appears mid-use.
  - **Scope**: same bundle only — the advertised service UUID is derived
    from the bundle id (+ an optional service label), so the id itself is
    never broadcast. Peers get random per-session ids, never hardware
    addresses.
  - Open: cross-bundle sessions by declared service name (a teacher's
    deck ↔ students' quiz) and how the prompt discloses them; 3–5+ device
    limits per platform (to be measured); binary messages; reconnect;
    whether the code should be viewer-drawn instead of bundle-drawn; the
    manifest key name (`nearby` today); conformance class (an optional
    module, e.g. `M-NEARBY`).
  - Demo: `portableweb-demos/tic-tac-toe`.

- **`AUTHORING.md` — where it lives and what goes in it.** *Decided
  direction (Oms, 2026-10-25): a note for now; not drafted yet.*
  - **Home:** a new file in this repo (`portableweb/spec`), beside
    CONTAINER.md / MANIFEST.md. **Informative**, not normative. Not part of
    the IETF draft (which may reference it) or the W3C CG draft; the CG
    may later publish it as a non-normative note / authoring guide.
  - **Why it exists:** every other spec file says what a *viewer* does
    when a bundle opens; nothing says what whoever *creates or edits* a
    bundle should do — a developer, a packer, and above all an AI
    (`portableweb-storage-authoring-context.md` §4).
  - **Readers:** AI tools, via an `llms.txt` on portableweb.org pointing
    at it (§2); our tooling — Validate / Pack warnings, the CLI lint, the
    planned `@portableweb/mcp` server — implements its checks; people
    writing bundles by hand.
  - **Collected so far:**
    - keep `id` and `userdata/` when an AI regenerates/edits a bundle vs.
      new `id` for a new bundle (storage-authoring context §2);
    - the "living summary" convention (same doc §3);
    - storage: list document keys in `storage.document` (prefix like
      `doc.*`), never list tokens/credentials; authors declare keys — the
      viewer never detects them;
    - permissions: declare only what's used; prefer `origins` site lists;
      always give a `justification`; capability-declaration lint (same doc
      §5);
    - no CDNs — bundle libraries and fonts locally (they fail silently in
      the sandbox);
    - handle network/capability failures with a visible message (after a
      deny nothing else tells the user — on-open permission entry above);
    - viewport: set `min_width` only when the layout truly can't go
      narrower (phone entry above);
    - frameless windows: transparent background, `-webkit-app-region:
      drag`, own close control (frameless entry above);
    - schema-legible document vs. opaque program storage (open; same doc
      §7);
    - custom data goes under `extensions` with a reverse-domain namespace
      (extensions entry above).

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
