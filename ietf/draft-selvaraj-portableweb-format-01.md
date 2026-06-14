---
title: "Portable Web Content Format (PortableWeb): Container and Manifest Specification"
abbrev: "portableweb-format"
docname: draft-selvaraj-portableweb-format-01
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

--- abstract

This document defines the Portable Web Content Format (PortableWeb),
a file format for packaging
interactive web content — including HTML, CSS, JavaScript, and associated
media — into a single self-contained, portable bundle. A PortableWeb bundle
(`.pweb` file) can be saved, shared, and rendered by a compatible viewer
application on any platform, entirely offline, without a web server, without
association with a Web origin, and without being confined to a web browser.

This specification defines the container format and manifest schema for
PortableWeb bundles at version 0.1. Companion specifications covering the
runtime sandbox, storage model, signing, and inter-bundle communication are
forthcoming.

--- middle

# Introduction

The emergence of AI-assisted development tools has fundamentally changed the
economics of creating interactive web content. Presentations, educational
simulations, small games, data visualizations, and scientific models that
previously required days of skilled development can now be generated in
minutes. This has created a massive and growing category of ephemeral Web
applications that need to be shared and used immediately across devices and
platforms, without a traditional server for distribution, without association
with a Web origin, and without being confined to a web browser.

No existing file format treats interactive web content as a portable,
self-contained, immediately runnable unit. Current options each force an
unacceptable tradeoff:

- Deploying to a web server requires hosting infrastructure and network
  connectivity, and is unsuitable for ephemeral or single-use content.

- Publishing to an application store requires developer accounts, review
  cycles, and ongoing maintenance — appropriate for long-lived commercial
  software, but not for the large volumes of interactive artifacts being
  created today.

- PDF loses interactivity entirely.

- EPUB 3 {{EPUB3}} is constrained to a document and book model. Its
  JavaScript support is an enhancement to a reading experience, not a
  general-purpose runtime. EPUB cannot meaningfully represent a game loop,
  a real-time simulation, or an interactive scientific model.

- Web Bundles, proposed in the Web Platform Incubator Community Group, was
  designed as a network transport optimization and never achieved broad
  implementation. It has no offline-first execution model and no
  inter-bundle communication mechanism.

- The Web Application Manifest describes how an already-deployed web
  application presents itself when installed on a device. It is
  fundamentally tied to a Web origin — the application lives on a server
  and the manifest is a descriptor for that server-hosted experience. It
  does not address content that has no server and no origin.

- WebAssembly {{WASM}} is a runtime technology, not a distribution format.
  It may be used as a resource within a PortableWeb bundle — alongside
  HTML, CSS, and JavaScript — where high-performance code execution is
  needed. However, WebAssembly defines no packaging structure, manifest,
  viewer model, or permission system for self-contained content
  distribution. The relationship is complementary: WebAssembly can run
  inside a PortableWeb bundle; it does not address the same problem.

The Portable Web Content Format (PortableWeb) addresses this gap.
A `.pweb` bundle is a single file
that contains all the HTML, CSS, JavaScript, and media required to render an
interactive experience. It can be opened by a compatible viewer application
on any platform — desktop, mobile, or otherwise — entirely offline, without
deployment infrastructure, without a Web origin, and without being confined
to a web browser. The content inside is built entirely on standard web
technologies, keeping the format firmly within the web platform ecosystem.

The format is content-model agnostic. A PortableWeb bundle may contain a
book, a game, an interactive presentation, an educational simulation, a 3D
experience, a scientific model, a collaborative application, or any other
interactive content built on web technologies. The format imposes no
constraints on the content model.

## Design Goals

The PortableWeb format is designed to:

