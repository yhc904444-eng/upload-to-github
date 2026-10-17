# Windows GitHub Release

An agent skill for publishing Windows application source code and downloadable releases to GitHub, with optional npm distribution, Chrome authorization, careful packaging, and verification of downloads and installation.

The skill guides an agent through an existing project's release process. It reuses the project's build and test commands and keeps local user data and credentials out of published files.

## What it covers

- Check the target repository, active GitHub account, visibility, and version before publishing.
- Reuse an authenticated GitHub CLI session, or guide Chrome device authorization when needed.
- Build and package an application using an explicit file list.
- Commit reviewed files, push a version tag, and create a GitHub Release.
- Read back the remote commit, tag, release metadata, and asset SHA256 digest.
- Resume a partially completed release without overwriting existing assets or repeating successful steps.
- Package Windows applications as tested npm tarballs when npm distribution is requested.
- Handle separate npm web login and publishing verification, with the user completing identity checks and 2FA.
- Compare registry integrity metadata and verify installation without inherited credentials.

## Requirements

- Windows and PowerShell; the bundled helper supports Windows PowerShell 5.1 and PowerShell 7.
- Git and [GitHub CLI](https://cli.github.com/), installed or available as trusted portable tools.
- Google Chrome for the browser authorization workflow, if CLI authentication is needed.
- An agent environment that can read `SKILL.md`, run project commands, and keep an interactive CLI session alive. Browser automation requires a supported browser-control tool; otherwise, the user completes the device page manually.
- The application's existing build tools and permission to publish to the intended repository.
- Node.js and npm for npm distribution tasks; application-specific runtime requirements are determined from the project.

## Installation

Download the skill ZIP from [Releases](https://github.com/yhc904444-eng/windows-github-release/releases), extract it, and place the `windows-github-release` folder in your agent's configured skills directory. The folder must contain `SKILL.md` directly.

Alternatively, clone this repository and place the resulting folder in that directory:

```powershell
git clone https://github.com/yhc904444-eng/windows-github-release.git
```

Keep `SKILL.md`, `agents/`, `references/`, and `scripts/` together. Follow your agent host's instructions for discovering newly installed skills. Review any existing installation before replacing it.

## Usage

Invoke the installed skill with a concrete publishing request:

```text
Use $windows-github-release to publish this Windows application to
OWNER/REPOSITORY as v1.2.0. Use the existing build and packaging scripts,
create a GitHub Release, and verify the uploaded ZIP against its local SHA256.
```

For a first publication, also specify whether the new repository should be public or private. The skill asks only for missing decisions and reuses authorization already given in the conversation.

The agent inspects the project, verifies authentication, runs relevant checks, packages approved files, publishes the commit and tag, and verifies the downloadable release. If browser sign-in is required, the user completes identity checks and the final consent step.

### Optional npm distribution

Request npm distribution explicitly, including the package name and intended visibility:

```text
Use $windows-github-release to update this application's GitHub Release
and publish its tested Windows package to npm as PACKAGE-NAME@1.2.0.
The npm package should be public. Verify registry integrity, anonymous
installation, the command-line entry point, and preservation of user data.
```

The [npm runbook](references/npm.md) covers package contents, TGZ validation, Chrome web login, publishing 2FA, recovery, and anonymous installation. GitHub and npm authentication are checked independently. Download-only requests use existing packages without signing in or publishing. Updating this skill alone does not authorize npm publication.

The GitHub device-page helper is specific to GitHub. npm login and publishing use their own current CLI session links. If an application tarball is distributed through GitHub rather than the npm registry, the result is identified as a GitHub-hosted npm-installable package.

## Chrome helper

Preview the detected Chrome executable and official device URL without opening a browser:

```powershell
.\scripts\open-github-device.ps1 -PlanOnly
```

Open the official device page when an active GitHub CLI authorization session needs it:

```powershell
.\scripts\open-github-device.ps1
```

For a nonstandard installation, supply an existing absolute Chrome path:

```powershell
.\scripts\open-github-device.ps1 -ChromePath 'C:\Program Files\Google\Chrome\Application\chrome.exe' -PlanOnly
```

The helper accepts only `https://github.com/login/device`, without credentials, query parameters, or fragments. It supports `-WhatIf`. Opening the page does not generate a code or prove that authentication succeeded; the agent must verify the original CLI session and API response.

## Release boundaries

Publishing requires an explicit user request. Preparing files or inspecting commands alone does not authorize an upload. Existing repository visibility and release assets are preserved unless a change is explicitly authorized.

Packages exclude private application data, progress, backups, logs, keys, tokens, `.npmrc`, and unapproved installers. Persistent application data stays outside npm installation and cache directories. The workflow does not print access tokens, bypass browser security checks, force-push tags, or overwrite release assets by default.

## Repository layout

```text
SKILL.md                          Agent instructions and workflow entry point
agents/openai.yaml                Skill display metadata and default prompt
references/device-auth.md         GitHub CLI and Chrome authorization runbook
references/publish.md             Commit, tag, publish, and verification runbook
references/npm.md                 npm packaging, web login, 2FA, and installation
references/windows-app-example.md Generic Windows application release example
scripts/open-github-device.ps1    Official device-page launcher
CHANGELOG.md                      Version history
```

## References

- [GitHub CLI authentication](https://cli.github.com/manual/gh_auth_login)
- [GitHub CLI environment variables](https://cli.github.com/manual/gh_help_environment)
- [GitHub OAuth device flow](https://docs.github.com/en/apps/oauth-apps/building-oauth-apps/authorizing-oauth-apps#device-flow)
- [npm login](https://docs.npmjs.com/cli/v11/commands/npm-login/)
- [npm publish](https://docs.npmjs.com/cli/v11/commands/npm-publish/)
- [npm two-factor authentication](https://docs.npmjs.com/configuring-two-factor-authentication/)
