---
title: "Portable Web Content Format (PortableWeb): Container and Manifest Specification"
abbrev: "portableweb-format"
docname: draft-selvaraj-portableweb-format-02
category: info
submissiontype: IETF
ipr: trust200902
area: Applications and Real-Time
workgroup: Independent Submission
keyword:
  - portable web content format
  - portableweb
  - pweb
  - portable
  - web content
  - offline
  - bundle
  - interactive
  - user-owned
  - stateful document

stand_alone: yes
smart_quotes: no
pi:
  toc: yes
  sortrefs: yes
  symrefs: yes

author:
  - name: Omprakash Selvaraj
    email: maintainer@portableweb.org
    uri: https://portableweb.org

normative:
  RFC2119:
  RFC8174:
  RFC8259:
    title: The JavaScript Object Notation (JSON) Data Interchange Format
    author:
      - ins: T. Bray
    date: 2017-12
  ISO21320:
    title: "ISO/IEC 21320-1: Document Container File — Part 1: Core"
    target: https://www.iso.org/standard/60101.html
    date: 2015
  UAX15:
    title: "Unicode Standard Annex #15: Unicode Normalization Forms"
    target: https://www.unicode.org/reports/tr15/
  BCP47:
    title: Tags for Identifying Languages
    target: https://www.rfc-editor.org/info/bcp47

informative:
  RFC6838:
    title: Media Type Specifications and Registration Procedures
    author:
      - ins: N. Freed
      - ins: J. Klensin
      - ins: T. Hansen
    date: 2013-01
  EPUB3:
    title: EPUB 3.3
    target: https://www.w3.org/TR/epub-33/
    date: 2023
  MINIAPP:
    title: MiniApp Packaging
    target: https://www.w3.org/TR/miniapp-packaging/
    date: 2023
  SEMVER:
    title: Semantic Versioning 2.0.0
    target: https://semver.org/
    date: 2013
  SPDX:
    title: SPDX License List
    target: https://spdx.org/licenses/
  ZIP:
    title: APPNOTE.TXT — .ZIP File Format Specification
    target: https://pkware.cachefly.net/webdocs/casestudies/APPNOTE.TXT
  WASM:
    title: WebAssembly Core Specification
    target: https://www.w3.org/TR/wasm-core-2/
    date: 2022
  WAM:
    title: Web Application Manifest
    target: https://www.w3.org/TR/appmanifest/
    date: 2023
  WEBBUNDLES:
    title: Web Bundles
    target: https://wpack-wg.github.io/bundled-responses/draft-ietf-wpack-bundled-responses.html
  IWA:
    title: Isolated Web Apps Explainer
    target: https://github.com/WICG/isolated-web-apps/blob/main/README.md

--- abstract

This document defines the Portable Web Content Format (PortableWeb),
a file format for packaging
interactive web content — including HTML, CSS, JavaScript, and associated
media — into a single self-contained, portable bundle. A PortableWeb bundle
(`.pweb` file) can be saved, copied, shared, and rendered by a compatible
viewer application on any platform, entirely offline, without a web server
and without requiring a server-hosted Web origin.

PortableWeb defines a portable-document lifecycle for interactive web
content: a bundle is opened directly as a user-owned file, may carry
mutable user state embedded within or alongside the file, and supports
copy, move, rename, save-as, export, and archival semantics. An optional
installed-application lifecycle is named and reserved for definition in a
companion specification.

This specification defines the container format and manifest schema for
PortableWeb bundles at format version 0.2. Companion specifications
covering the runtime sandbox, storage algorithms, signing, and
inter-bundle communication are forthcoming.

--- middle

# Introduction

AI-assisted tools have changed who creates interactive web content.
Applications — presentations, educational simulations, small games, data
visualizations, personal tools, and scientific models — that previously
required professional software development are now routinely created by
people who are not developers, by describing the desired application in
natural language. Interactive applications have thereby become a category
of user-created document, comparable to word-processing documents,
spreadsheets, and slide decks. Unlike those categories, however,
interactive web applications have no native file format: no
platform-independent, self-contained, immediately runnable unit that can
be saved, shared, and kept — together with its user's data — independent
of hosting infrastructure, accounts, and toolchains.

Several existing technologies package or describe web content (see
Section 3), and some — notably EPUB {{EPUB3}} and W3C MiniApp Packaging
{{MINIAPP}} — already define ZIP-based containers with manifests. What no
existing technology standardizes is the treatment of an interactive web
artifact as a **portable, stateful, user-owned document**:

- Opening an interactive web artifact directly as a file, the way a PDF
  or word-processing document is opened, without installation and without
  a hosting platform.

- Saving mutable user state back into, or alongside, that file, so that
  the document and its data travel together.

- Well-defined copy, rename, move, save-as, export, and archival
  semantics for both the content and its state.

- A portable-document lifecycle as the primary model, with installation
  as an optional, explicitly user-mediated secondary lifecycle.

- Content built on standard HTML, CSS, and JavaScript, portable across
  independent viewer implementations, without dependence on a particular
  vendor platform.

The Portable Web Content Format (PortableWeb) addresses this gap.
A `.pweb` bundle is a single file
that contains all the HTML, CSS, JavaScript, and media required to render an
interactive experience. It can be opened by a compatible viewer application
on any platform — desktop, mobile, or otherwise — entirely offline, without
deployment infrastructure, without requiring a server-hosted Web origin, and
without being confined to a web browser. The content inside is built
entirely on standard web technologies, keeping the format firmly within the
web platform ecosystem.

The format is content-model agnostic. A PortableWeb bundle may contain a
book, a game, an interactive presentation, an educational simulation, a 3D
experience, a scientific model, a personal tool, or any other interactive
content built on web technologies. The format imposes no constraints on the
content model.

## Design Goals

The PortableWeb format is designed to:

- Be openable by any compatible viewer on any platform, entirely offline.
- Behave like a document: saveable, copyable, shareable, and archivable.
- Allow user state to travel with the document, under the user's control,
  including the ability to inspect, export, strip, or reset that state.
- Support any interactive content built on standard web technologies.
- Operate without requiring a server-hosted Web origin and without being
  confined to a web browser.
- Declare capabilities and permissions upfront in a structured manifest,
  with deny-by-default enforcement.
- Provide a stable, versioned format with a long-term archival guarantee
  from version 1.0 onward.