- Be openable by any compatible viewer on any platform, entirely offline.
- Behave like a document: saveable, copyable, shareable, and archivable.
- Support any interactive content built on standard web technologies.
- Operate without a Web origin and without being confined to a web browser.
- Declare capabilities and permissions upfront in a structured manifest.
- Provide a stable, versioned format with long-term backwards compatibility.
- Be identifiable without unpacking (via magic bytes and a mimetype entry).
- Remain simple enough that a conforming implementation can be built quickly.

## Scope of This Document

This document defines:

1. The container format: how a `.pweb` file is structured as a ZIP archive
   (Section 3).
2. The manifest schema: the `manifest.json` file that every bundle must
   contain (Section 4).
3. Security considerations for implementations (Section 6).
4. IANA considerations for the `application/vnd.portableweb+zip` media type
   (Section 7).

The following are out of scope for this document and will be addressed in
companion specifications:

- The runtime sandbox and security model (`SANDBOX`).
- The frozen subset of supported web platform features per spec version
  (`RUNTIME-PROFILE`).
- Cryptographic signing of bundles (`SIGNING`).
- Storage, permissions, and user data isolation (`STORAGE`).
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

# Container Format

## File Extension and Media Type

A PortableWeb bundle uses the following identifiers:

- **File extension:** `.pweb`
- **Media type:** `application/vnd.portableweb+zip`
- **Magic bytes:** `50 4B 03 04` (PK\\003\\004) — the standard ZIP local
  file header signature.

A viewer MUST accept files with the `.pweb` extension or the
`application/vnd.portableweb+zip` media type. A viewer SHOULD also identify
bundles by inspecting the `mimetype` entry described in Section 3.3.

## Outer Container

A bundle MUST be a valid ZIP archive. The ISO/IEC 21320-1 Document Container
File profile {{ISO21320}} is RECOMMENDED. Specifically:

- The archive MUST NOT be encrypted.
- The archive MUST NOT be split across multiple files.
- File and directory names inside the archive MUST use forward slashes (`/`)
  as path separators, encoded in UTF-8.
- The archive SHOULD NOT contain absolute paths or `..` path components.

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
schema is defined in Section 4. At minimum, the manifest declares:

- The spec version the bundle targets.
- A unique bundle identifier.
- The bundle version.
- A human-readable title.
- The path to the entry HTML file.
- Any declared permissions.

## The Entry File

A bundle MUST contain the file referenced by the manifest's `entry` field.
The entry file MUST have a `.html` or `.htm` extension and MUST be valid
HTML5. The entry file is loaded by the viewer in a sandboxed context. All
other files in the bundle are addressable from the entry file using relative
paths.

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
└── data/                     (recommended: JSON and static data)
~~~

## Reserved Paths

The following paths at the archive root are reserved by this specification.
Bundles SHOULD NOT create files at these paths unless following an explicit
PortableWeb sub-specification:

- `mimetype`
- `manifest.json`
- `META-INF/` (reserved for signature manifests and integrity data)
- `.well-known/` (reserved for future use)

## Bundle Identification

A viewer SHOULD identify a file as a PortableWeb bundle if any of the
following conditions are true:

1. The file extension is `.pweb`.
2. The file's declared media type is `application/vnd.portableweb+zip`.
3. The first ZIP entry is a STORED file named `mimetype` containing exactly
   `application/vnd.portableweb+zip`.

A viewer SHOULD reject any file claiming to be a PortableWeb bundle that
fails to validate against this section.

## Versioning

The container format is versioned independently from companion
specifications. This document describes container version 0.1.

Future container versions MUST remain backwards compatible. A bundle
declaring `spec_version: "1.0"` in its manifest MUST remain openable by any
future viewer that claims support for v1.0 bundles. New features are added
in new spec versions; existing features are not removed. This guarantee is
the foundation of the PortableWeb archival promise.

# Manifest Schema

## Overview

Every PortableWeb bundle contains a `manifest.json` file at its archive root.
The manifest is the bundle's structured metadata: it identifies the bundle,
declares its entry point, specifies requested permissions, and carries rights
and authorship information.

