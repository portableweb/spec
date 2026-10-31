# Android (AOSP): map `.pweb` to `application/vnd.portableweb+zip`

**Status (2026-10-31):**
- [x] Debian bug report sent to submit@bugs.debian.org (Package: media-types) — bug number: _waiting for the reply_
- [ ] Google issue tracker: request the mapping; mention the Debian bug number → gives the `Bug:` id
- [ ] AOSP change on android-review.googlesource.com (only if the issue doesn't get it added)

## Why

Android's Files app, Downloads and Drive look a file's type up by extension
in Android's built-in table (`MimeMap`). `.pweb` isn't in it, so a bundle is
handed to apps as `application/octet-stream` / ZIP: the "Open with" sheet
suggests archive apps first, and a viewer can only catch `.pweb` files by
claiming *all* ZIP and unknown files. With the mapping, providers report
`application/vnd.portableweb+zip`, and only apps that declare that type are
offered.

The type is registered with IANA in the vendor tree:
https://www.iana.org/assignments/media-types/application/vnd.portableweb+zip

## The change

File: `platform/frameworks/base` → `mime/java-res/android.mime.types`.

Format (from the file's header): each line maps a MIME type to extensions;
`?` before the type means "only set this type's default extension if it has
none" (putIfAbsent); the extensions themselves are always mapped to the type.
Add in alphabetical order among the `?application/vnd.*` lines:

```diff
 ?application/vnd.ms-wpl wpl
+?application/vnd.portableweb+zip pweb
 ?application/vnd.stardivision.impress sdp
```

(Neighbouring lines as of the revision checked; place it wherever sorts
correctly on `main`.)

Test: the MimeMap tests live under `frameworks/base/mime/tests/`; add
assertions next to the existing extension/type checks (verify the class name
on `main`):

```java
assertEquals("application/vnd.portableweb+zip", mimeMap.guessMimeTypeFromExtension("pweb"));
assertEquals("pweb", mimeMap.guessExtensionFromMimeType("application/vnd.portableweb+zip"));
```

## Commit message

```
Add MIME mapping for PortableWeb bundles (.pweb)

Map the extension .pweb to application/vnd.portableweb+zip, the media
type registered with IANA for PortableWeb bundles: self-contained,
ZIP-based interactive documents (CONTAINER.md, Internet-Draft
draft-selvaraj-portableweb-format).

Without this mapping, document providers report .pweb files as
application/octet-stream, so "Open with" offers archive apps and viewers
must register for all ZIP/unknown files to be offered at all.

IANA: https://www.iana.org/assignments/media-types/application/vnd.portableweb+zip
Spec: https://github.com/portableweb/spec

Bug: <issuetracker id>
Test: atest MimeMapTest
```

## How to submit

1. File an issue on https://issuetracker.google.com (Android Public Tracker →
   Framework) asking for the mapping; it gives the `Bug:` id. Link IANA and
   the spec.
2. Sign the Google CLA (individual) with the account used for Gerrit.
3. `repo init -u https://android.googlesource.com/platform/manifest -b main`
   is not needed for a one-line change: clone only `platform/frameworks/base`
   with the Gerrit commit-msg hook, commit, and
   `git push origin HEAD:refs/for/main`.
4. Add reviewers from `mime/OWNERS`.

## Second route: Debian `media-types`

AOSP's base table is imported from Debian's `mime.types` (AOSP's
`external/mime-support`), and Linux tools read it too. A merge request on
https://salsa.debian.org/debian/media-types adding

```
application/vnd.portableweb+zip			pweb
```

reaches Android at the next import, independent of the AOSP change. File
both; whichever lands first wins.

## Until then

Current phones never get this. The Android viewer keeps its fallback intent
filters (octet-stream / ZIP, checked in-app) and tells users to pick
"Just once", not "Always", for those types
(`viewer/packages/mobile/android/README.md`).
