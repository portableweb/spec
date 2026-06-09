# PortableWeb Container Specification

**Version:** 0.1 (Draft)
**Status:** Pre-release. Breaking changes may occur until v1.0.
**Date:** 2026-05-24
**Editor:** Omprakash Selvaraj
**Canonical URL:** https://portableweb.org/spec/container/
**IETF Internet-Draft:** [draft-selvaraj-portableweb-format-00](../ietf/draft-selvaraj-portableweb-format-00.md)

---

## 1. Overview

A **PortableWeb bundle** (`.pweb`) is a single file containing all the HTML, CSS,
JavaScript, and media needed to render an interactive document, packaged in
a way that can be opened by any compatible viewer, offline, indefinitely.

This document defines the **container format**: how the bytes inside a `.pweb`
file are organized, what files must exist, and how a viewer identifies the
bundle. It does *not* yet define the full runtime sandbox, permission model,
or feature subset — those are separate documents in this directory.

A PortableWeb bundle is intended to behave like a document, not an
application: it is a file you can save, copy, email, or archive. A compatible
viewer opens it in its own window, sandboxed from the host system and from
other bundles.

## 2. Terminology

The key words **MUST**, **MUST NOT**, **SHOULD**, **SHOULD NOT**, and **MAY**
in this document are to be interpreted as described in RFC 2119.

- **Bundle** — a single `.pweb` file.
- **Viewer** — software that opens, renders, and sandboxes a bundle.
- **Manifest** — the `manifest.json` file inside a bundle.
- **Entry** — the HTML file the viewer loads first, declared in the manifest.

## 3. File extension and media type

- **File extension:** `.pweb`
- **Media type:** `application/vnd.portableweb+zip`
- **Magic bytes:** Bundles begin with the standard ZIP local file header
  signature (`50 4B 03 04`).

A viewer **MUST** accept files with the `.pweb` extension or the registered
media type. A viewer **SHOULD** also identify bundles by inspecting the
`mimetype` entry described in §4.2.

## 4. Container format

### 4.1 Outer container

A bundle **MUST** be a valid ZIP archive (ISO/IEC 21320-1, "Document
Container File" profile, recommended). Specifically:

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
- **Compression:** STORED (uncompressed).
- **No extra fields** in the local file header.

This convention (borrowed from EPUB) allows a tool to identify a PortableWeb
bundle by reading the first ~80 bytes of the file, without unpacking the
archive.

### 4.3 The `manifest.json` entry

A bundle **MUST** contain a file named `manifest.json` at the archive root,
encoded as UTF-8 JSON. The manifest schema is defined in `MANIFEST.md`. At
minimum, the manifest declares:

- The spec version the bundle targets
- A unique bundle identifier
- The bundle version
- A human-readable title
- The entry HTML file path
- The declared permissions

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
├── assets/                   (recommended for images, fonts, icons)
│   ├── icon.svg
│   └── ...
├── scripts/                  (recommended for JS files)
├── styles/                   (recommended for CSS files)
├── media/                    (recommended for audio/video)
└── data/                     (recommended for JSON/static data)
```

## 6. Reserved paths

The following paths at the archive root are reserved for future use by the
PortableWeb specification. Bundles **SHOULD NOT** create files at these
paths unless following an explicit PortableWeb sub-specification:

- `mimetype`
- `manifest.json`
- `META-INF/` (reserved for signature manifests, digests, and integrity data
  in future versions)
- `.well-known/` (reserved for future use)

## 7. Identification by viewers

A viewer **SHOULD** identify a file as a PortableWeb bundle if any of the
following are true:

1. The file extension is `.pweb`.
2. The file's media type is `application/vnd.portableweb+zip`.
3. The first ZIP entry is a STORED file named `mimetype` containing exactly
   `application/vnd.portableweb+zip`.

A viewer **SHOULD** reject any file claiming to be a PortableWeb bundle that
fails to validate against §4 of this specification.

## 8. Versioning

The container format is versioned independently from the runtime/sandbox
specification. This document describes container version **0.1**.

Future container versions **MUST** remain backwards compatible: a bundle
declaring `spec_version: 1.0` in its manifest **MUST** remain openable by
any future viewer that claims support for v1.0 bundles, indefinitely. New
features are added in new spec versions; old features are never removed.

This guarantee is the foundation of PortableWeb's archival promise.

## 9. Out of scope (for v0.1)

The following are intentionally not specified in this document and will be
addressed in companion specifications:

- The manifest schema in full detail → `MANIFEST.md`
- The runtime sandbox and security model → `SANDBOX.md`
- The frozen subset of web platform features per spec version → `RUNTIME-PROFILE.md`
- Cryptographic signing of bundles → `SIGNING.md`
- Storage, permissions, and user data → `STORAGE.md`

## 10. License

This specification is licensed under
[Creative Commons Attribution 4.0 International (CC-BY-4.0)](https://creativecommons.org/licenses/by/4.0/).

Reference implementations and example bundles published in the PortableWeb
repositories are licensed under the MIT License unless otherwise stated.

## 11. Changelog

- **0.1** (2026-05-24) — Initial draft. Defines container format, mimetype
  convention, manifest requirement, entry file requirement, and reserved
  paths. Companion specifications (MANIFEST, SANDBOX, RUNTIME-PROFILE) are
  forthcoming.