## Format

The manifest MUST be a valid JSON document {{RFC8259}} encoded as UTF-8
without a byte order mark. The top-level value MUST be a JSON object.

## Required Fields

The following fields MUST be present in every conforming manifest:

| Field | Type | Description |
|---|---|---|
| `spec_version` | string | The PortableWeb container spec version this bundle targets. Format: `"MAJOR.MINOR"`. For v0.1 bundles, the value MUST be `"0.1"`. |
| `id` | string | A globally unique identifier for this bundle in reverse-domain notation (e.g., `"org.example.my-bundle"`). MUST contain only lowercase alphanumeric characters, dots, and hyphens. |
| `version` | string | The bundle's own version, following Semantic Versioning 2.0 {{SEMVER}} (e.g., `"1.0.0"`). |
| `title` | string | A human-readable title for the bundle. MUST NOT exceed 200 characters. |
| `entry` | string | The path within the bundle to the HTML entry file. MUST end in `.html` or `.htm`. MUST NOT begin with `/`. |

## Recommended Fields

The following fields are RECOMMENDED:

| Field | Type | Description |
|---|---|---|
| `description` | string | A short description of the bundle. MUST NOT exceed 1000 characters. |
| `author` | object | An object with `name` (required), `email` (optional), and `url` (optional). |
| `created` | string | The creation date in ISO 8601 format (e.g., `"2026-05-24T00:00:00Z"`). |
| `icon` | string | Path within the bundle to a square icon (SVG or PNG RECOMMENDED). |
| `permissions` | object | Declared capabilities (see Section 4.5). If omitted, all permissions default to their specified default values. |
| `rights` | object | Copyright and license information (see Section 4.6). |
| `viewport` | object | Hints to the viewer for initial window sizing (see Section 4.7). |
| `content_type` | string | A hint describing the nature of the content. RECOMMENDED values: `"game"`, `"presentation"`, `"book"`, `"simulation"`, `"tool"`, `"report"`, `"visualization"`, `"education"`. |

## Permissions

Permissions are declared upfront in the manifest and are not requested at
runtime. Any permission not declared is denied by default. Viewers SHOULD
present declared permissions to the user when a bundle is first opened.

| Permission | Type | Default | Description |
|---|---|---|---|
| `network` | boolean | `false` | Allow fetch and XMLHttpRequest to non-bundle URLs. Archival bundles SHOULD keep this `false`. |
| `camera` | boolean or string | `false` | Allow getUserMedia video access. A string value is shown to the user as a justification. |
| `microphone` | boolean or string | `false` | Allow getUserMedia audio access. |
| `geolocation` | boolean or string | `false` | Allow the Geolocation API. |
| `clipboard_write` | boolean | `false` | Allow programmatic writes to the system clipboard. |
| `notifications` | boolean | `false` | Allow OS-level notifications while the bundle is open. |
| `fullscreen` | boolean | `true` | Allow the Fullscreen API. Default is `true` due to low risk. |
| `storage` | string | `"isolated"` | Storage mode. Allowed values: `"none"` (no persistent storage), `"isolated"` (scoped localStorage and IndexedDB, isolated per bundle). |
| `peers` | boolean | `false` | Allow inter-bundle communication via local channels. Defined in the companion COMMS specification. |

Future versions of this specification MAY define additional permission keys.
Viewers MUST ignore unknown permission keys when the bundle targets a spec
version the viewer supports.

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
  "spec_version": "0.1",
  "id": "org.example.minimal",
  "version": "1.0.0",
  "title": "Minimal Example",
  "entry": "index.html"
}
~~~

## Example: Full Manifest

