# GitHub CLI Device Authorization

## 1. Check existing authentication

Locate an existing `gh.exe` on PATH or in a trusted project-local portable installation. Do not install it globally without authorization. Run `gh auth status --hostname github.com` and `gh api user --jq .login`. Confirm that the active account can access the intended repository; an organization owner need not match the user login.

A signed-in browser does not prove that the CLI is authenticated. If CLI and API checks already succeed, do not generate a new code or sign out to rehearse the process. Detect whether `GH_TOKEN` or `GITHUB_TOKEN` exists without printing its value; environment tokens can override stored credentials. Address an account or permission problem directly instead of repeatedly signing in or requesting broader scopes.

## 2. Maintain one live authorization session

Start authentication in a persistent interactive terminal or PTY:

```powershell
& $gh auth login --hostname github.com --git-protocol https --web
```

Retain the returned terminal session ID and use that same session for subsequent reads and input. Do not claim that a one-shot shell is still waiting after it has exited. Respond to actual prompts about Git credentials and opening a browser; do not send keystrokes based on assumptions. Do not create or upload SSH keys or request unnecessary scopes.

Read the current user code and official verification URL from this CLI session. Remember when the code was issued. Do not reuse codes from conversation history, screenshots, examples, or other processes. Enter only the short user code, never an OAuth `device_code` or access token.

Keep the code in the current execution context. Show it to the user only when needed. Do not write it to skill files, source code, release notes, log files, URL parameters, or the clipboard by default. Let GitHub CLI handle token exchange and polling.

## 3. Open the official page in Chrome

Prefer the user's specified Chrome session when the available tool can control it. Use the user's normal signed-in browser profile. Do not describe an embedded browser as Chrome or create an unrelated sign-in profile.

If the CLI should launch Chrome itself, set `GH_BROWSER` only for the relevant process, using an already verified executable path. Preserve quotes around a path containing spaces:

```powershell
# $chrome is an existing, verified absolute path.
$env:GH_BROWSER = '"' + $chrome + '"'
```

Observe the actual CLI prompt before pressing Enter. If automatic opening fails while the CLI is still waiting, use the browser tool or `scripts/open-github-device.ps1` to open `https://github.com/login/device`. Continue the same CLI session and code. Restore temporary environment changes in any reused shell.

Opening a page does not prove that it loaded. Read the current tab's URL and content through the browser tool. For the ordinary github.com flow, enter the user code only on HTTPS `github.com`. Investigate look-alike domains, certificate warnings, and unexpected redirects before proceeding. Confirm a user-specified GitHub Enterprise hostname separately; the bundled launcher supports github.com only.

Read the browser tool's entry-point instructions and returned runtime documentation before interacting with a Chrome tab. If only native Windows control is available, first read the installed computer-use skill and required guidance, and verify that the capability is enabled. Do not substitute SendKeys, injected scripts, guessed coordinates, or browser credential-store access for supported page interaction.

## 4. Complete identity checks, code entry, and consent

Use the currently observed page state:

| Page state | Action |
| --- | --- |
| Sign-in, Verify Session, password, passkey, CAPTCHA, or 2FA | Ask the user to complete this step in the Chrome window. Do not request, collect, or store passwords or verification codes, or bypass the check. Keep the CLI session alive. |
| Device-code form | Locate the actual editable controls. Enter the full current code in a single field, or distribute characters according to a segmented form. Do not put hyphens into single-character fields. |
| Code entered | Read back the visible values and compare them with the current code. Correct errors before selecting the page's actual Continue control. Do not repeatedly submit an unknown code. |
| Application consent | Verify the expected GitHub CLI application, account, and permissions. Let the user complete final consent. Record that consent is pending and avoid repeating the same request. |
| Success or connected | Read the original CLI session's completion result, then verify the API response. Page success alone is insufficient. |

Use observed DOM/accessibility controls or screenshot evidence. Do not hard-code control indexes. Refresh page state after navigation or after the user completes identity verification. When the user says authorization is complete, check the CLI and API before asking for more actions or uploading files.

When user action is necessary, explain the window, current step, and completion signal together. Include the current code and official link if code entry is still pending. If consent is already displayed, ask the user to review and approve that page directly. Continue independent build, documentation, and packaging work while waiting. Do not abandon the live process or create a scheduled task to replace it.

## 5. Verify authentication and credential handling

Wait for the original `gh auth login` process to complete. Run `gh auth status --hostname github.com` and `gh api user --jq .login` again. Verify the active account and repository access before publishing. Browser cookies, a success page, a user reply, or an opened tab cannot replace CLI/API evidence.

Never print a token with `gh auth token` or use `--insecure-storage`. GitHub CLI can fall back to a plaintext file if its credential store is unavailable. If that happens, explain the observed storage issue and resolve it or let the user select an appropriate method. Do not describe plaintext storage as secure authentication.

## 6. Recover according to the observed state

| Observed problem | Recovery |
| --- | --- |
| Page temporarily unavailable; CLI still waiting | Check the official address, current Chrome tab, and connectivity. Reopen the page once and continue with the current code. |
| Unsafe-app warning, certificate error, or repeated sign-in loop | Record the actual message. Use the normal Chrome profile and official URL, and let the user complete verification. Do not disable browser checks or change security flags. |
| Local process crash, including `0x80000003` | Check whether Chrome recovered and whether the CLI session is still alive. Do not infer that the account or token expired, or close all browser processes. |
| Invalid/expired user code or ended CLI session | First check whether authentication actually succeeded. If not, end or confirm the end of the old task-owned session before starting a new one. Explain that the old code is invalid and replace it. |
| `authorization_pending` | Wait for the user. Do not start another login. Let the CLI control polling. |
| `slow_down` or rate limiting | Let the CLI back off. Do not add rapid API polling or repeatedly request codes. |
| `access_denied` or user cancellation | Stop this attempt. Start another only when the user indicates that they want to continue. |
| Browser success but CLI timeout | Check authentication and the API first. Resume publishing if they succeed; start a replacement session only if needed. |
| Network timeout, Windows Schannel failure, or access restriction | Distinguish network, proxy, sandbox, and process problems. Follow the environment's permission rules. Use an existing verified proxy only for the relevant process; do not hard-code ports, change system proxy settings, or disable TLS verification. |

By default, start at most two replacement sessions, each justified by an observed failure. If the same blocker repeats, preserve the build and report the current page/CLI state and required next action. A later user request to continue can justify recovery based on new evidence. Never retry indefinitely.

Treat the actual CLI state and server-provided expiry as authoritative. Recheck official documentation if the authorization flow changes.

## Official references

- [GitHub CLI auth login](https://cli.github.com/manual/gh_auth_login)
- [GitHub CLI environment variables](https://cli.github.com/manual/gh_help_environment)
- [GitHub OAuth device flow and error responses](https://docs.github.com/en/apps/oauth-apps/building-oauth-apps/authorizing-oauth-apps#device-flow)