- Be identifiable without unpacking (via magic bytes and a mimetype entry).
- Remain simple enough that a conforming implementation can be built
  quickly.

## Scope of This Document

This document defines:

1. The lifecycle profiles of a bundle: portable and installed (Section 4).
2. The identity model: package, document, and runtime instance identity
   (Section 5).
3. The container format: how a `.pweb` file is structured as a ZIP
   archive, validated, and processed (Section 6).
4. The manifest schema: the `manifest.json` file that every bundle must
   contain (Section 7).
5. Security considerations for implementations (Section 10).
6. IANA considerations for the `application/vnd.portableweb+zip` media
   type (Section 11).

The following are out of scope for this document and will be addressed in
companion specifications:

- The runtime sandbox and security model, including the synthetic-origin
  algorithm and packaged-resource URL scheme (`SANDBOX`,
  `RUNTIME-PROFILE`).
- Storage backend algorithms: staging, atomic commit, locking, crash
  recovery, quotas, autosave, and export/import (`STORAGE`).
- The installed-application lifecycle: registration, background tasks,
  notifications, and update mechanisms.
- Cryptographic signing of bundles (`SIGNING`).
- Inter-bundle communication via local channels such as Bluetooth and
  Wi-Fi Direct (`COMMS`).

# Terminology

The key words "MUST", "MUST NOT", "REQUIRED", "SHALL", "SHALL NOT",
"SHOULD", "SHOULD NOT", "RECOMMENDED", "NOT RECOMMENDED", "MAY", and
"OPTIONAL" in this document are to be interpreted as described in
BCP 14 {{RFC2119}} {{RFC8174}} when, and only when, they appear in all
capitals, as shown here.

The following terms are used throughout this document:

**Portable Web Content Format (PortableWeb):**
: The file format defined by this specification for packaging
  interactive web
  content into a single self-contained, portable bundle. "PortableWeb" is
  used as the short form throughout this document.

**Bundle:**
: A single `.pweb` file conforming to this specification.

**Viewer:**
: Software that opens, renders, and sandboxes a bundle.

**Manifest:**
: The `manifest.json` file at the root of a bundle archive.

**Entry file:**
: The HTML file the viewer loads first, declared in the manifest.

**Package boundary:**
: The set of files contained within a bundle. Resources outside this
  boundary are external resources.

**Application region:**
: The immutable portion of a bundle: every entry except those under the
  reserved `userdata/` path (Section 6.9).

**User-data region:**
: The mutable portion of a bundle: entries under the reserved `userdata/`
  path, used by bundles with embedded storage (Section 6.9).

**Package identifier:**
: The manifest `id` field, identifying the application or content package
  and its update lineage (Section 5).

**Runtime instance identifier:**
: A viewer-assigned identifier for one association between a viewer and a
  bundle file, used to key storage, permissions, and runtime origin
  (Section 5).

**Portable lifecycle:**
: The default lifecycle in which a bundle is opened directly as a
  document (Section 4.1).

**Installed lifecycle:**
: An optional lifecycle in which a bundle is explicitly installed by the
  user through a viewer (Section 4.2).

# Relationship to Existing Technologies

PortableWeb overlaps in mechanism with several existing technologies while
differing in purpose. This section positions the format relative to each;
none of the following statements are normative.

**EPUB** {{EPUB3}}:
: A ZIP-based packaged document format for reflowable publications.
  PortableWeb borrows EPUB's `mimetype` first-entry identification
  convention. EPUB's content model is a book — its scripting support is an
  enhancement to a reading experience, not a general-purpose runtime, and
  it defines no capability or permission model for interactive content.

**W3C MiniApp Packaging** {{MINIAPP}}:
: Defines a ZIP package, manifest, offline launch, and signature scheme
  for "mini apps" hosted inside super-app platforms. MiniApps are an
  application-distribution mechanism for a platform ecosystem: content is
  installed into and managed by a host platform, uses platform-specific
  (non-standard-web) component and API models, and has no concept of the
  package as a user-owned document carrying its own mutable state.
  PortableWeb differs on each of these points: standard HTML/CSS/JS
  content, direct file open with no platform registration, and
  document-style state and copy semantics.

**Web Application Manifest** {{WAM}}:
: Describes how an already-deployed, server-hosted web application
  presents itself when installed on a device. It is a descriptor for an
  origin-hosted experience, not a packaging format. PortableWeb reuses
  Web Application Manifest field semantics where practical (Section 7)
  rather than inventing incompatible metadata.

**Web Bundles** {{WEBBUNDLES}}:
: A network-transport packaging of HTTP exchanges. Designed as a
  transport optimization; never achieved broad implementation as a
  document format, and defines no manifest, permission, storage, or
  lifecycle model.

**Isolated Web Apps / Signed Web Bundles** {{IWA}}:
: A Chromium-led proposal that packages a web application in a signed Web
  Bundle and installs it with a stronger-than-web security posture. IWAs
  are applications — installation-first, update-managed, signed by
  publisher identity — not documents; there is no direct-open file
  lifecycle and no embedded user state.

**Hosted Progressive Web Apps:**
: Server-hosted applications with offline caching. The application lives
  at an origin and disappears when the origin does; there is no file the
  user owns.

**Native application packages** (APK, MSIX, dmg, etc.):
: Platform-specific application distribution with full OS integration and
  correspondingly heavyweight trust, signing, and store requirements.
  Not portable across platforms, and not documents.

**WebAssembly** {{WASM}}:
: A runtime technology, not a distribution format. WebAssembly modules
  may be used as resources within a PortableWeb bundle — alongside HTML,
  CSS, and JavaScript — where high-performance code execution is needed.
  WebAssembly defines no packaging structure, manifest, viewer model, or
  permission system; the relationship is complementary.

In summary: existing formats either package **applications for a platform**
(MiniApp, IWA, native packages), package **static or book-like documents**
(PDF, EPUB), or describe **server-hosted experiences** (Web Application
Manifest, PWAs, Web Bundles). PortableWeb packages **interactive web
content as a portable, stateful, user-owned document**, with installation
available as a secondary, optional lifecycle.

# Lifecycle Profiles

A PortableWeb bundle has exactly one format and one media type, but a
viewer may associate with a bundle in one of two lifecycle modes. The
portable lifecycle is the primary model and the format's chief
differentiator; the installed lifecycle is secondary and optional.

