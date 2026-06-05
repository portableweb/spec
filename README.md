# PortableWeb

> An open file format for self-contained, sandboxed, interactive documents.
> Like PDF, but interactive. Like a webpage, but a file you own.

**File extension:** `.pweb`  ·  **Media type:** `application/vnd.portableweb+zip`  ·  **Status:** v0.1 draft

---

## What is PortableWeb?

A **PortableWeb bundle** (`.pweb`) is a single file containing all the HTML,
CSS, JavaScript, and media needed to render an interactive document. It opens
in a compatible viewer, sandboxed from the host system and offline-first by
default.

The format is designed for:

- **Interactive presentations** — the natural successor to PDF for content that's more than just text
- **AI-generated artifacts** — a real home for the millions of interactive things AI tools create
- **Educational explainers** — interactive lessons that work offline and don't need a server
- **Personal tools** — journals, calculators, planners you keep as files instead of subscriptions
- **Archival of interactive work** — a single file that still renders 20 years from now

## Design principles

1. **Self-contained.** A bundle contains everything it needs. No CDN, no network, no broken dependencies in five years.
2. **Sandboxed.** No filesystem access, no surveillance APIs, network off by default. Permissions declared upfront in the manifest.
3. **Archival.** Each spec version is a frozen subset of web platform features. v1.0 bundles render correctly in any v1.0-compatible viewer, forever.
4. **Owned.** A bundle is a file. You can email it, copy it, archive it. No host, no account, no subscription.
5. **Open.** Spec under CC-BY 4.0. Reference implementations under MIT. No vendor lock-in.

## Repository layout

```
spec/         The PortableWeb specification documents
examples/     Reference bundles (start with hello.pweb)
scripts/      Build and validation tools
```

## Quick start

**Look inside the first bundle:**

```bash
unzip -lv examples/hello.pweb
```

**Build your own from a source folder:**

```bash
./scripts/build-pweb.sh my-source-folder/ my-bundle.pweb
```

**Read the spec:**

- [Container format](spec/CONTAINER.md) — ZIP layout, required files, identification
- [Manifest schema](spec/MANIFEST.md) — `manifest.json` fields and validation

## Status & roadmap

This is **v0.1**. The container and manifest specs are stable enough to build
real bundles against, but breaking changes may occur before v1.0.

Next milestones:

- **v0.2** — Sandbox model and runtime profile specs; first reference viewer (Tauri-based, cross-platform)
- **v0.3–0.9** — Iteration based on real-world use; CLI validator; mobile viewers; integrations with AI authoring tools
- **v1.0** — Stable spec. From v1.0 onward, all bundles remain renderable forever.

See `spec/README.md` for the full roadmap.

## How does this differ from…

- **A regular webpage** — PortableWeb is a *file*, not a URL. It works offline, doesn't depend on a host, and can be archived. Bundles are sandboxed more aggressively than browser pages.
- **A PWA (Progressive Web App)** — PWAs install from a URL and require ongoing hosting. PortableWeb files are self-contained documents that work without any server.
- **An EPUB** — EPUB is technically similar (zip of HTML/CSS/JS), but EPUB readers don't reliably run JavaScript, and the ecosystem treats EPUBs as books, not interactive documents. PortableWeb is designed from day one for full interactivity.
- **A PDF** — PDF is great for static documents. PortableWeb is the interactive equivalent — with a similar archival promise.

## Get involved

- Read the [spec](spec/)
- Try [hello.pweb](examples/hello.pweb)
- Build a bundle and open a PR adding it to `examples/`
- File issues with feedback on the v0.1 draft

## Trademark

PortableWeb™ is claimed as a trademark by the PortableWeb project creator.

The .pweb file format is intended to be an open specification.

Use of the name PortableWeb must not imply endorsement, certification, or official status unless authorized.

Truthful statements such as "supports .pweb files" are permitted.

## License

- Specification: [CC-BY 4.0](https://creativecommons.org/licenses/by/4.0/)
- Reference code and examples: [MIT](LICENSE) unless otherwise stated

## Author

Created and maintained by **Omprakash Selvaraj** ([@omscse](https://github.com/omscse)).
The PortableWeb project lives at [portableweb.org](https://portableweb.org).
