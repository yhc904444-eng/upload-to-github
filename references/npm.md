# npm Packaging, Authorization, and Downloads

Use this runbook when a user requests npm installation or distribution of a Windows application. Select only the phases needed for the task: downloading an existing package does not require sign-in or publication, and updating this skill alone does not authorize real npm authentication or publication.

## Scope, environment, and application wrapper

Read the package name, version, registry, publishing account, visibility, and existing scripts from the current project. Reuse decisions already made by the user. Investigate name or ownership conflicts before proposing another package name; do not register under a different account or make a package public without authorization. An application's display name may contain spaces, but the npm name must follow registry rules. An `npm view` E404 alone does not establish that a name can be registered.

Locate the actual Node.js, npm, and Chrome executables. In PowerShell, prefer `npm.cmd`, `npx.cmd`, and installed `.cmd` entry points instead of changing system script policy. Inspect current connectivity; use an existing verified proxy only for the relevant process when necessary. Do not change the global registry or disable TLS verification. Explicitly use the official registry for publication and verification to avoid confusing mirror delays with missing releases.

Reuse the application's build process. Choose an appropriate wrapper for a native Windows application: either include verified program files or use a downloader with a clear source and integrity verification. When the user has not chosen, evaluate bundling first to reduce installation dependencies. Set accurate `os`, Node.js engine requirements, `bin`, `files`, repository links, and license information. Do not select an open-source license for original code without authorization; preserve third-party licenses.

A launcher should start the application with a separate argument array and `shell: false`, handle paths with spaces, and report exit and startup errors. Keep persistent records in a stable user-data directory outside global installation directories and the npx cache. Explain migration or data-directory selection for an older portable installation without automatically overwriting records.

## Prepare a reviewable TGZ

Use an explicit package file list and inspect both `files` and the actual tar entries. Do not package a previously used installation directory wholesale. Exclude `.npmrc`, tokens, passwords, logs, user data, backups, private content, original APKs, and unapproved resources. Inspect unexpected generated files rather than hiding them through recursive deletion.

Resolve `$packageDir`, `$releaseDir`, `$tarball`, `$packageName`, `$version`, and `$chromeExe` from the actual project and command outputs. The following commands are examples, not evidence that a build has passed:

```powershell
npm.cmd pack $packageDir --dry-run --json
npm.cmd pack $packageDir --pack-destination $releaseDir --json
tar.exe -tf $tarball
Get-FileHash -LiteralPath $tarball -Algorithm SHA256
```

Review lifecycle scripts before packing; do not assume a dry run is free of side effects. Check actual archive contents, application version, licenses, and size. Compute and retain the TGZ's SHA512 SRI value: `sha512-` followed by the Base64-encoded digest. An executable hash and its containing TGZ hash serve different purposes and must not be interchanged.

Validate the launcher, path handling, and actual application startup in isolated directories with fictional data. For applications with persistent records, verify that upgrading or uninstalling does not remove them. Close only test processes started by this task. Publish the exact tested TGZ rather than rebuilding unverified content during publication.

## npm account and Chrome web authorization

