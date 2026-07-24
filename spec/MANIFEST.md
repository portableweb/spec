<div align="center">

<img src="https://raw.githubusercontent.com/portableweb/.github/main/profile/flow.svg" alt="The PortableWeb loop: you ask an AI to build interactive web content, it is generated, you pack it as a single .pweb file, and it runs everywhere — phone, Mac, PC, or shared with a friend." width="100%" />

<br /><br />

</div>

# PortableWeb Manifest Schema

**Version:** 0.2 (Draft)
**Status:** Pre-release. Breaking changes may occur until v1.0.
**Date:** 2026-07-24
**Editor:** Omprakash Selvaraj
**Canonical URL:** [https://portableweb.org/spec/container/](https://zenodo.org/records/20618881)
**IETF Internet-Draft:** [draft-selvaraj-portableweb-format-02](https://datatracker.ietf.org/doc/draft-selvaraj-portableweb-format/)

---

*This document defines the manifest schema for the Portable Web Content Format (PortableWeb). For the container format, see `CONTAINER.md`.*

---

## 1. Overview

Every PortableWeb bundle contains a `manifest.json` file at its archive root.
The manifest is the bundle's metadata: it identifies the package, declares
its entry point, declares its storage model and requested capabilities, and
carries rights and authorship information.

Where a manifest field has an equivalent in the
[Web Application Manifest](https://www.w3.org/TR/appmanifest/), this
specification reuses the established semantics rather than inventing
incompatible ones. The manifest declares the bundle's *maximum capability
request*; declarations are inputs to viewer policy, never grants (§7).

This document defines the manifest schema for format version 0.2.

## 2. Format

The manifest **MUST** be a valid JSON document encoded as UTF-8 without a
byte order mark. The top-level value **MUST** be an object.

## 3. Required fields

| Field | Type | Description |
|---|---|---|
| `spec_version` | string | The PortableWeb format version this bundle targets. Format: `"MAJOR.MINOR"`. For bundles conforming to this document, the value is `"0.2"`. |
| `id` | string | The **package identifier**: a globally unique identifier in reverse-domain form (e.g. `"org.example.my-bundle"`). Lowercase, alphanumeric, dots, and hyphens only. Identifies the package and its update lineage. It is **not** a runtime origin, **not** a storage key on its own, and **not** proof of authorship (see §4.1). |
| `version` | string | The bundle's own version, following [Semantic Versioning 2.0](https://semver.org/) (e.g. `"1.0.0"`). |
| `title` | string | A human-readable title for the bundle (equivalent to Web Application Manifest `name`). Max 200 characters. |
| `entry` | string | The path within the bundle to the HTML file the viewer loads first. **MUST** end in `.html` or `.htm`. **MUST NOT** start with `/`. |

### 3.1 Identity semantics

The `id` field identifies the *package and its update lineage* only. Two
bundles with the same `id` are versions of the same package. Distinct
identity concepts are defined in the Internet-Draft §5:

- **Runtime instance identity** is assigned by the viewer, never declared
  in the manifest, and is the correct key for runtime origin, permission
  grants, and external storage. Viewers **MUST NOT** key security state on
  `id` alone — independent copies of a bundle would otherwise share state.
- **Publisher identity** is established through signing (companion
  `SIGNING` specification), never inferred from `id`.
- Identity **MUST NOT** be derived solely from filename or path; a copy
  imported into a viewer is a new runtime instance and does not inherit
  the original's grants or storage.

## 4. Recommended and optional fields

Fields marked (R) are recommended; the rest are optional.

| Field | Type | Description |
|---|---|---|
| `description` (R) | string | A short description of the bundle. Max 1000 characters. |
| `author` (R) | object | An object with `name` (required), `email` (optional), and `url` (optional). |
| `created` (R) | string | The creation date in ISO 8601 format (e.g. `"2026-07-24T00:00:00Z"`). |
| `icons` (R) | array | Icon declarations (§5). |
| `permissions` | object | Declared capabilities (§7). If omitted, all permissions default to their specified default values. |
| `storage` | object | Storage declaration (§6). If omitted, defaults to `{"model": "external"}`. |
| `rights` | object | Copyright and license information (§8). |
| `viewport` | object | Hints to the viewer for initial window sizing (§9). |
| `content_type` | string | A hint describing the nature of the content. Recommended values: `"game"`, `"presentation"`, `"book"`, `"simulation"`, `"tool"`, `"report"`, `"visualization"`, `"education"`. |
| `short_name` | string | A short form of the title for constrained UI surfaces (Web Application Manifest `short_name` semantics). Max 30 characters. |
| `lang` | string | Primary language of the manifest's human-readable fields, as a BCP 47 language tag. |
| `dir` | string | Base text direction for human-readable manifest fields: `"ltr"`, `"rtl"`, or `"auto"`. |
| `icon` | string | **Deprecated 0.1 form:** path to a single square icon. Viewers **MUST** still accept it; `icons` takes precedence when both are present. |

## 5. The `icons` array

Each element is an object with
[Web Application Manifest](https://www.w3.org/TR/appmanifest/) icon
semantics:

| Field | Type | Description |
|---|---|---|
| `src` | string | Package-relative path to the icon resource. **MUST** resolve within the package boundary. External URLs **MUST NOT** be used and **MUST** be rejected. |
| `sizes` | string | Space-separated dimensions (e.g. `"48x48 96x96"`), or `"any"` for scalable formats. |
| `type` | string | The icon's media type (e.g. `"image/png"`, `"image/svg+xml"`). |
| `purpose` | string | Icon purpose hint (e.g. `"any"`, `"maskable"`, `"monochrome"`). |

SVG icons **MUST NOT** contain script and **MUST NOT** reference external
resources; viewers **MUST** render icons in a context where neither is
possible.

## 6. The `storage` object

Declares where the bundle's mutable user state lives. Replaces the 0.1
`permissions.storage` string.

| Field | Type | Description |
|---|---|---|
| `model` | string | One of `"none"`, `"external"`, `"embedded"`. Default: `"external"`. |

- **`"none"`** — no persistent state. Storage APIs behave as denied or
  ephemeral per the companion `STORAGE` specification.
- **`"external"`** — state lives in the viewer's per-instance store,
  outside the bundle file; the file never changes. Right for games, live
  tools, and frequent small state changes. `.pwebdata` export is the
  portability mechanism. Keyed by runtime instance identity (§3.1), never
  by `id` alone.
- **`"embedded"`** — state is persisted into the bundle's own `userdata/`
  region (`CONTAINER.md` §7), so the document and its data travel
  together as one file. Right for document-like content: journals,
  notebooks, albums, decks. Writes are staged and committed atomically by
  the viewer; the archive is never rewritten per storage call.

Regardless of model, standard web storage APIs (`localStorage`,
IndexedDB) remain the interface presented to bundle content; the viewer
supplies the backing implementation.

**Degradation rule:** a viewer that supports storage but not the embedded
model **MUST NOT** refuse to open an embedded-model bundle — it **MUST**
fall back to external persistence for the session and **SHOULD** offer
export of an updated bundle. The same fallback applies whenever the
viewer holds a non-writable file handle (read-only media, sandboxed copy,
streamed source), regardless of viewer capability.

Hybrid declarations (named stores with per-store models) are reserved for
the companion `STORAGE` specification.

**Compatibility:** the 0.1 form `permissions.storage` with values
`"none"` / `"isolated"` remains accepted; `"isolated"` is equivalent to
`{"model": "external"}`. When both forms are present, the top-level
`storage` object wins.

## 7. The `permissions` object

Permissions are **declared upfront in the manifest, not requested at
runtime.** Any permission not declared is denied. A declaration is the
bundle's maximum capability request — an input to viewer and user policy,
never an automatic grant. Viewers **SHOULD** show the user which
permissions a bundle has declared when the bundle is first opened.

| Permission | Type | Default | Meaning |
|---|---|---|---|
| `internet.read` | boolean | `false` | Allow retrieval of external resources over the network: requests using safe methods (e.g. HTTP GET/HEAD) without request bodies. Archival bundles **SHOULD** keep this `false`. Origin allowlists are reserved for the companion runtime specification. |
| `internet.write` | boolean | `false` | Allow network requests that transmit data: unsafe methods, request bodies, WebSocket messages, uploads. Encompasses `internet.read`; bundles **SHOULD** declare both for clarity. |
| `network` | boolean | `false` | **Deprecated 0.1 form:** equivalent to declaring both `internet.read` and `internet.write`. Viewers **MUST** still accept it; the split keys take precedence when both forms are present. |
| `camera` | boolean or string | `false` | Allow `getUserMedia` video access. String value is the justification shown to the user. |
| `microphone` | boolean or string | `false` | Allow `getUserMedia` audio access. |
| `geolocation` | boolean or string | `false` | Allow the Geolocation API. |
| `clipboard_write` | boolean | `false` | Allow programmatic writes to the user clipboard. |
| `notifications` | boolean | `false` | Allow showing OS-level notifications while the bundle is open. |
| `fullscreen` | boolean | `true` | Allow the Fullscreen API. Default-on because of low risk. |
| `peers` | boolean | `false` | Allow inter-bundle communication via local channels. Defined in the companion COMMS specification. |
| `storage` | string | `"isolated"` | **Deprecated 0.1 form** of the storage declaration; see §6. |

The read/write split is a disclosure and enforcement tier, not an
exfiltration guarantee: any permitted outbound request — including a
safe-method request under `internet.read` — can carry data encoded in its
URL. Viewers **SHOULD** present `internet.read` to users as "this content
can access the internet."

### 7.1 Required and optional declarations

Every declaration is **optional** by default: if the capability is denied
or unimplemented, the bundle still opens and the capability fails with the
standard web-platform denial for that API (`NotAllowedError`, rejected
fetch, etc.) — no novel error types. Authors are expected to handle these
ordinary failure paths.

A bundle **MAY** mark a permission as **required** using object form:

```json
"permissions": {
  "camera": { "required": true, "justification": "Scans QR codes" }
}
```

The object form accepts `required` (boolean, default `false`) and
`justification` (string, shown to the user). A boolean or string
declaration is equivalent to object form with `required: false`.

Viewer behavior:

- If a **required** capability is unsupported or denied, the viewer
  **MUST NOT** run the bundle as if nothing were wrong: it **MUST**
  either refuse to open, or clearly warn the user before opening with the
  capability unavailable.
- An **unknown** permission key in optional form **MUST** be ignored (the
  bundle opens; the capability is denied). An unknown key marked
  `required: true` **MUST NOT** be silently ignored — it is handled as an
  unsupported required capability.
- A required marking never weakens deny-by-default: it changes what the
  viewer tells the user, not what the bundle is granted.

Future versions may define additional permission keys.

## 8. The `rights` object

| Field | Type | Description |
|---|---|---|
| `copyright` | string | Human-readable copyright notice (e.g. `"© 2026 Jane Doe"`). |
| `license` | string | An [SPDX license identifier](https://spdx.org/licenses/) (e.g. `"MIT"`, `"CC-BY-4.0"`, `"CC0-1.0"`, `"proprietary"`). |
| `license_url` | string | URL to the full license text. |
| `contact` | string | Contact for licensing inquiries. |

## 9. The `viewport` object

| Field | Type | Description |
|---|---|---|
| `preferred_width` | integer | Suggested initial window width in CSS pixels. |
| `preferred_height` | integer | Suggested initial window height in CSS pixels. |
| `resizable` | boolean | Whether the viewer window should be resizable. Default: `true`. |
| `min_width` | integer | Minimum window width in CSS pixels. |
| `min_height` | integer | Minimum window height in CSS pixels. |

These are hints, not requirements. Viewers may respect or override them
based on the user's environment.

## 10. Example: minimal valid manifest

```json
{
  "spec_version": "0.2",
  "id": "org.example.minimal",
  "version": "1.0.0",
  "title": "Minimal Example",
  "entry": "index.html"
}
```

## 11. Example: full manifest

```json
{
  "spec_version": "0.2",
  "id": "org.example.field-journal",
  "version": "2.0.0",
  "title": "Field Journal",
  "short_name": "Journal",
  "description": "A personal field journal with photos and notes.",
  "content_type": "tool",
  "lang": "en",
  "dir": "ltr",
  "author": {
    "name": "Jane Doe",
    "email": "jane@example.com",
    "url": "https://janedoe.example.com"
  },
  "created": "2026-07-24T00:00:00Z",
  "icons": [
    { "src": "assets/icon.svg", "sizes": "any", "type": "image/svg+xml" },
    { "src": "assets/icon-192.png", "sizes": "192x192", "type": "image/png" }
  ],
  "entry": "index.html",
  "storage": {
    "model": "embedded"
  },
  "permissions": {
    "camera": { "required": false, "justification": "Attach photos to entries" },
    "fullscreen": true
  },
  "rights": {
    "copyright": "© 2026 Jane Doe",
    "license": "CC-BY-4.0",
    "license_url": "https://creativecommons.org/licenses/by/4.0/"
  },
  "viewport": {
    "preferred_width": 1280,
    "preferred_height": 800,
    "resizable": true,
    "min_width": 800,
    "min_height": 600
  }
}
```

## 12. Validation

Viewers and tools **SHOULD** validate manifests against the schema before
opening a bundle. A versioned, formal JSON Schema document for this
manifest will be published at
`https://portableweb.org/spec/manifest.schema.json`, alongside reference
bundles, invalid test bundles, and a conformance test suite.

Viewers **SHOULD** ignore unknown top-level manifest fields, and
repackaging tools **SHOULD** preserve fields they do not understand.

## 13. Changelog

- **0.2** (2026-07-24) — Aligned with
  [draft-selvaraj-portableweb-format-02](https://datatracker.ietf.org/doc/draft-selvaraj-portableweb-format/).
  `spec_version` is now `"0.2"`. `id` redefined as the package identifier
  with explicit identity/copy semantics (§3.1). Singular `icon`
  deprecated in favor of an `icons` array with Web Application Manifest
  semantics (§5). New optional `short_name`, `lang`, `dir`. New top-level
  `storage` object with `"none"` / `"external"` / `"embedded"` models,
  replacing `permissions.storage` (`"isolated"` remains a deprecated
  alias for external) with a normative degradation rule (§6).
  Permission declarations gain an object form with `required` and
  `justification`; required-vs-optional processing rules added (§7.1).
  The boolean `network` permission is split into `internet.read` /
  `internet.write` (reconciling the W3C CG draft's model; `network`
  remains a deprecated alias for both).
- **0.1** (2026-05-24) — Initial draft. Added `content_type` recommended field
  and `peers` permission; aligned with
  [draft-selvaraj-portableweb-format-01](https://www.ietf.org/archive/id/draft-selvaraj-portableweb-format-01.html).