~~~json
{
  "spec_version": "0.1",
  "id": "org.example.solar-system",
  "version": "1.2.0",
  "title": "Interactive Solar System",
  "description": "Explore planet orbits and relative scales.",
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
~~~

## Validation

Viewers and tools SHOULD validate manifests against the schema before
opening a bundle. A formal JSON Schema document for this manifest will be
published at `https://portableweb.org/spec/manifest.schema.json`.

# Interoperability Considerations

PortableWeb bundles are ZIP-based containers with a manifest that identifies
the package structure, entry resource, declared capabilities, and packaged
resources. Interoperability depends on viewers interpreting the manifest
consistently, resolving resource paths consistently, and enforcing package
boundaries consistently.

Implementations SHOULD use UTF-8 for manifest data and resource identifiers.
Resource paths SHOULD be treated as case-sensitive, package-relative paths.
Implementations SHOULD avoid relying on platform-specific filesystem
behavior such as case-insensitive path matching, absolute paths, drive
letters, symbolic links, or path separators other than `/`.

Viewers SHOULD reject or normalize ambiguous paths, duplicate entries, and
references that resolve outside the package boundary.

PortableWeb bundles may contain common web resource formats including HTML,
CSS, JavaScript, JSON, images, fonts, audio, and video. Rendering behavior
may vary between web engines and viewer implementations, particularly for
optional web platform features, media codecs, and device APIs. Bundle
authors SHOULD use widely supported web standards and SHOULD declare
required or requested capabilities in the manifest. Viewers SHOULD ignore
unknown manifest fields that are not required for safe processing.

A conforming local PortableWeb bundle SHOULD be interpretable using only
the resources it contains, unless the manifest and viewer policy explicitly
allow external network access.

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

- Isolate storage per bundle.
- Restrict or mediate network access according to user or application policy.
- Prevent script access to the viewer application's privileged interface.
- Apply the security model of the underlying web rendering engine.
- Prevent active content from escaping the sandbox through navigation,
  popups, downloads, same-origin confusion, or unrestricted access to
  host-provided APIs.

## Permission Model

A PortableWeb manifest declares the capabilities requested by the bundle.
These declarations are inputs to the viewer's security policy and are not
security guarantees by themselves. Viewers SHOULD apply a deny-by-default
policy and SHOULD allow only the capabilities explicitly permitted by both
the manifest and the viewer or user policy. Viewers MAY ignore or further
restrict manifest-declared capabilities.

## Confidentiality and Integrity

The media type itself provides no confidentiality, integrity, authentication,
authorization, or replay protection. Where confidentiality or integrity is
required, it SHOULD be provided externally, for example by HTTPS or TLS
during transport, operating-system file protections, digital signatures, or
checksums. Viewers SHOULD make trust decisions based on the source and
integrity of the package before enabling higher-risk capabilities.

Cryptographic signing of PortableWeb bundles is defined in the companion
SIGNING specification.

## ZIP Container Security

PortableWeb files are ZIP-based binary containers. The security
considerations for ZIP containers and compressed content apply.
Implementations SHOULD protect against:

- Decompression bombs and excessive memory or disk usage.
- Deeply nested archives.
- Duplicate or ambiguous filenames.
- Absolute paths and path traversal sequences such as `../`.
- Symbolic links and platform-specific path handling issues.
- Filename normalization conflicts.
- Mismatches between ZIP metadata and actual content.

Implementations SHOULD impose reasonable limits on total uncompressed size,
file count, nesting depth, path length, and individual resource size before
extraction or rendering. Implementations SHOULD NOT extract files outside
an application-controlled storage area.

## External Resources

PortableWeb packages may contain internal links between packaged resources
and may optionally reference external resources when the `network` permission
is granted. Viewers SHOULD clearly distinguish packaged local resources from
external resources and SHOULD mediate or block external navigation and
network requests according to user or application policy.

# IANA Considerations

## Media Type Registration

This document registers the following media type:

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
: See Section 6 of this document.

Interoperability considerations:
: See Section 5 of this document.

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

# Changes from Version 00
{:numbered="false"}

The following changes were made in this revision:

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