1. Run `npm.cmd whoami --registry=https://registry.npmjs.org` to check CLI authentication. Browser or GitHub sign-in does not prove npm CLI sign-in. A network error does not prove that the user is signed out. Confirm that the account matches the publishing scope.
2. If an account is needed, open the official [signup page](https://www.npmjs.com/signup). Let the user set a password, verify email, and accept terms. If the registration page returns JSON `Not Found`, inspect the actual page and official URL and allow the user to complete registration. Do not collect passwords or repeatedly reopen the same failing page.
3. Start web login in a persistent terminal and retain its session handle:

   ```powershell
   npm.cmd login --auth-type=web --registry=https://registry.npmjs.org --browser=$chromeExe
   ```

4. Read the current CLI's session URL, which may use a form such as `https://www.npmjs.com/login?next=/login/cli/SESSION-ID`. If prompted to press Enter, send it to that same terminal so the CLI opens Chrome. This is an npm session link, not a GitHub device code. Never pass it to `open-github-device.ps1`. Check HTTPS and the official domain, and do not persist real session URLs in documentation or logs.
5. When browser control is available, read the tool's instructions and observe the current page before ordinary navigation. Let the user handle passwords, email verification, 2FA, Windows Hello, passkeys, and final consent. Without browser control, provide the current CLI URL and keep the CLI waiting while the user opens it. Starting a browser process does not prove that the page loaded or authorization succeeded.
6. After the user reports completion, read the original terminal until it exits and verify `whoami` against the official registry. Continue independent package checks while waiting; do not run multiple login flows concurrently.

If the flow falls back to `Username:`, returns `ENYI`, or expires, inspect the actual error and connectivity. End only the task-owned failed session before creating a replacement. Do not ask for passwords in chat or reuse an old link. If the same error remains after one targeted retry, report the blocker and preserve the prepared package instead of retrying indefinitely.

Do not print `.npmrc` or tokens. A field-filtered `npm profile get tfa --json` can return more profile data than expected. If a 2FA check is necessary, capture and parse JSON internally and output only the required mode or status. Do not place raw account profiles or email addresses in logs or deliverables.

## Publish, verify identity, and recover

Before publication, query the exact `name@version`. If it exists, compare integrity: continue verification if it matches, or stop and establish a new version if it differs. Never overwrite an existing package version or try to reuse it after unpublishing. Do not resolve conflicts by deleting releases, force-pushing, moving old tags, or exposing credentials.

```powershell
npm.cmd view "$packageName@$version" version dist.integrity dist.shasum dist.tarball --json --registry=https://registry.npmjs.org
npm.cmd publish $tarball --access=public --registry=https://registry.npmjs.org --browser=$chromeExe
```

Use `--access=public` only when public npm publication is authorized. For a prepared TGZ that needs no publishing hooks, `--ignore-scripts` may be appropriate. Inspect required scripts before deciding; do not apply that flag universally.

| Observed state | Next action |
| --- | --- |
| E403 explicitly requests 2FA or a granular token that bypasses 2FA | Read the exact error. Prefer user-managed 2FA in official account settings; do not default to a long-lived bypass token. For an ordinary permission error, check package ownership and the account. |
| The user has not enabled required 2FA | Follow the current official account settings to enable it. Let the user configure the supported authenticator or passkey and store recovery codes themselves. Do not collect those codes. |
| The publish process displays a current `https://www.npmjs.com/auth/cli/SESSION-ID` URL and an Enter prompt | Treat it as separate publishing verification. Continue in that same publishing process while the user verifies identity. Do not restart `publish` as a substitute for consent. |
| Timeout, disconnect, or uncertain return | Query the official registry's exact version and integrity before deciding whether a retry is needed. An error does not prove that nothing was published. |
| CLI success followed by processing or a temporary E404 | Retry reads with bounded delays of several seconds to tens of seconds. If it remains unavailable, report submission without verified downloads and do not republish the same version. |

## Official readback and anonymous installation

Publication is complete only when the official registry metadata is readable and anonymous download and installation succeed. Read the exact version, `dist.tarball`, `dist.integrity`, and `dist.shasum`. Compare remote SHA512 SRI to the tested TGZ; store any downloaded verification copy separately.

For anonymous verification, use a blank temporary user config, new cache, and independent installation prefix. Also remove inherited npm authentication configuration from the test subprocess. Never rewrite the user's credentials. A credential-free HTTP request can cross-check the public tarball. Do not call a token-authenticated installation anonymous.

```powershell
# These paths belong to an isolated test directory; $emptyConfig is a blank file.
npm.cmd install --global "$packageName@$version" --registry=https://registry.npmjs.org --userconfig=$emptyConfig --cache=$cacheDir --prefix=$prefixDir --no-audit --no-fund
```

Review install scripts first. If the package needs no hooks, validation may use `--ignore-scripts`; if hooks are required, validate the real installation flow in isolation. Run the installed entry point and check version, program integrity, and actual startup. Use the real package's documented flags and a separate data directory. Clean up only verified test paths, leaving actual user records untouched.

Provide `npm.cmd install --global PACKAGE-NAME`, its actual entry point, and, when useful, `npx.cmd --yes --package=PACKAGE-NAME@VERSION ENTRY-POINT`. Verify these against the package's `bin` metadata. Users downloading public packages do not need npm accounts. Explain actual Windows, Node.js, and native runtime requirements.

If registry publication is blocked, an already authorized GitHub Release may host the same tested TGZ. Verify installation from its actual download URL. Identify it as a GitHub-hosted npm-installable package; do not claim npm registry publication.

Update README and release installation instructions only after validation. Read the latest remote state before pushing and preserve concurrent user changes. Adding npm distribution does not require moving an existing application version tag. Report GitHub publication, npm publication, and installation validation separately, with real links and necessary data-migration instructions.

## Official references

- [npm login](https://docs.npmjs.com/cli/v11/commands/npm-login/)
- [Create an npm account](https://docs.npmjs.com/creating-a-new-npm-user-account/)
- [npm publish, version uniqueness, and integrity](https://docs.npmjs.com/cli/v11/commands/npm-publish/)
- [Configure two-factor authentication](https://docs.npmjs.com/configuring-two-factor-authentication/)

Authentication policies and pages can change. Resolve differences through current official documentation and observed CLI prompts rather than treating a previous project's flow as a permanent rule.
