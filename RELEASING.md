# Releasing a Spec Revision

One rule governs everything here:

> **A normative sentence is only ever *edited* in `spec/*.md` in this
> repository.** Every other copy of the spec — the IETF Internet-Draft
> revisions, the W3C CG report, the portableweb.org spec page — is either a
> dated snapshot cut from this repository or a generated rendering, and each
> carries a banner saying so. Flow is one-directional: changes land here,
> then propagate outward. Never edit a snapshot to fix the spec.

## The four surfaces

| Surface | Role | How it changes |
|---|---|---|
| `spec/*.md` (this repo) | **Canonical, living, normative.** | Direct edits. Normative changes land with their conformance fixtures where applicable. |
| `ietf/draft-*-NN.md` (this repo) | Frozen snapshot per IETF submission. | Cut from `spec/*.md` at a tag. Once submitted to the datatracker, never edited again — corrections go into the *next* `-NN`. |
| `w3c-cg/portableweb` → `spec/index.html` | Dated Draft CG Report snapshot (ReSpec). | Regenerated from `spec/*.md` at the same tag as the corresponding I-D revision. Also hosts CG-only material (charter, meetings, tests) that this repo does not own. |
| `portableweb/web` → `docs/spec/index.html` | Website rendering for portableweb.org/spec/. | Rebuilt from `spec/*.md` content at release time. Never hand-edited for normative content. |

## Release checklist

When a batch of spec changes is ready to publish:

1. **Settle the text here.** All normative edits merged into `spec/*.md`
   on the release branch; changelogs in each touched file updated;
   breaking changes explicitly marked.
2. **Tag** this repo: `spec-vX.Y-draft.N` (e.g. `spec-v0.2-draft.1`).
3. **Cut the Internet-Draft** (when an IETF submission is warranted —
   not every tag needs one):
   - Assemble `ietf/draft-selvaraj-portableweb-format-NN.md` from the
     tagged `spec/*.md` content.
   - Update the "Changes from Version NN-1" appendix.
   - Build with kramdown-rfc (`kdrfc` locally, or
     [author-tools.ietf.org](https://author-tools.ietf.org/)) and fix
     warnings.
   - Submit to the datatracker. From this moment the `-NN` file is
     frozen.
4. **Regenerate the CG snapshot:** update `w3c-cg/portableweb`'s
   `spec/index.html` from the tagged content, set its snapshot-banner
   date and version, link the new I-D revision.
5. **Rebuild the website rendering:** update `web/docs/spec/index.html`
   from the tagged content, set its snapshot-banner version, deploy.
6. **Check for stragglers:** grep all four surfaces for the old version
   string and stale draft-revision links.

## Reconciliation debt

If a snapshot is ever found to contain normative content that this repo
lacks (it has happened — the CG draft's `internet.read`/`internet.write`
split predated its adoption here), the fix is always: decide, land it
*here* first, then regenerate the snapshot. Do not "fix" this repo by
copying snapshot text without an explicit decision recorded in a
changelog.
