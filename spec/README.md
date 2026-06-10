# Portable Web Content Format (PortableWeb) — Specification

This directory contains the official specifications for the Portable Web Content
Format (PortableWeb) — a file format for packaging interactive web content into
a single self-contained, portable bundle.

## Current version: 0.1 (Draft)

> ⚠️ **Pre-release.** Breaking changes may occur until v1.0.

The specification is available as an IETF Internet Draft:
[draft-selvaraj-portableweb-format-01](https://www.ietf.org/archive/id/draft-selvaraj-portableweb-format-01.html)

## Documents

| Document | Status | Description |
|---|---|---|
| [CONTAINER.md](CONTAINER.md) | Draft 0.1 | The file format: ZIP layout, mimetype, required entries. |
| [MANIFEST.md](MANIFEST.md) | Draft 0.1 | The `manifest.json` schema: required and optional fields. |
| `SANDBOX.md` | Planned | The runtime sandbox and permission enforcement model. |
| `RUNTIME-PROFILE.md` | Planned | The frozen subset of HTML/CSS/JS allowed in each spec version. |
| `STORAGE.md` | Planned | Storage isolation, quotas, export/import, snapshot bundles. |
| `SIGNING.md` | Planned | Optional cryptographic signing of bundles. |
| `COMMS.md` | Planned | Inter-bundle communication via local channels (e.g. `peers` permission). |

## Quick reference

- **File extension:** `.pweb`
- **Media type:** `application/vnd.portableweb+zip`
- **Container:** ZIP (with `mimetype` entry as first uncompressed file)
- **Required files inside:** `mimetype`, `manifest.json`, entry HTML
- **Default permissions:** all denied (except scoped storage and fullscreen)

## Roadmap

- **v0.1** — Container and manifest only (this release)
- **v0.2** — Add SANDBOX and RUNTIME-PROFILE; first viewer reference implementation
- **v0.3 – v0.9** — Iterate on real-world usage; gather feedback from early adopters
- **v1.0** — Stable spec. From v1.0 onward, all bundles remain renderable
  forever; new features ship in v1.x and v2.x without breaking v1.0 bundles.

## License

The PortableWeb specification is licensed under
[CC-BY 4.0](https://creativecommons.org/licenses/by/4.0/). You are free to
share and adapt it with attribution.

## Contributing

The spec is developed in the open at
[github.com/portableweb/spec](https://github.com/portableweb/spec).
Feedback, issues, and PRs are welcome.
