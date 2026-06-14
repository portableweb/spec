<div align="center">

<img src="https://raw.githubusercontent.com/portableweb/.github/main/profile/flow.svg" alt="The PortableWeb loop: you ask an AI to build interactive web content, it is generated, you pack it as a single .pweb file, and it runs everywhere — phone, Mac, PC, or shared with a friend." width="100%" />

<br /><br />

# PortableWeb — Specification

**The format spec for `.pweb`: one self-contained file for interactive content built with web technology — runs on any device, fully offline.**

This repository holds the **specification**, **reference examples**, and the **IETF draft source**. For the project's story and the web app, visit **[portableweb.org](https://portableweb.org)**.

[![Website](https://img.shields.io/badge/portableweb.org-0b0b15?style=flat-square&labelColor=0b0b15&color=7c3aed)](https://portableweb.org)
[![Spec](https://img.shields.io/badge/spec-v0.1%20draft-9f67f5?style=flat-square)](spec/)
[![IETF Internet-Draft](https://img.shields.io/badge/IETF-Internet--Draft-20d6d2?style=flat-square&labelColor=333)](https://datatracker.ietf.org/doc/draft-selvaraj-portableweb-format/)
[![W3C Community Group](https://img.shields.io/badge/W3C-Community%20Group-005a9c?style=flat-square)](https://www.w3.org/community/portableweb/)
[![Spec License](https://img.shields.io/badge/spec-CC--BY%204.0-444?style=flat-square)](https://creativecommons.org/licenses/by/4.0/)
[![Code License](https://img.shields.io/badge/code-MIT-444?style=flat-square)](LICENSE)

</div>

---

## What is PortableWeb?

A **PortableWeb bundle** (`.pweb`) packages the HTML, CSS, JavaScript, and media of an interactive experience into **one file**. A compatible viewer opens it in its own sandboxed window — on desktop, mobile, or anywhere — entirely offline, with no deployment, no Web origin, and no browser required.

It behaves like a document: save it, copy it, email it, archive it. The format is **content-model agnostic** — a bundle can hold a game, a presentation, a simulation, a 3D experience, a scientific model, a report, or a book.

> Looking for the **normative text**? It lives in [`ietf/`](ietf/) and is published as an IETF Internet-Draft: **[draft-selvaraj-portableweb-format](https://www.ietf.org/archive/id/draft-selvaraj-portableweb-format-01.html)**. This README is a map, not the spec itself.

## The format at a glance

|                         |                                                                            |
| ----------------------- | -------------------------------------------------------------------------- |
| **File extension**      | `.pweb`                                                                    |
| **Media type**          | `application/vnd.portableweb+zip`                                          |
| **Container**           | ZIP (with a `mimetype` entry as the first, uncompressed file — as in EPUB) |
| **Required inside**     | `mimetype`, `manifest.json`, and an HTML entry file                        |
| **Default permissions** | Deny-by-default (only scoped storage and fullscreen on)                    |
| **Identifiable**        | From the first ~80 bytes, without unpacking                                |

## Repository layout

```text
.
├── spec/         The specification documents — start here
│   ├── README.md     Index + roadmap of all spec documents
│   ├── CONTAINER.md  The file format: ZIP layout, mimetype, required entries
│   └── MANIFEST.md   The manifest.json schema: required & optional fields
├── ietf/         The IETF Internet-Draft source (kramdown-rfc)
├── examples/     Runnable reference bundles
│   ├── hello.pweb        The simplest valid bundle
│   └── hello-source/     Its unpacked source, ready to rebuild
├── scripts/
│   └── build-pweb.sh     Packs a folder into a spec-correct .pweb
└── LICENSE       MIT (covers the tooling/code in this repo)
```

## Start here

1. **Read the spec** — [`spec/CONTAINER.md`](spec/CONTAINER.md) for the file format, then [`spec/MANIFEST.md`](spec/MANIFEST.md) for the manifest schema. The [`spec/README.md`](spec/README.md) index lists everything, including the planned companion specs.
2. **Inspect a real bundle** — a `.pweb` is just a ZIP:
   ```bash
   unzip -lv examples/hello.pweb        # list contents
   unzip -p  examples/hello.pweb manifest.json   # read one file
   ```
3. **Preview it** (bypasses the viewer sandbox — preview only):
   ```bash
   unzip examples/hello.pweb -d /tmp/hello && open /tmp/hello/index.html
   ```
4. **Build your own** from a folder:
   ```bash
   scripts/build-pweb.sh examples/hello-source my-bundle.pweb
   ```
   The script enforces the correct ZIP layout (mimetype first, uncompressed, no extra fields).

## Specification documents

| Document                          | Status    | Description                                                 |
| --------------------------------- | --------- | ----------------------------------------------------------- |
| [CONTAINER.md](spec/CONTAINER.md) | Draft 0.1 | The file format: ZIP layout, `mimetype`, required entries.  |
| [MANIFEST.md](spec/MANIFEST.md)   | Draft 0.1 | The `manifest.json` schema: required and optional fields.   |
| `SANDBOX.md`                      | Planned   | The runtime sandbox and permission-enforcement model.       |
| `RUNTIME-PROFILE.md`              | Planned   | The frozen subset of HTML/CSS/JS allowed per spec version.  |
| `STORAGE.md`                      | Planned   | Storage isolation, quotas, export/import, snapshot bundles. |
| `SIGNING.md`                      | Planned   | Optional cryptographic signing of bundles.                  |
| `COMMS.md`                        | Planned   | Inter-bundle communication over local channels (`peers`).   |

## Status & roadmap

> ⚠️ **Pre-release.** This is **v0.1 (draft)** — the container and manifest only. Breaking changes may occur until v1.0.

- **v0.1** — Container and manifest _(this release)_
- **v0.2** — Add `SANDBOX` and `RUNTIME-PROFILE`; first viewer reference implementation
- **v0.3 – v0.9** — Iterate on real-world usage; gather feedback from early adopters
- **v1.0** — Stable spec. From v1.0 onward, every bundle stays renderable forever; new features ship in v1.x / v2.x without breaking v1.0 bundles.

## Standards, built in the open

- 🌐 **[W3C Community Group](https://www.w3.org/community/portableweb/)** — _Portable Web Content Format CG._ Container, manifest, viewer conformance, storage, and a permission-gated offline peer-to-peer channel. Anyone may join; W3C membership is not required.
- 📜 **[IETF Internet-Draft](https://datatracker.ietf.org/doc/draft-selvaraj-portableweb-format/)** — `draft-selvaraj-portableweb-format` defines the container, manifest schema, security considerations, and the `application/vnd.portableweb+zip` media type.

## Contributing

The format is still in **draft**, which is exactly when feedback shapes it most.

- 🐛 **Open an issue** — questions, ambiguities, and proposals are all welcome.
- 🔧 **Send a PR** — corrections and clarifications to the spec, new examples, or tooling.
- 🧪 **Build a `.pweb`** and share it — real-world usage drives the spec far more than theory. If you make something interesting, add it to [`examples/`](examples/) via PR.
- 🌐 **[Join the W3C CG](https://www.w3.org/community/portableweb/join)** to help standardize it.

## License

- **Specification text** — [CC-BY 4.0](https://creativecommons.org/licenses/by/4.0/). Share and adapt with attribution.
- **Code & tooling** in this repo — [MIT](LICENSE).

<div align="center">
<br />
<sub><a href="https://portableweb.org">portableweb.org</a> · <a href="https://www.w3.org/community/portableweb/">W3C CG</a> · <a href="https://datatracker.ietf.org/doc/draft-selvaraj-portableweb-format/">IETF Draft</a></sub>
</div>