## The Portable Lifecycle

The portable lifecycle is the default. Every conforming viewer MUST
support it. In the portable lifecycle:

- A bundle is opened directly, like a document. Installation is not
  required and MUST NOT be a precondition for opening.

- A bundle MAY carry embedded mutable user data in its user-data region
  (Section 6.9) when it declares embedded storage (Section 7.6).

- Copying the bundle file produces an independent, fully usable copy.
  For a bundle with embedded storage, the copy carries its own copy of
  the embedded user data.

- Granted permissions and externally held viewer storage MUST NOT
  silently transfer to a copy of the file. A copy imported into a viewer
  is a new runtime instance (Section 5.2).

- Content receives no persistent background execution, no execution at
  system startup, and no remote push delivery. Dedicated Workers and
  Shared Workers MAY be available to content while a bundle is open;
  Service Workers are not part of the baseline profile. Detailed worker
  and API profiles are defined in the companion runtime specification.

- The user MUST be able to dispose of the association completely:
  deleting the file and any viewer-held state for it removes the content
  and its data.

- Viewers SHOULD offer state-hygiene operations on bundles with user
  state: exporting state, resetting state, and producing a stripped
  ("pristine") copy of a bundle without its user data. Sharing flows for
  bundles with embedded user data SHOULD default to asking whether to
  include or strip that data.

## The Installed Lifecycle (Reserved)

A viewer MAY additionally support an installed lifecycle, in which the
user explicitly registers a bundle with the viewer or host system. The
installed lifecycle is named and reserved by this document; its details
are deferred to a companion specification. The following constraints are
normative now:

- Installation MUST be an explicit user action mediated by the viewer.
  Installation MUST NOT occur merely because a manifest requests or
  suggests it.

- An installed bundle has a viewer-assigned, stable installation
  identity, distinct from the package identifier (Section 5).

- Capabilities that imply durable host integration — background tasks,
  notification registrations, credential storage, update mechanisms —
  are available only to installed bundles, only with explicit permission,
  and only where the platform supports them.

- Copies of the underlying file MUST NOT inherit an installation's
  registrations, credentials, or permissions.

# Identity Model

## Identity Concepts

Earlier revisions of this specification used the single manifest `id`
field for all identity purposes. Application identity, document identity,
and runtime identity are distinct concepts, and conflating them causes
concrete failures — most notably, independent copies of a bundle sharing
security and storage state. This revision distinguishes:

**Package identifier** (`id`, Section 7.3):
: Identifies the application or content package and its update lineage.
  Two bundles with the same `id` are versions of the same package.
  Declared by the author in the manifest.

**Document identity:**
: Identifies a logical user document — a particular journal, a particular
  save file — independent of which package version renders it. This
  document does not define a manifest field for document identity; a
  future revision or companion specification may.

**Runtime instance identifier:**
: Assigned by the viewer, never declared in the manifest. Identifies one
  association between a viewer and a bundle file, and is the correct key
  for runtime origin, permission grants, external storage, notifications,
  and background registrations.

**Publisher identity:**
: Established through cryptographic signing (companion `SIGNING`
  specification), never inferred from the package identifier. An
  unsigned `id` is a claim, not a proof.

## Identity and Copy Semantics

The following rules apply to conforming viewers:

- A viewer MUST NOT derive bundle identity solely from the file's name or
  filesystem path. Renaming or moving a file through viewer-mediated
  operations SHOULD preserve its runtime instance association.

