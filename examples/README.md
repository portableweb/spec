# PortableWeb Examples

Reference bundles demonstrating the PortableWeb format.

## hello.pweb

The simplest valid PortableWeb bundle. Three files in a ZIP:

- `mimetype` — identifies this as a PortableWeb bundle (uncompressed, first entry)
- `manifest.json` — bundle metadata (id, version, title, permissions, etc.)
- `index.html` — the entry page; renders a small welcome with a live clock and a tap-to-count interaction

This bundle proves the format end-to-end: container layout, manifest schema,
HTML/CSS/JS execution in the sandbox.

### Inspect it

A `.pweb` is just a ZIP, so any standard tool can look inside:

```bash
# List contents
unzip -lv hello.pweb

# Extract everything
unzip hello.pweb -d hello-extracted/

# Read a single file without extracting
unzip -p hello.pweb manifest.json
```

### Preview it as a regular web page

Until the PortableWeb viewer ships, you can preview the contents in any browser:

```bash
unzip hello.pweb -d /tmp/hello && open /tmp/hello/index.html
```

(Note: this bypasses the sandbox the viewer will enforce. Treat it as a
preview only.)

### Build it yourself

The unpacked source is in `hello-source/`. To rebuild the bundle:

```bash
../scripts/build-pweb.sh hello-source hello.pweb
```

The build script enforces the correct ZIP layout (mimetype first, uncompressed,
no extra fields).

## More examples coming

Future bundles in this directory will demonstrate:
- A complete interactive presentation
- A small game using Canvas / WebGL
- A bundle with persistent local storage
- A bundle that requests permissions
- A signed bundle

If you build something interesting in `.pweb`, open a PR.
