# Portable Web Content Format (PortableWeb) — Container Specification

**Version:** 0.1 (Draft)
**Status:** Pre-release. Breaking changes may occur until v1.0.
**Date:** 2026-05-24
**Editor:** Omprakash Selvaraj
**Canonical URL:** [https://portableweb.org/spec/container/](https://zenodo.org/records/20618881)
**IETF Internet-Draft:** [draft-selvaraj-portableweb-format-01](https://www.ietf.org/archive/id/draft-selvaraj-portableweb-format-01.html)

---

## 1. Overview

A **PortableWeb bundle** (`.pweb`) is a single file containing all the HTML, CSS,
JavaScript, and media needed to render an interactive experience, packaged in
a way that can be opened by any compatible viewer application on any platform,
entirely offline, without a web server and without being associated with a Web
origin.

This document defines the **container format**: how the bytes inside a `.pweb`
file are organized, what files must exist, and how a viewer identifies the
bundle. The runtime sandbox, permission model, and frozen feature subset are
defined in companion specifications.

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

## 3. File extension and media type

- **File extension:** `.pweb`
- **Media type:** `application/vnd.portableweb+zip`
- **Magic bytes:** `50 4B 03 04` (PK\003\004) — the standard ZIP local file header signature.

A viewer **MUST** accept files with the `.pweb` extension or the registered
media type. A viewer **SHOULD** also identify bundles by inspecting the
`mimetype` entry described in §4.2.

## 4. Container format

### 4.1 Outer container

A bundle **MUST** be a valid ZIP archive. The ISO/IEC 21320-1 Document Container
File profile is RECOMMENDED. Specifically:

- The archive **MUST NOT** be encrypted.
- The archive **MUST NOT** be split across multiple files.
- File and directory names inside the archive **MUST** use forward slashes
  (`/`) as path separators, encoded in UTF-8.
- The archive **SHOULD NOT** contain absolute paths or `..` path components.

### 4.2 The `mimetype` entry

A bundle **MUST** contain a file named `mimetype` at the archive root with:

- **Contents:** the ASCII string `application/vnd.portableweb+zip` with no
  trailing newline or whitespace.
- **Position:** the *first* entry in the ZIP archive.
- **Compression:** STORED (method 0, uncompressed).
- **No extra fields** in the local file header.

This convention (borrowed from EPUB) allows a tool to identify a PortableWeb
bundle by reading the first ~80 bytes of the file, without unpacking the
archive.

### 4.3 The `manifest.json` entry

A bundle **MUST** contain a file named `manifest.json` at the archive root,
encoded as UTF-8 JSON without a byte order mark. The manifest schema is
defined in `MANIFEST.md`. At minimum, the manifest declares:

- The spec version the bundle targets.
- A unique bundle identifier.
- The bundle version.
- A human-readable title.
- The entry HTML file path.
- Any declared permissions.

### 4.4 The entry file

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
└── data/                     (recommended: JSON and static data)
```

## 6. Reserved paths

The following paths at the archive root are reserved by this specification.
Bundles **SHOULD NOT** create files at these paths unless following an explicit
PortableWeb sub-specification:

- `mimetype`
- `manifest.json`
- `META-INF/` (reserved for signature manifests and integrity data in future versions)
- `.well-known/` (reserved for future use)

## 7. Bundle identification

A viewer **SHOULD** identify a file as a PortableWeb bundle if any of the
following are true:

1. The file extension is `.pweb`.
2. The file's declared media type is `application/vnd.portableweb+zip`.
3. The first ZIP entry is a STORED file named `mimetype` containing exactly
   `application/vnd.portableweb+zip`.

A viewer **SHOULD** reject any file claiming to be a PortableWeb bundle that
fails to validate against §4 of this specification.

## 8. Versioning

The container format is versioned independently from companion specifications.
This document describes container version **0.1**.

Future container versions **MUST** remain backwards compatible. A bundle
declaring `spec_version: "1.0"` in its manifest **MUST** remain openable by
any future viewer that claims support for v1.0 bundles. New features are
added in new spec versions; existing features are never removed. This
guarantee is the foundation of the PortableWeb archival promise.

## 9. Interoperability Considerations

PortableWeb bundles are ZIP-based containers with a manifest that identifies
the package structure, entry resource, declared capabilities, and packaged
resources. Interoperability depends on viewers interpreting the manifest
consistently, resolving resource paths consistently, and enforcing package
boundaries consistently.

Implementations **SHOULD** use UTF-8 for manifest data and resource identifiers.
Resource paths **SHOULD** be treated as case-sensitive, package-relative paths.
Implementations **SHOULD** avoid relying on platform-specific filesystem
behavior such as case-insensitive path matching, absolute paths, drive
letters, symbolic links, or path separators other than `/`.

Viewers **SHOULD** reject or normalize ambiguous paths, duplicate entries, and
references that resolve outside the package boundary.

PortableWeb bundles may contain common web resource formats including HTML,
CSS, JavaScript, JSON, images, fonts, audio, and video. Rendering behavior
may vary between web engines and viewer implementations, particularly for
optional web platform features, media codecs, and device APIs. Bundle
authors **SHOULD** use widely supported web standards and **SHOULD** declare
required capabilities in the manifest. Viewers **SHOULD** ignore unknown
manifest fields that are not required for safe processing.

A conforming local PortableWeb bundle **SHOULD** be interpretable using only
the resources it contains, unless the manifest and viewer policy explicitly
allow external network access.

## 10. Security Considerations

PortableWeb files may contain active web content including HTML, CSS,
JavaScript, WebAssembly, and other resources. Implementations **MUST** treat
PortableWeb files as untrusted content unless obtained from a verified
trusted source.

### Sandboxed execution

PortableWeb content is intended to be rendered by a viewer in a sandboxed
execution environment with no ambient access to the host application, local
files, device APIs, credentials, cookies, or other user data except where
explicitly granted. Viewers **SHOULD**:

- Isolate storage per bundle.
- Restrict or mediate network access according to user or application policy.
- Prevent script access to the viewer's privileged interface.
- Apply the security model of the underlying web rendering engine.
- Prevent active content from escaping the sandbox through navigation, popups,
  downloads, same-origin confusion, or unrestricted access to host-provided APIs.

### Permission model

A manifest's declared capabilities are inputs to the viewer's security policy,
not security guarantees by themselves. Viewers **SHOULD** apply a deny-by-default
policy and allow only capabilities permitted by both the manifest and
viewer/user policy. Viewers **MAY** ignore or further restrict manifest-declared
capabilities.

### Confidentiality and integrity

The container format itself provides no confidentiality, integrity, or
authentication. Where these properties are required, they **SHOULD** be
provided externally (e.g., HTTPS during transport, OS file protections, or
cryptographic signing). Cryptographic signing of bundles is defined in the
companion `SIGNING` specification.

### ZIP container security

Implementations **SHOULD** protect against:

- Decompression bombs and excessive memory or disk usage.
- Duplicate or ambiguous filenames.
- Absolute paths and path traversal sequences (`../`).
- Symbolic links and platform-specific path handling issues.
- Mismatches between ZIP metadata and actual content.

Implementations **SHOULD** impose reasonable limits on total uncompressed size,
file count, nesting depth, path length, and individual resource size.

## 11. Out of scope (for v0.1)

The following are intentionally not specified in this document and will be
addressed in companion specifications:

- The manifest schema in full detail → `MANIFEST.md`
- The runtime sandbox and security model → `SANDBOX.md`
- The frozen subset of web platform features per spec version → `RUNTIME-PROFILE.md`
- Cryptographic signing of bundles → `SIGNING.md`
- Storage, permissions, and user data → `STORAGE.md`
- Inter-bundle communication → `COMMS.md`

## 12. License

This specification is licensed under
[Creative Commons Attribution 4.0 International (CC-BY-4.0)](https://creativecommons.org/licenses/by/4.0/).

Reference implementations and example bundles published in the PortableWeb
repositories are licensed under the MIT License unless otherwise stated.

## 13. Changelog

- **0.1** (2026-05-24) — Initial draft. Defines container format, mimetype
  convention, manifest requirement, entry file requirement, and reserved paths.
  Companion specifications (MANIFEST, SANDBOX, RUNTIME-PROFILE) are forthcoming.