- A viewer MUST NOT use the package identifier alone as the runtime
  origin or storage key, because independent copies of a bundle (or a
  malicious bundle reusing another's `id`) would then share security
  state. The runtime origin MUST incorporate viewer-assigned instance
  identity. The precise origin-derivation algorithm is defined in the
  companion runtime specification.

- Importing or opening a copy of a bundle creates a new runtime instance.
  The copy MUST NOT share permission grants, external viewer storage,
  credentials, or background registrations with the original.

- Guaranteed copy and move detection applies only to viewer-mediated
  operations. Arbitrary operating-system-level file copies cannot always
  be distinguished from moves; viewers SHOULD treat an ambiguous case as
  a new instance rather than silently attaching existing state to it.

# Container Format

## File Extension and Media Type

A PortableWeb bundle uses the following identifiers:

- **File extension:** `.pweb`
- **Media type:** `application/vnd.portableweb+zip`
- **Magic bytes:** `50 4B 03 04` (PK\\003\\004) — the standard ZIP local
  file header signature.

The file extension, a declared media type, and the ZIP magic bytes are
**candidate-identification hints only**. The ZIP local file header
signature is shared by every ZIP-based format and does not uniquely
identify a PortableWeb bundle. A viewer MUST validate a candidate file
per Section 6.10 and Section 6.11 before executing any content from it.

## Outer Container

A bundle MUST be a valid ZIP archive {{ZIP}}. The ISO/IEC 21320-1
Document Container File profile {{ISO21320}} is RECOMMENDED. Specifically:

- The archive MUST NOT be encrypted.
- The archive MUST NOT be split across multiple files.
- Entries MUST use compression method STORED (0) or DEFLATE (8). A
  viewer MAY reject archives using any other compression method.
- File and directory names inside the archive MUST use forward slashes
  (`/`) as path separators, encoded in UTF-8.

## Container Validation Rules

A viewer MUST reject a candidate bundle whose archive violates any of the
following rules:

- Entry names MUST NOT contain absolute paths (a leading `/`), drive
  letters, or backslash (`\\`) path separators.
- Entry names MUST NOT contain `.` or `..` path components, in raw or
  percent-encoded form.
- The archive MUST NOT contain symbolic links or other entry types that
  resolve outside the package boundary.
- Entry names MUST be compared case-sensitively after Unicode
  Normalization Form C (NFC) {{UAX15}}. The archive MUST NOT contain
  duplicate entries or entries whose names are equivalent after NFC
  normalization.

A viewer MUST enforce implementation-defined limits on total uncompressed
size, individual entry size, file count, path length, path depth, and
compression ratio, and MUST reject archives exceeding them. Viewers
SHOULD document their limits. These limits protect against decompression
bombs and resource exhaustion (Section 10.6).

Resource paths are case-sensitive, package-relative paths. A viewer MUST
NOT serve any resource that resolves outside the package boundary, and
MUST NOT rely on platform filesystem behavior (case-insensitive matching,
symlink resolution, separator translation) when resolving paths.

## The `mimetype` Entry

A bundle MUST contain a file named `mimetype` at the archive root with the
following properties:

- **Contents:** the ASCII string `application/vnd.portableweb+zip` with no
  trailing newline or whitespace.
- **Position:** the first entry in the ZIP archive.
- **Compression:** STORED (method 0, uncompressed).
- **No extra fields** in the local file header.

This convention, borrowed from EPUB {{EPUB3}}, allows a tool to identify a
PortableWeb bundle by reading the first approximately 80 bytes of the file
without unpacking the archive.

## The `manifest.json` Entry

A bundle MUST contain a file named `manifest.json` at the archive root,
encoded as UTF-8 JSON {{RFC8259}} without a byte order mark. The manifest
schema is defined in Section 7. At minimum, the manifest declares:

- The format version the bundle targets.
- The package identifier.
- The bundle version.
- A human-readable title.
- The path to the entry HTML file.
- Any declared permissions.

The manifest is processed by the viewer in a privileged context. Viewers
SHOULD NOT serve the manifest bytes to bundle content.

## The Entry File

A bundle MUST contain the file referenced by the manifest's `entry` field.
The entry file MUST have a `.html` or `.htm` extension and MUST be valid
HTML5. The entry file is loaded by the viewer in a sandboxed context. All
other files in the bundle are addressable from the entry file using
relative paths.

## Recommended File Layout

The following layout is RECOMMENDED but not required. Bundles MAY use any
layout consistent with this section.

~~~
example.pweb (zip)
├── mimetype                  (required, first, uncompressed)
├── manifest.json             (required, at root)
├── index.html                (required, entry file)
├── assets/                   (recommended: images, fonts, icons)
├── scripts/                  (recommended: JavaScript files)
├── styles/                   (recommended: CSS files)
├── media/                    (recommended: audio and video)
├── data/                     (recommended: JSON and static data)
└── userdata/                 (reserved: embedded user data, Section 6.9)
~~~

## Reserved Paths

The following paths at the archive root are reserved by this specification.
Bundles MUST NOT create files at these paths except as specified by this
document or an explicit PortableWeb sub-specification:

- `mimetype`
- `manifest.json`
- `META-INF/` (reserved for signature manifests and integrity data)
- `userdata/` (reserved for the mutable user-data region, Section 6.9)
- `.well-known/` (reserved for future use)

## Package Regions

A bundle is divided into two regions:

**The application region** consists of every entry except those under
`userdata/`. It contains the author-supplied application: the mimetype,
manifest, entry file, and all packaged resources. The application region
is immutable during rendering: viewers MUST NOT allow bundle content to
modify it, and tools that update it (e.g., an authoring tool releasing a
new version) are producing a new version of the package.

**The user-data region** consists of entries under the reserved
`userdata/` path. It holds embedded mutable user state for bundles that
declare embedded storage (Section 7.6). Viewers write to this region on
behalf of the user through the storage mechanisms defined in the
companion `STORAGE` specification; bundle content never writes to the
archive directly.

Rules:

- A bundle that does not declare embedded storage SHOULD NOT contain a
  `userdata/` region; viewers MUST NOT create one for it.
- Publisher signatures (companion `SIGNING` specification) MUST cover the
  application region — including the manifest and its storage
  declaration — and MUST NOT cover the user-data region, so that
  ordinary use does not invalidate the publisher's signature. The
  user-data region MAY carry a separate integrity mechanism.
- When signed application resources are updated (a new package version),
  the user-data region is carried forward unchanged unless the user
  requests otherwise. The merge algorithm is defined in the companion
  `STORAGE` specification.
- Viewers MUST NOT rewrite the archive on every storage mutation.
  Updates to the user-data region are staged outside the file and
  committed with an atomic whole-file replacement. Staging, locking,
  crash recovery, and autosave policy are defined in the companion
  `STORAGE` specification.

## Bundle Identification

A viewer SHOULD treat a file as a candidate PortableWeb bundle if any of
the following conditions are true:

1. The file extension is `.pweb`.
2. The file's declared media type is `application/vnd.portableweb+zip`.
3. The first ZIP entry is a STORED file named `mimetype` containing exactly
   `application/vnd.portableweb+zip`.

Candidate identification is a routing hint only. A viewer MUST validate
the container (Section 6.3), the `mimetype` entry (Section 6.4), and the
manifest (Section 7) before executing any content, and MUST reject any
candidate that fails validation.

## Processing Model

This specification defines conformance requirements for four classes of
implementation:

- **Packages** — `.pweb` files conforming to Sections 6 and 7.
- **Viewers** — software that opens, renders, and sandboxes packages.
- **Packagers and authoring tools** — software that produces packages.
- **Validators** — software that checks packages against this
  specification without rendering them.

A conforming viewer processes a candidate file in the following order.
Later steps MUST NOT begin until earlier steps succeed:

1. Identify the candidate file (Section 6.10).
2. Validate the ZIP structure and enforce container limits (Section 6.3).
3. Validate the `mimetype` entry (Section 6.4).
4. Parse and validate the manifest (Section 7).
5. Resolve lifecycle and runtime instance identity (Sections 4 and 5).
6. Evaluate declared capabilities; refuse or warn on unsupported
   required capabilities (Section 7.7).
7. Establish the sandbox and runtime origin (Section 8; companion
   `SANDBOX` specification).
8. Mount packaged resources for resolution within the package boundary.
9. Initialize storage per the storage declaration (Section 7.6).
10. Load the entry resource.

A validator implements steps 1–4 and reports results without executing
content.

## Versioning and Compatibility

The container format and manifest schema share a single format version.
This document describes format version **0.2**. Bundles declare the
format version they target in the manifest `spec_version` field
(Section 7.3).

**Before version 1.0**, the format is a draft: revisions MAY make
breaking corrections, and every breaking change MUST be listed in the
revision history of the defining document. Viewers claiming support for
format 0.2 SHOULD also accept 0.1 bundles; the 0.1-to-0.2 differences are
listed in this document's revision notes and are additive except where
noted.

**From version 1.0 onward**, the format is append-only: new features are
added in new format versions, existing features are never removed, and a
bundle declaring `spec_version: "1.0"` MUST remain openable by any future
viewer that claims v1.0 support. This guarantee is the foundation of the
PortableWeb archival promise.

Version handling rules for viewers:

- A viewer that does not support a bundle's declared `spec_version` MUST
  NOT execute the bundle silently as if it did. It MUST either refuse to
  open the bundle with a clear indication of the version mismatch, or
  clearly warn the user before attempting best-effort rendering.
- Unknown top-level manifest fields and unknown *optional* permission
  keys MUST be ignored (Section 7.7). Unknown permission keys marked
  *required* MUST NOT be ignored (Section 7.7).
- Tools that repackage or transform bundles SHOULD preserve manifest
  fields they do not understand.

# Manifest Schema

## Overview

Every PortableWeb bundle contains a `manifest.json` file at its archive
root. The manifest is the bundle's structured metadata: it identifies the
package, declares its entry point, declares its storage model and
requested capabilities, and carries rights and authorship information.

Where a manifest field has an equivalent in the Web Application Manifest
{{WAM}}, this specification reuses the established semantics rather than
inventing incompatible ones. The manifest declares the bundle's maximum
capability request; declarations are inputs to viewer policy, never
grants (Section 7.7).

## Format

The manifest MUST be a valid JSON document {{RFC8259}} encoded as UTF-8
without a byte order mark. The top-level value MUST be a JSON object.

## Required Fields

The following fields MUST be present in every conforming manifest:

| Field | Type | Description |
|---|---|---|
| `spec_version` | string | The PortableWeb format version this bundle targets. Format: `"MAJOR.MINOR"`. For bundles conforming to this document, the value MUST be `"0.2"`. |
| `id` | string | The package identifier (Section 5): a globally unique identifier in reverse-domain notation (e.g., `"org.example.my-bundle"`). MUST contain only lowercase alphanumeric characters, dots, and hyphens. Identifies the package and its update lineage; not a runtime origin and not proof of authorship. |
| `version` | string | The bundle's own version, following Semantic Versioning 2.0 {{SEMVER}} (e.g., `"1.0.0"`). |
| `title` | string | A human-readable title for the bundle (equivalent to Web Application Manifest `name`). MUST NOT exceed 200 characters. |
| `entry` | string | The path within the bundle to the HTML entry file. MUST end in `.html` or `.htm`. MUST NOT begin with `/`. |

## Recommended and Optional Fields

The following fields are OPTIONAL; those marked (R) are RECOMMENDED:

| Field | Type | Description |
|---|---|---|
| `description` (R) | string | A short description of the bundle. MUST NOT exceed 1000 characters. |
| `author` (R) | object | An object with `name` (required), `email` (optional), and `url` (optional). |
| `created` (R) | string | The creation date in ISO 8601 format (e.g., `"2026-07-24T00:00:00Z"`). |
| `icons` (R) | array | Icon declarations (Section 7.5). |
| `permissions` | object | Declared capabilities (Section 7.7). If omitted, all permissions default to their specified default values. |
| `storage` | object | Storage declaration (Section 7.6). If omitted, defaults to `{"model": "external"}`. |
| `rights` | object | Copyright and license information (Section 7.8). |
| `viewport` | object | Hints to the viewer for initial window sizing (Section 7.9). |
| `content_type` | string | A hint describing the nature of the content. RECOMMENDED values: `"game"`, `"presentation"`, `"book"`, `"simulation"`, `"tool"`, `"report"`, `"visualization"`, `"education"`. |
| `short_name` | string | A short form of the title for constrained UI surfaces (Web Application Manifest `short_name` semantics). MUST NOT exceed 30 characters. |
| `lang` | string | The primary language of the manifest's human-readable fields, as a {{BCP47}} language tag. |
| `dir` | string | Base text direction for human-readable manifest fields: `"ltr"`, `"rtl"`, or `"auto"`. |
| `icon` | string | Deprecated 0.1 form: path to a single square icon. Viewers MUST still accept it; `icons` takes precedence when both are present. |

## Icons

The `icons` field is an array of objects with Web Application Manifest
{{WAM}} icon semantics:

| Field | Type | Description |
|---|---|---|
| `src` | string | Package-relative path to the icon resource. MUST resolve within the package boundary. External URLs MUST NOT be used and MUST be rejected. |
| `sizes` | string | Space-separated icon dimensions (e.g., `"48x48 96x96"`), or `"any"` for scalable formats. |
| `type` | string | The icon resource's media type (e.g., `"image/png"`, `"image/svg+xml"`). |
| `purpose` | string | Icon purpose hint, per Web Application Manifest (e.g., `"any"`, `"maskable"`, `"monochrome"`). |

SVG icons MUST NOT contain script and MUST NOT reference external
resources; viewers MUST render icons in a context where neither is
possible.

## Storage Declaration

The `storage` object declares where the bundle's mutable user state
lives. It replaces the 0.1 `permissions.storage` string.

| Field | Type | Description |
|---|---|---|
| `model` | string | One of `"none"`, `"external"`, or `"embedded"`. Default: `"external"`. |

The models:

**`"none"`:**
: The bundle has no persistent state. Storage APIs behave as denied or
  ephemeral per the companion `STORAGE` specification.

**`"external"`:**
: State lives in the viewer's per-instance store, outside the bundle
  file; the file never changes. Suited to games, live tools, caches, and
  anything with frequent small state changes. `.pwebdata` export (per the
  companion `STORAGE` specification) is the portability mechanism.
  Externally stored state is keyed by runtime instance identity
  (Section 5), never by package identifier alone.

**`"embedded"`:**
: State is persisted into the bundle's own `userdata/` region
  (Section 6.9), so the document and its data travel together as one
  file. Suited to document-like content: journals, notebooks, albums,
  decks, form documents. Writes are staged and committed atomically;
  bundle content still uses standard web storage APIs, and the viewer is
  responsible for the round-trip.

Regardless of model, standard web storage APIs (`localStorage`,
IndexedDB) remain the interface presented to bundle content; the viewer
supplies the backing implementation. A viewer that supports storage but
not the embedded model MUST NOT refuse to open an embedded-model bundle:
it MUST fall back to external persistence for the session and SHOULD
offer export of an updated bundle. The same fallback applies when a
viewer holds a non-writable file handle (read-only media, sandboxed
copies, streamed sources).

Hybrid declarations — named stores with per-store models, e.g. portable
document data embedded with operational caches and credentials external —
are reserved for the companion `STORAGE` specification and MUST NOT be
expressed in the `model` field.

Compatibility: the 0.1 form `permissions.storage` with string values
`"none"` and `"isolated"` remains accepted; `"isolated"` is equivalent to
`{"model": "external"}`. When both forms are present, the top-level
`storage` object takes precedence.

## Permissions

Permissions are declared upfront in the manifest and are not requested at
runtime. Any permission not declared is denied by default. A declaration
is the bundle's maximum capability request — an input to viewer and user
policy, never an automatic grant. Viewers SHOULD present declared
permissions to the user when a bundle is first opened.

| Permission | Type | Default | Description |
|---|---|---|---|
| `internet.read` | boolean | `false` | Allow retrieval of external resources over the network: requests using safe methods (e.g., HTTP GET or HEAD) without request bodies. Archival bundles SHOULD keep this `false`. Origin allowlists are reserved for the companion runtime specification. |
| `internet.write` | boolean | `false` | Allow network requests that transmit data: unsafe methods, request bodies, WebSocket messages, and uploads. Encompasses `internet.read`; bundles SHOULD declare both for clarity. |
| `network` | boolean | `false` | Deprecated 0.1 form: equivalent to declaring both `internet.read` and `internet.write`. Viewers MUST still accept it; the split keys take precedence when both forms are present. |
| `camera` | boolean or string | `false` | Allow getUserMedia video access. A string value is shown to the user as a justification. |
| `microphone` | boolean or string | `false` | Allow getUserMedia audio access. |
| `geolocation` | boolean or string | `false` | Allow the Geolocation API. |
| `clipboard_write` | boolean | `false` | Allow programmatic writes to the system clipboard. |
| `notifications` | boolean | `false` | Allow OS-level notifications while the bundle is open. |
| `fullscreen` | boolean | `true` | Allow the Fullscreen API. Default is `true` due to low risk. |
| `peers` | boolean | `false` | Allow inter-bundle communication via local channels. Defined in the companion COMMS specification. |
| `storage` | string | `"isolated"` | Deprecated 0.1 form of the storage declaration; see Section 7.6. |

### Required and Optional Declarations

Every permission declaration is **optional** by default: if the viewer or
user denies the capability, or the viewer does not implement it, the
bundle still opens and the capability fails with the standard web
platform denial for that API (e.g., `NotAllowedError`, a rejected fetch).
Bundle authors are expected to handle these ordinary failure paths.

A bundle MAY mark a permission as **required** by declaring it in object
form:

~~~json
"permissions": {
  "camera": { "required": true, "justification": "Scans QR codes" }
}
~~~

The object form accepts `required` (boolean, default `false`) and
`justification` (string, shown to the user). A boolean or string
declaration is equivalent to the object form with `required: false`.

Viewer behavior:

- If a **required** capability is unsupported by the viewer or denied by
  policy, the viewer MUST NOT run the bundle as if nothing were wrong: it
  MUST either refuse to open the bundle or clearly warn the user before
  opening it with the capability unavailable.
- An **unknown permission key** declared in optional form MUST be
  ignored; the bundle opens and the capability is denied. An unknown
  permission key marked `required: true` MUST NOT be silently ignored
  and is handled as an unsupported required capability.
- A required declaration never weakens deny-by-default: it changes what
  the viewer tells the user, not what the bundle is granted.

Future versions of this specification and companion specifications MAY
define additional permission keys (candidates include external
navigation, popups, downloads, clipboard read, persistent-storage
durability, background tasks, and local-network and peer communication).

## The `rights` Object

| Field | Type | Description |
|---|---|---|
| `copyright` | string | Human-readable copyright notice (e.g., `"© 2026 Jane Doe"`). |
| `license` | string | An SPDX license identifier {{SPDX}} (e.g., `"MIT"`, `"CC-BY-4.0"`, `"CC0-1.0"`, `"proprietary"`). |
| `license_url` | string | URL to the full license text. |
| `contact` | string | Contact information for licensing inquiries. |

## The `viewport` Object

| Field | Type | Description |
|---|---|---|
| `preferred_width` | integer | Suggested initial window width in CSS pixels. |
| `preferred_height` | integer | Suggested initial window height in CSS pixels. |
| `resizable` | boolean | Whether the viewer window should be resizable. Default: `true`. |
| `min_width` | integer | Minimum window width in CSS pixels. |
| `min_height` | integer | Minimum window height in CSS pixels. |

These are hints, not requirements. Viewers MAY override them based on the
user's environment or platform conventions.

## Example: Minimal Valid Manifest

~~~json
{
  "spec_version": "0.2",
  "id": "org.example.minimal",
  "version": "1.0.0",
  "title": "Minimal Example",
  "entry": "index.html"
}
~~~

## Example: Full Manifest

~~~json
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
~~~

## Validation

Viewers and tools SHOULD validate manifests against the schema before
opening a bundle. A versioned, formal JSON Schema document for this
manifest will be published at
`https://portableweb.org/spec/manifest.schema.json`, alongside reference
bundles, invalid test bundles, and a conformance test suite.

# Packaged Resource URLs and Runtime Origins

Content inside a bundle addresses packaged resources by package-relative
reference. How those references are surfaced to the web engine is
implementation-defined: a viewer MAY map packaged resources to internal
URLs of its choosing (a custom scheme, a synthetic host, or another
mechanism). No particular URL scheme is standardized by this document,
and internal URLs MUST NOT be treated as stable or interchange-worthy
identifiers.

URL syntax and security origin are separate concepts. Whatever internal
URL mapping a viewer uses, the runtime origin assigned to bundle content:

- MUST be unique per runtime instance (Section 5), incorporating
  viewer-assigned instance identity and not merely the manifest `id`;
- MUST isolate each instance's storage, permissions, and execution
  context from every other bundle and from the viewer's own privileged
  context.

A future companion specification may standardize a `pweb:` URI scheme,
including its syntax, resolution algorithm, origin behavior, and security
considerations. Until then, `pweb:` URLs are host-specific plumbing and
MUST NOT appear in bundle content as cross-viewer references.

# Interoperability Considerations

PortableWeb bundles are ZIP-based containers with a manifest that identifies
the package structure, entry resource, declared capabilities, and packaged
resources. Interoperability depends on viewers interpreting the manifest
consistently, resolving resource paths consistently, and enforcing package
boundaries consistently.

Implementations MUST use UTF-8 for manifest data and resource identifiers.
Resource paths are case-sensitive, package-relative paths (Section 6.3).
Implementations MUST NOT rely on platform-specific filesystem
behavior such as case-insensitive path matching, absolute paths, drive
letters, symbolic links, or path separators other than `/`.

PortableWeb bundles may contain common web resource formats including HTML,
CSS, JavaScript, JSON, images, fonts, audio, and video. Rendering behavior
may vary between web engines and viewer implementations, particularly for
optional web platform features, media codecs, and device APIs. Bundle
authors SHOULD use widely supported web standards and SHOULD declare
requested capabilities in the manifest, marking as required only those the
content cannot meaningfully function without. Viewers SHOULD ignore
unknown manifest fields that are not required for safe processing, and
repackaging tools SHOULD preserve them.

A conforming bundle in the portable lifecycle SHOULD be interpretable
using only the resources it contains, unless the manifest and viewer
policy explicitly allow external network access.

# Security Considerations

PortableWeb files may contain active web content including HTML, CSS,
ECMAScript, WebAssembly (if permitted by the viewer), and other resources
referenced by the manifest. Implementations MUST treat PortableWeb files as
untrusted content unless obtained from a verified trusted source.

## Sandboxed Execution

PortableWeb content is intended to be processed by a viewer, not executed
as native operating-system code. Viewers that render active content SHOULD
do so in a sandboxed execution environment with no ambient access to the
host application, local files, device APIs, credentials, cookies, or other
user data except where the user has explicitly granted access. Viewers
SHOULD:

- Isolate storage and execution per runtime instance (Section 5).
- Restrict or mediate network access according to user or application policy.
- Prevent script access to the viewer application's privileged interface.
- Apply the security model of the underlying web rendering engine.
- Prevent active content from escaping the sandbox through navigation,
  popups, downloads, same-origin confusion, or unrestricted access to
  host-provided APIs.
- Deny bundle content the ability to register Service Workers or any
  other mechanism that would outlive the open session in the portable
  lifecycle.

## Permission Model

A PortableWeb manifest declares the capabilities requested by the bundle.
These declarations are inputs to the viewer's security policy and are not
security guarantees by themselves. Viewers MUST apply a deny-by-default
policy: only capabilities permitted by both the manifest and the viewer or
user policy are available, and everything else is denied. Viewers MAY
ignore or further restrict manifest-declared capabilities, subject to the
required-capability disclosure rules of Section 7.7.1. A `required`
marking affects what the user is told, never what the bundle is granted.

## Identity and Copy Semantics

Because bundles are freely copyable files, viewers MUST NOT key security
state (permission grants, storage, credentials, registrations) on the
package identifier alone (Section 5.2). Doing so would allow an
independent or malicious copy declaring the same `id` to inherit another
bundle's grants and data.

## Credentials and Tokens

Bundles in the portable lifecycle are not durable holders of secrets.
Credentials, OAuth access and refresh tokens, API keys, and similar
secrets MUST NOT be embedded in a portable `.pweb` file — including its
user-data region — because copying or sharing the file would ship the
secrets with it. Where a viewer supports authenticated flows, tokens
belong in protected external viewer storage keyed to the runtime
instance. Detailed OAuth integration is out of scope for this document
and requires the installed lifecycle's stable identity.

## Confidentiality and Integrity

The media type itself provides no confidentiality, integrity, authentication,
authorization, or replay protection. Where confidentiality or integrity is
required, it SHOULD be provided externally, for example by HTTPS or TLS
during transport, operating-system file protections, digital signatures, or
checksums. Viewers SHOULD make trust decisions based on the source and
integrity of the package before enabling higher-risk capabilities.

Cryptographic signing of PortableWeb bundles is defined in the companion
SIGNING specification. Signature scope follows the package-region rules
of Section 6.9: the application region is signed; the user-data region is
not.

## ZIP Container Security

PortableWeb files are ZIP-based binary containers. The security
considerations for ZIP containers and compressed content apply. The
validation rules of Section 6.3 are mandatory; in particular
implementations MUST protect against:

- Decompression bombs and excessive memory or disk usage.
- Deeply nested archives and excessive path depth.
- Duplicate, ambiguous, or normalization-equivalent filenames.
- Absolute paths and path traversal sequences such as `../`.
- Symbolic links and platform-specific path handling issues.
- Filename normalization conflicts.
- Mismatches between ZIP metadata and actual content.

Implementations MUST impose limits on total uncompressed size,
file count, nesting depth, path length, compression ratio, and individual
resource size before extraction or rendering. Implementations MUST NOT
extract files outside an application-controlled storage area.

## External Resources

PortableWeb packages may contain internal links between packaged resources
and may optionally reference external resources when the `internet.read`
or `internet.write` permissions are granted. Viewers SHOULD clearly
distinguish packaged local resources from external resources and SHOULD
mediate or block external navigation and network requests according to
user or application policy.

The read/write split is a disclosure and enforcement tier, not an
exfiltration guarantee: any permitted outbound request — including a
safe-method request under `internet.read` — can carry data encoded in
its URL. Viewers SHOULD therefore present `internet.read` to users as
"this content can access the internet," and users SHOULD treat any
network-permitted bundle as capable of transmitting data.

## User Data in Shared Files

A bundle with embedded storage carries its user's data inside the file.
Sharing flows SHOULD default to asking whether to include or strip the
user-data region, and viewers SHOULD make producing a stripped copy easy
(Section 4.1). Authors of embedded-storage bundles SHOULD assume any
copy that leaves the user's device may be read in full.

# IANA Considerations

## Media Type Registration

The `application/vnd.portableweb+zip` media type described in this section
has been registered with IANA in the vendor tree per {{RFC6838}}
(registration date 2026-07-21) and is listed
in the IANA Media Types registry at
<https://www.iana.org/assignments/media-types/application/vnd.portableweb+zip>.
The registration template below is retained for reference and reflects the
registered entry. This revision makes no changes to the registration and
requests no IANA action.

Type name:
: application

Subtype name:
: vnd.portableweb+zip

Required parameters:
: None.

Optional parameters:
: None.

Encoding considerations:
: Binary.

Security considerations:
: See Section 10 of this document.

Interoperability considerations:
: See Section 9 of this document.

Published specification:
: This document.

Applications that use this media type:
: PortableWeb viewer applications, authoring tools, packaging tools,
  validation tools, document-management systems, file managers, web servers,
  content-distribution systems, and AI content generation tools that create,
  distribute, inspect, validate, store, or render PortableWeb packages.

Fragment identifier considerations:
: Fragment identifier semantics are not defined by this registration for the
  PortableWeb container as a whole. Fragment identifiers within packaged
  resources are interpreted according to the rules of the individual resource
  media type. If a future version of this specification defines
  PortableWeb-specific fragment identifier syntax, this registration will be
  updated.

Additional information:

: Magic number(s): `50 4B 03 04` (PK\\003\\004)

: File extension(s): `.pweb`

: Macintosh file type code: N/A

: Object Identifiers: N/A

Person to contact for further information:
: Omprakash Selvaraj, maintainer@portableweb.org

Intended usage:
: COMMON

Restrictions on usage:
: None.

Author:
: Omprakash Selvaraj

Change controller:
: Omprakash Selvaraj

--- back

# Changes from Version 01
{:numbered="false"}

This revision is a substantial architectural revision. The format version
advances from 0.1 to 0.2. Because the format is pre-1.0, breaking
corrections are permitted (see Section 6.12); they are marked below.

Registration and positioning:

- The `application/vnd.portableweb+zip` media type has been formally
  registered with IANA (registration date 2026-07-21). Section 11 now
  records the registration and links to the IANA Media Types registry
  entry. No further IANA action is requested.
- The problem statement no longer claims that no existing format handles
  portable interactive web content; it now states precisely what
  PortableWeb uniquely standardizes (the portable, stateful, user-owned
  document lifecycle). A new "Relationship to Existing Technologies"
  section (Section 3) positions the format against EPUB, W3C MiniApp
  Packaging, Web Application Manifest, Web Bundles, Isolated Web Apps,
  hosted PWAs, and native packages.
- "Without association with a Web origin" has been replaced with
  "without requiring a server-hosted Web origin" throughout, since
  viewers assign synthetic runtime origins.

New architecture:

- Lifecycle profiles (Section 4): the portable lifecycle is defined
  normatively as the primary model; the installed lifecycle is named and
  reserved with minimal normative constraints, its details deferred to a
  companion specification.
- Identity model (Section 5): package identifier, document identity,
  runtime instance identity, and publisher identity are now distinct
  concepts, with copy/move/rename semantics. **Breaking correction:** the
  package identifier alone must no longer be used as the runtime origin
  or storage key.
- Package regions (Section 6.9): the container is divided into an
  immutable application region and a mutable user-data region under the
  newly reserved `userdata/` root path. Signature scope is defined to
  cover only the application region.
- Packaged resource URLs and runtime origins (Section 8): internal URL
  mappings are implementation-defined; URL syntax and security origin are
  separated; no URI scheme is standardized by this document.

Container:

- Container validation (Section 6.3) is now mandatory and enforceable:
  prohibitions on absolute paths, dot and dot-dot components, backslashes,
  drive letters, and symbolic links are MUST-level (**breaking
  correction** from SHOULD-level in -01); NFC-normalized case-sensitive
  entry-name comparison and duplicate rejection are required; allowed
  compression methods are limited to STORED and DEFLATE; limits on size,
  count, depth, path length, and compression ratio are required.
- File extension, declared media type, and ZIP magic bytes are now
  candidate-identification hints only; full validation is required before
  execution, and the non-uniqueness of ZIP magic bytes is stated.
- A normative processing model and conformance classes for packages,
  viewers, packagers, and validators have been added (Section 6.11).
- Versioning (Section 6.12) no longer promises unconditional backward
  compatibility for all future versions (**breaking correction**): pre-1.0
  revisions may make documented breaking corrections; the append-only
  archival guarantee applies from 1.0 onward. Unsupported-version and
  unknown-field handling are now defined.

Manifest (format version 0.2):

- `spec_version` for conforming bundles is now `"0.2"`; viewers are
  expected to continue accepting 0.1 bundles.
- The singular `icon` field is deprecated in favor of an `icons` array
  with Web Application Manifest semantics (Section 7.5); package-relative
  sources only, with script-free and externally-isolated SVG rendering
  required.
- New optional fields `short_name`, `lang`, and `dir`, reusing Web
  Application Manifest semantics.
- A top-level `storage` declaration (Section 7.6) replaces the 0.1
  `permissions.storage` string, defining the `"none"`, `"external"`, and
  `"embedded"` models; `"isolated"` remains accepted as a deprecated
  alias for the external model. Fallback behavior for viewers lacking
  embedded-model support or holding non-writable handles is defined.
  Hybrid named stores are reserved for the STORAGE companion
  specification.
- The boolean `network` permission is split into `internet.read` and
  `internet.write` (**breaking correction**, reconciling the W3C
  Community Group draft's model into this document); `network` remains
  accepted as a deprecated alias equivalent to declaring both.
- Permission declarations may now use an object form with `required` and
  `justification` members (Section 7.7.1). Declarations remain
  optional-by-default with standard web denial semantics; required
  capabilities that are unsupported or denied trigger refuse-or-warn.
  Unknown optional permission keys are ignored; unknown required keys are
  not.

Security:

- New security-considerations subsections: identity and copy semantics,
  credentials and tokens (secrets must not be embedded in portable
  files), and user data in shared files (strip-on-share guidance).
- ZIP container protections and limits raised from SHOULD to MUST.

# Changes from Version 00
{:numbered="false"}

The following changes were made in revision -01:

- The format's full name, "Portable Web Content Format
  (PortableWeb)", is now
  introduced explicitly on first use in the document title, abstract,
  Introduction section, and Terminology section. Subsequent references
  throughout the document continue to use "PortableWeb" as the short form.

- A formal terminology entry for
  "Portable Web Content Format (PortableWeb)"
  has been added to Section 2 to establish the short-form usage.

- The keyword list has been updated to include
  "portable web content format" for improved discoverability.

- Editorial clarifications throughout; no normative changes.

# Acknowledgments
{:numbered="false"}

The PortableWeb container format draws on conventions established by EPUB 3
{{EPUB3}} for the `mimetype` entry and ZIP-based packaging, and on the
broader web platform standards ecosystem for the runtime model. The author
thanks the IANA media types reviewer and the W3C Portable Web Content Format
Community Group participants for their feedback on early drafts of this
specification.
