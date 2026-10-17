# Example: A Portable Windows Application

This is an illustrative C# / WPF release workflow. All names, paths, commands, and versions below are placeholders. Read the actual project before executing anything. This example grants no permission to publish a repository.

## Example project

- Project directory: `C:\Projects\ExampleApp`.
- Target: the user-selected `OWNER/REPOSITORY` and repository visibility.
- Platform: C# / WPF on .NET Framework 4.8, when that matches the project.
- Build entry point: `build.ps1`.
- Packaging entry point: `package.ps1`.
- Application output: `dist\ExampleApp.exe`.
- Release package: `release\ExampleApp_Windows_1.2.0.zip`.

## Adapt the release

1. Locate the existing GitHub CLI and verify its active account through the API. Use a portable CLI only after verifying its actual location and trust.
2. Find the project's real version fields. A typical project may use an assembly information file, application code, README, usage guide, changelog, and packaging script. Update only the fields the project actually uses.
3. Run the existing build and relevant validation commands. If the application exposes a self-test or startup probe, inspect its behavior before invoking it. Use isolated temporary directories so tests cannot modify normal user data.
4. Inspect the packaging manifest. Include required executables, configuration, documentation, examples, third-party licenses, and attribution. Keep private data, progress, backups, and logs out of the package.
5. Extract the ZIP into a separate directory and validate the version, startup behavior, and SHA256. For hidden test helpers launched with `Start-Process`, use `-WindowStyle Hidden` unless the user needs an interactive window.
6. Follow the [publication runbook](publish.md) and verify the remote release assets against the local package.

An existing portable installation may contain a `UserData` directory. Publish from an explicit clean file list rather than compressing that installation. Do not infer a proxy address, GitHub account, repository visibility, local path, or current version from a previous release.
