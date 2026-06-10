# PortableWeb Manifest Schema

**Version:** 0.1 (Draft)
**Status:** Pre-release. Breaking changes may occur until v1.0.
**Date:** 2026-05-24
**Editor:** Omprakash Selvaraj
**Canonical URL:** https://portableweb.org/spec/manifest/
**IETF Internet-Draft:** [draft-selvaraj-portableweb-format-01](https://www.ietf.org/archive/id/draft-selvaraj-portableweb-format-01.html)

---

*This document defines the manifest schema for the Portable Web Content Format (PortableWeb). For the container format, see `CONTAINER.md`.*

---

## 1. Overview

Every PortableWeb bundle contains a `manifest.json` file at its archive root.
The manifest is the bundle's metadata: it identifies the bundle, declares
its entry point, lists the permissions it requests, and carries rights and
authorship information.

This document defines the manifest schema for container format v0.1.

## 2. Format

The manifest **MUST** be a valid JSON document encoded as UTF-8 without a
byte order mark. The top-level value **MUST** be an object.

## 3. Required fields

| Field | Type | Description |
|---|---|---|
| `spec_version` | string | The PortableWeb container spec version this bundle targets. Format: `"MAJOR.MINOR"`. For v0.1 bundles, the value is `"0.1"`. |
| `id` | string | A globally unique identifier for this bundle, in reverse-domain form (e.g. `"org.example.my-bundle"`). Lowercase, alphanumeric, dots, and hyphens only. |
| `version` | string | The bundle's own version, following [Semantic Versioning 2.0](https://semver.org/) (e.g. `"1.0.0"`). |
| `title` | string | A human-readable title for the bundle. Max 200 characters. |
| `entry` | string | The path within the bundle to the HTML file the viewer loads first. **MUST** end in `.html` or `.htm`. **MUST NOT** start with `/`. |

## 4. Recommended fields

| Field | Type | Description |
|---|---|---|
| `description` | string | A short description of the bundle. Max 1000 characters. |
| `author` | object | An object with `name` (required), `email` (optional), and `url` (optional). |
| `created` | string | The creation date in ISO 8601 format (e.g. `"2026-05-24T00:00:00Z"`). |
| `icon` | string | Path within the bundle to a square icon (SVG or PNG recommended). Used by viewers in window titles and file listings. |
| `permissions` | object | Declared capabilities (see §5). If omitted, all permissions default to their specified default values. |
| `rights` | object | Copyright and license information (see §6). |
| `viewport` | object | Hints to the viewer for initial window sizing (see §7). |
| `content_type` | string | A hint describing the nature of the content. Recommended values: `"game"`, `"presentation"`, `"book"`, `"simulation"`, `"tool"`, `"report"`, `"visualization"`, `"education"`. |

## 5. The `permissions` object

Permissions are **declared upfront in the manifest, not requested at runtime.**
Any permission not declared here is denied. Viewers **SHOULD** show the user
which permissions a bundle has declared when the bundle is first opened.

| Permission | Type | Default | Meaning |
|---|---|---|---|
| `network` | boolean | `false` | Allow `fetch`/`XHR` to non-bundle URLs. Strongly discouraged in v0.1; archival bundles **SHOULD** keep this `false`. |
| `camera` | boolean or string | `false` | Allow `getUserMedia` video access. String value is the justification shown to the user. |
| `microphone` | boolean or string | `false` | Allow `getUserMedia` audio access. |
| `geolocation` | boolean or string | `false` | Allow the Geolocation API. |
| `clipboard_write` | boolean | `false` | Allow programmatic writes to the user clipboard. |
| `notifications` | boolean | `false` | Allow showing OS-level notifications while the bundle is open. |
| `fullscreen` | boolean | `true` | Allow the Fullscreen API. Default-on because of low risk. |
| `storage` | string | `"isolated"` | Storage mode. Allowed values: `"none"` (no persistent storage), `"isolated"` (scoped `localStorage`/IndexedDB, isolated per bundle). |
| `peers` | boolean | `false` | Allow inter-bundle communication via local channels. Defined in the companion COMMS specification. |

Future versions of this specification may define additional permission keys.
Viewers **MUST** ignore unknown permission keys when the bundle targets a spec
version the viewer supports.

## 6. The `rights` object

| Field | Type | Description |
|---|---|---|
| `copyright` | string | Human-readable copyright notice (e.g. `"© 2026 Jane Doe"`). |
| `license` | string | An [SPDX license identifier](https://spdx.org/licenses/) (e.g. `"MIT"`, `"CC-BY-4.0"`, `"CC0-1.0"`, `"proprietary"`). |
| `license_url` | string | URL to the full license text. |
| `contact` | string | Contact for licensing inquiries. |

## 7. The `viewport` object

| Field | Type | Description |
|---|---|---|
| `preferred_width` | integer | Suggested initial window width in CSS pixels. |
| `preferred_height` | integer | Suggested initial window height in CSS pixels. |
| `resizable` | boolean | Whether the viewer window should be resizable. Default: `true`. |
| `min_width` | integer | Minimum window width in CSS pixels. |
| `min_height` | integer | Minimum window height in CSS pixels. |

These are hints, not requirements. Viewers may respect or override them
based on the user's environment.

## 8. Example: minimal valid manifest

```json
{
  "spec_version": "0.1",
  "id": "org.example.minimal",
  "version": "1.0.0",
  "title": "Minimal Example",
  "entry": "index.html"
}
```

## 9. Example: full manifest

```json
{
  "spec_version": "0.1",
  "id": "org.example.solar-system",
  "version": "1.2.0",
  "title": "Interactive Solar System",
  "description": "Explore planet orbits and relative scales of our solar system.",
  "content_type": "simulation",
  "author": {
    "name": "Jane Doe",
    "email": "jane@example.com",
    "url": "https://janedoe.example.com"
  },
  "created": "2026-05-24T00:00:00Z",
  "icon": "assets/icon.svg",
  "entry": "index.html",
  "permissions": {
    "network": false,
    "camera": false,
    "microphone": false,
    "storage": "isolated",
    "fullscreen": true,
    "peers": false
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

## 10. Validation

Viewers and tools **SHOULD** validate manifests against the schema before
opening a bundle. A formal JSON Schema document for this manifest will be
published at `https://portableweb.org/spec/manifest.schema.json`.

## 11. Changelog

- **0.1** (2026-05-24) — Initial draft. Added `content_type` recommended field
  and `peers` permission; aligned with
  [draft-selvaraj-portableweb-format-01](https://www.ietf.org/archive/id/draft-selvaraj-portableweb-format-01.html).
