# Commit and Publish

Resolve `$gh`, `$projectRoot`, `$repo` (`OWNER/REPOSITORY`), `$branch`, `$tag`, `$zip`, and `$notes` from the current project and the user's established target. Do not copy placeholder values from an example into a real release.

1. Inspect `git status --short`, remotes, existing tags, and the latest remote commit. Do not silently repoint an existing remote. Resolve repository access problems first. Initialize Git only in the intended project directory when necessary. For a new repository, reuse the user's selected visibility; ask if it has not been selected.
2. Build, test, and package through the existing project scripts. Verify that source and package versions match. Report the checks actually run, rather than historical test counts.
3. Stage explicit paths with `git add -- ...`. Review `git diff --cached --check` and the staged file list. `.gitignore` does not remove already tracked private files. Inspect all history about to be pushed, too. If it contains credentials or private records, stop the first public push and prepare a reviewable cleanup proposal; do not rewrite the user's history without authorization.
4. Commit and create an unused version tag. If the tag exists, compare its target; do not move or force-push it. If an asset with the same name exists, compare its digest instead of overwriting it. Push the new commit and tag normally, atomically when supported.
5. Create a release using notes from a file:

   ```powershell
   & $gh release create $tag $zip --repo $repo --verify-tag --title $title --notes-file $notes
   ```

   Choose draft, prerelease, and latest status according to the request. Do not change unrelated historical releases. After an upload timeout, query the existing release and assets before retrying. Upload only missing assets; do not default to `--clobber`.

6. Read back the remote state, using verified API path components:

   ```powershell
   & $gh api "repos/$repo/branches/$branch" --jq .commit.sha
   & $gh api "repos/$repo/releases/tags/$tag" --jq '{html_url,draft,prerelease,tag_name,assets:[.assets[]|{name,size,digest,browser_download_url}]}'
   ```

   URL-encode special characters in branch or tag names. Do not construct API paths from unreviewed external text. Resolve annotated tags to their actual commits. Compare asset names, sizes, and digests with the local package. If a digest is unavailable, use `gh release download` into an independent directory and compare SHA256 values.

7. Confirm the local Git status and provide the version, links, and actual validation. If only part of the publication succeeded, identify the completed commit, tag, or release and the missing step. Do not claim a complete delivery while the download remains unverified.

Use UTF-8 with BOM for PowerShell scripts that must support Windows PowerShell 5.1. Save multiline release notes in a UTF-8 file. JSON serialization is not shell escaping. Limit environment changes to the relevant child process and restore temporary changes in a reused shell.
