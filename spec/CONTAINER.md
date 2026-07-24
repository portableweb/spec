<div align="center">

<img src="https://raw.githubusercontent.com/portableweb/.github/main/profile/flow.svg" alt="The PortableWeb loop: you ask an AI to build interactive web content, it is generated, you pack it as a single .pweb file, and it runs everywhere — phone, Mac, PC, or shared with a friend." width="100%" />

<br /><br />

</div>

# Portable Web Content Format (PortableWeb) — Container Specification

**Version:** 0.2 (Draft)
**Status:** Pre-release. Breaking changes may occur until v1.0.
**Date:** 2026-07-24
**Editor:** Omprakash Selvaraj
**Canonical URL:** [https://portableweb.org/spec/container/](https://zenodo.org/records/20618881)
**IETF Internet-Draft:** [draft-selvaraj-portableweb-format-02](https://datatracker.ietf.org/doc/draft-selvaraj-portableweb-format/)

---

## 1. Overview

A **PortableWeb bundle** (`.pweb`) is a single file containing all the HTML, CSS,
JavaScript, and media needed to render an interactive experience, packaged in
a way that can be opened by any compatible viewer application on any platform,
entirely offline, without a web server and without requiring a server-hosted
Web origin.

PortableWeb treats interactive web content as a **portable, stateful,
user-owned document**: a bundle is opened directly as a file, may carry
mutable user state embedded within or alongside the file, and has
well-defined copy, share, and archival semantics. This *portable lifecycle*
is the format's primary model; an optional *installed lifecycle* is named
and reserved by the Internet-Draft and deferred to a companion
specification.

This document defines the **container format**: how the bytes inside a `.pweb`
file are organized, what files must exist, how the archive is validated, and
how a viewer identifies and processes the bundle. The manifest schema is
defined in `MANIFEST.md`. The runtime sandbox, permission enforcement, and
storage algorithms are defined in companion specifications.

A PortableWeb bundle is content-model agnostic — it may contain a
presentation, game, simulation, educational explainer, personal tool, or any
other interactive content built on web technologies.

## 2. Terminology

The key words **MUST**, **MUST NOT**, **SHOULD**, **SHOULD NOT**, and **MAY**
in this document are to be interpreted as described in RFC 2119.

- **Portable Web Content Format (PortableWeb)** — the file format defined by this specification. "PortableWeb" is the short form used throughout.
- **Bundle** — a single `.pweb` file conforming to this specification.
- **Viewer** — software that opens, renders, and sandboxes a bundle.
- **Manifest** — the `manifest.json` file at the root of a bundle archive.
- **Entry file** — the HTML file the viewer loads first, declared in the manifest.
- **Package boundary** — the set of files contained within a bundle. Resources outside this boundary are external resources.
- **Application region** — the immutable portion of a bundle: every entry except those under `userdata/` (§7).
- **User-data region** — the mutable portion of a bundle: entries under the reserved `userdata/` path (§7).

## 3. File extension and media type

- **File extension:** `.pweb`
- **Media type:** `application/vnd.portableweb+zip` ([IANA-registered](https://www.iana.org/assignments/media-types/application/vnd.portableweb+zip), 2026-07-21)
- **Magic bytes:** `50 4B 03 04` (PK\003\004) — the standard ZIP local file header signature.

The file extension, a declared media type, and the ZIP magic bytes are
**candidate-identification hints only** — the ZIP signature is shared by
every ZIP-based format. A viewer **MUST** validate a candidate file per
§4 and §8 before executing any content from it.

## 4. Container format

### 4.1 Outer container

A bundle **MUST** be a valid ZIP archive. The ISO/IEC 21320-1 Document Container
File profile is RECOMMENDED. Specifically:

- The archive **MUST NOT** be encrypted.
- The archive **MUST NOT** be split across multiple files.
- Entries **MUST** use compression method STORED (0) or DEFLATE (8). A
  viewer **MAY** reject archives using any other compression method.
- File and directory names inside the archive **MUST** use forward slashes
  (`/`) as path separators, encoded in UTF-8.

### 4.2 Validation rules

A viewer **MUST** reject a candidate bundle whose archive violates any of
the following:

- Entry names **MUST NOT** contain absolute paths (a leading `/`), drive
  letters, or backslash (`\`) path separators.
- Entry names **MUST NOT** contain `.` or `..` path components, in raw or
  percent-encoded form.
- The archive **MUST NOT** contain symbolic links or other entry types
  that resolve outside the package boundary.
- Entry names **MUST** be compared case-sensitively after Unicode
  Normalization Form C (NFC). The archive **MUST NOT** contain duplicate
  entries or entries whose names are equivalent after NFC normalization.

A viewer **MUST** enforce implementation-defined limits on total
uncompressed size, individual entry size, file count, path length, path
depth, and compression ratio, and **MUST** reject archives exceeding them.
Viewers **SHOULD** document their limits.

Resource paths are case-sensitive, package-relative paths. A viewer
**MUST NOT** serve any resource that resolves outside the package
boundary, and **MUST NOT** rely on platform filesystem behavior
(case-insensitive matching, symlink resolution, separator translation)
when resolving paths.

### 4.3 The `mimetype` entry

A bundle **MUST** contain a file named `mimetype` at the archive root with:

- **Contents:** the ASCII string `application/vnd.portableweb+zip` with no
  trailing newline or whitespace.
- **Position:** the *first* entry in the ZIP archive.
- **Compression:** STORED (method 0, uncompressed).
- **No extra fields** in the local file header.

This convention (borrowed from EPUB) allows a tool to identify a PortableWeb
bundle by reading the first ~80 bytes of the file, without unpacking the
archive.

### 4.4 The `manifest.json` entry

A bundle **MUST** contain a file named `manifest.json` at the archive root,
encoded as UTF-8 JSON without a byte order mark. The manifest schema is
defined in `MANIFEST.md`. At minimum, the manifest declares:

- The format version the bundle targets.
- The package identifier.
- The bundle version.
- A human-readable title.
- The entry HTML file path.
- Any declared permissions.

The manifest is processed by the viewer in a privileged context. Viewers
**SHOULD NOT** serve the manifest bytes to bundle content.

### 4.5 The entry file

A bundle **MUST** contain the file referenced by the manifest's `entry`
field. The entry file **MUST** have a `.html` or `.htm` extension and **MUST**
be valid HTML5.

The entry file is loaded by the viewer in a sandboxed context. All other
files in the bundle are addressable from the entry file using relative paths.

## 5. Recommended file layout

The following layout is **RECOMMENDED** but not required. Bundles MAY use
any layout consistent with §4.

```
example.pweb (zip)
├── mimetype                  (required, first, uncompressed)
├── manifest.json             (required, at root)
├── index.html                (required, entry file)
├── assets/                   (recommended: images, fonts, icons)
├── scripts/                  (recommended: JavaScript files)
├── styles/                   (recommended: CSS files)
├── media/                    (recommended: audio and video)
├── data/                     (recommended: JSON and static data)
└── userdata/                 (reserved: embedded user data, §7)
```

## 6. Reserved paths

The following paths at the archive root are reserved by this specification.
Bundles **MUST NOT** create files at these paths except as specified by
this document or an explicit PortableWeb sub-specification:

- `mimetype`
- `manifest.json`
- `META-INF/` (reserved for signature manifests and integrity data)
- `userdata/` (reserved for the mutable user-data region, §7)
- `.well-known/` (reserved for future use)

## 7. Package regions

A bundle is divided into two regions:

**The application region** is every entry except those under `userdata/`.
It contains the author-supplied application: the mimetype, manifest, entry
file, and all packaged resources. The application region is immutable
during rendering: viewers **MUST NOT** allow bundle content to modify it.

**The user-data region** is the set of entries under the reserved
`userdata/` path. It holds embedded mutable user state for bundles that
declare the embedded storage model (`MANIFEST.md` §6). Viewers write to
this region on behalf of the user through the mechanisms defined in the
companion `STORAGE` specification; bundle content never writes to the
archive directly.

Rules:

- A bundle that does not declare embedded storage **SHOULD NOT** contain a
  `userdata/` region; viewers **MUST NOT** create one for it.
- Publisher signatures (companion `SIGNING` specification) **MUST** cover
  the application region — including the manifest and its storage
  declaration — and **MUST NOT** cover the user-data region, so ordinary
  use does not invalidate the publisher's signature.
- Viewers **MUST NOT** rewrite the archive on every storage mutation.
  Updates to the user-data region are staged outside the file and
  committed with an atomic whole-file replacement (temp file + fsync +
  rename or platform equivalent).

## 8. Bundle identification and processing

A viewer **SHOULD** treat a file as a *candidate* PortableWeb bundle if any
of the following are true:

1. The file extension is `.pweb`.
2. The file's declared media type is `application/vnd.portableweb+zip`.
3. The first ZIP entry is a STORED file named `mimetype` containing exactly
   `application/vnd.portableweb+zip`.

Candidate identification is a routing hint only. A conforming viewer
processes a candidate in the following order, and later steps **MUST NOT**
begin until earlier steps succeed:

1. Identify the candidate file (above).
2. Validate the ZIP structure and enforce container limits (§4.1–§4.2).
3. Validate the `mimetype` entry (§4.3).
4. Parse and validate the manifest (`MANIFEST.md`).
5. Resolve lifecycle and runtime instance identity (Internet-Draft §4–§5).
6. Evaluate declared capabilities; refuse or warn on unsupported required
   capabilities (`MANIFEST.md` §7).
7. Establish the sandbox and runtime origin (companion `SANDBOX` spec).
8. Mount packaged resources for resolution within the package boundary.
9. Initialize storage per the storage declaration (`MANIFEST.md` §6).
10. Load the entry resource.

A validator implements steps 1–4 and reports results without executing
content. A viewer **MUST** reject any candidate that fails validation.

## 9. Versioning

The container format and manifest schema share a single format version.
This document describes format version **0.2**.

**Before v1.0**, the format is a draft: revisions **MAY** make breaking
corrections, and every breaking change **MUST** be listed in the
changelog. Viewers claiming support for format 0.2 **SHOULD** also accept
0.1 bundles.

**From v1.0 onward**, the format is append-only: new features are added in
new format versions, existing features are never removed, and a bundle
declaring `spec_version: "1.0"` **MUST** remain openable by any future
viewer that claims v1.0 support. This guarantee is the foundation of the
PortableWeb archival promise.

A viewer that does not support a bundle's declared `spec_version` **MUST
NOT** execute the bundle silently as if it did: it **MUST** either refuse
with a clear version-mismatch indication, or clearly warn the user before
attempting best-effort rendering.

## 10. Interoperability Considerations

PortableWeb bundles are ZIP-based containers with a manifest that identifies
the package structure, entry resource, declared capabilities, and packaged
resources. Interoperability depends on viewers interpreting the manifest
consistently, resolving resource paths consistently, and enforcing package
boundaries consistently.

Implementations **MUST** use UTF-8 for manifest data and resource
identifiers, and **MUST** treat resource paths as case-sensitive,
package-relative paths (§4.2).

PortableWeb bundles may contain common web resource formats including HTML,
CSS, JavaScript, JSON, images, fonts, audio, and video. Rendering behavior
may vary between web engines and viewer implementations, particularly for
optional web platform features, media codecs, and device APIs. Bundle
authors **SHOULD** use widely supported web standards and **SHOULD** declare
requested capabilities in the manifest. Viewers **SHOULD** ignore unknown
manifest fields that are not required for safe processing, and repackaging
tools **SHOULD** preserve them.

A conforming bundle **SHOULD** be interpretable using only the resources it
contains, unless the manifest and viewer policy explicitly allow external
network access.

## 11. Security Considerations

PortableWeb files may contain active web content including HTML, CSS,
JavaScript, WebAssembly, and other resources. Implementations **MUST** treat
PortableWeb files as untrusted content unless obtained from a verified
trusted source.

### Sandboxed execution

PortableWeb content is intended to be rendered by a viewer in a sandboxed
execution environment with no ambient access to the host application, local
files, device APIs, credentials, cookies, or other user data except where
explicitly granted. Viewers **SHOULD**:

- Isolate storage and execution per runtime instance.
- Restrict or mediate network access according to user or application policy.
- Prevent script access to the viewer's privileged interface.
- Apply the security model of the underlying web rendering engine.
- Prevent active content from escaping the sandbox through navigation, popups,
  downloads, same-origin confusion, or unrestricted access to host-provided APIs.
- Deny bundle content the ability to register Service Workers or any other
  mechanism that would outlive the open session in the portable lifecycle.

### Permission model

A manifest's declared capabilities are inputs to the viewer's security policy,
not security guarantees by themselves. Viewers **MUST** apply a deny-by-default
policy and allow only capabilities permitted by both the manifest and
viewer/user policy. A `required` marking on a permission (`MANIFEST.md` §7)
affects what the user is told, never what the bundle is granted.

### Identity and copy semantics

Bundles are freely copyable files. Viewers **MUST NOT** key security state
(permission grants, storage, credentials, registrations) on the manifest
`id` alone — independent copies, or a malicious bundle reusing another's
`id`, would then share security state. Runtime origin and storage keys
**MUST** incorporate viewer-assigned instance identity.

### Credentials and tokens

Credentials, OAuth tokens, API keys, and similar secrets **MUST NOT** be
embedded in a portable `.pweb` file, including its user-data region —
copying or sharing the file would ship the secrets with it. Tokens belong
in protected external viewer storage keyed to the runtime instance.

### Confidentiality and integrity

The container format itself provides no confidentiality, integrity, or
authentication. Where these properties are required, they **SHOULD** be
provided externally (e.g., HTTPS during transport, OS file protections, or
cryptographic signing). Cryptographic signing of bundles is defined in the
companion `SIGNING` specification; signature scope follows §7.

### ZIP container security

The validation rules of §4.2 are mandatory. In particular, implementations
**MUST** protect against:

- Decompression bombs and excessive memory or disk usage.
- Duplicate, ambiguous, or normalization-equivalent filenames.
- Absolute paths and path traversal sequences (`../`).
- Symbolic links and platform-specific path handling issues.
- Mismatches between ZIP metadata and actual content.

Implementations **MUST** impose limits on total uncompressed size, file
count, nesting depth, path length, compression ratio, and individual
resource size, and **MUST NOT** extract files outside an
application-controlled storage area.

### User data in shared files

A bundle with embedded storage carries its user's data inside the file.
Sharing flows **SHOULD** default to asking whether to include or strip the
user-data region, and viewers **SHOULD** make producing a stripped
("pristine") copy easy.

## 12. Out of scope (for v0.2)

The following are intentionally not specified in this document and will be
addressed in companion specifications:

- The manifest schema in full detail → `MANIFEST.md`
- The runtime sandbox, security model, and origin algorithm → `SANDBOX.md`
- Storage backend algorithms (staging, atomic commit, locking, crash
  recovery, quotas, export/import) → `STORAGE.md`
- The frozen subset of web platform features per spec version → `RUNTIME-PROFILE.md`
- The installed lifecycle (registration, background tasks, notifications,
  updates) → companion specification
- Cryptographic signing of bundles → `SIGNING.md`
- Inter-bundle communication → `COMMS.md`

## 13. License

This specification is licensed under
[Creative Commons Attribution 4.0 International (CC-BY-4.0)](https://creativecommons.org/licenses/by/4.0/).

Reference implementations and example bundles published in the PortableWeb
repositories are licensed under the MIT License unless otherwise stated.

## 14. Changelog

- **0.2** (2026-07-24) — Substantial architectural revision, aligned with
  draft-selvaraj-portableweb-format-02. Container validation raised to
  MUST-level (path prohibitions, NFC-normalized duplicate rejection,
  STORED/DEFLATE only, mandatory limits) — *breaking correction*.
  Reserved `userdata/` root path; defined immutable application region
  and mutable user-data region with signature scope. Extension, media
  type, and magic bytes downgraded to candidate-identification hints;
  added the ten-step normative processing model and conformance classes.
  Versioning rewritten: pre-1.0 breaking corrections permitted, archival
  promise applies from v1.0 — *breaking correction*. New security
  subsections: identity/copy semantics, credentials and tokens, user data
  in shared files.
- **0.1** (2026-05-24) — Initial draft. Defines container format, mimetype
  convention, manifest requirement, entry file requirement, and reserved paths.
