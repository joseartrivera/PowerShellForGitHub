# PowerShellForGitHub PowerShell Module
## Changelog

## [0.3.1](https://github.com/PowerShell/PowerShellForGitHub/tree/0.3.1) - (2018/11/13)
### Fixes:
* Minor static analysis issues fixed.
* Corrected name of the test file for `GitHubRepositoryForks`
* Ensured the `getParams` are used during execution of `Get-GitHubRepositoryFork`

More Info: [[pr]](https://github.com/PowerShell/PowerShellForGitHub/pull/42) | [[cl]](https://github.com/PowerShell/PowerHellForGitHub/commit/5703295d497f20fe8eec91d6ed47d126cc518592)

Author: [**@HowardWolosky**](https://github.com/HowardWolosky)

------

## [0.3.0](https://github.com/PowerShell/PowerShellForGitHub/tree/0.3.0) - (2018/11/13)
### Features:
+ Added support for querying forks and creating new ones.

### Fixes:
* Will only perform a retry when receiving a `202` response on a `GET` request.  Previously, it would
  retry regardless of the method of the request.

More Info: [[pr]](https://github.com/PowerShell/PowerShellForGitHub/pull/41) | [[cl]](https://github.com/PowerShell/PowerHellForGitHub/commit/1076239d7639497984a6e0b04df1e69019c4ec28)

Author: [**@HowardWolosky**](https://github.com/HowardWolosky)

------

## [0.2.0](https://github.com/PowerShell/PowerShellForGitHub/tree/0.2.0) - (2018/11/13)
### Features:
+ Significant restructing and refactoring of entire module to make future expansion easier.
+ Significant documentation updates ([CHANGELOG](./CHANGELOG.md), [CONTRIBUTING.md](./CONTRIBUTING.md),
  [GOVERNANCE.md](./GOVERNANCE.md), [README.md](./README.md), [USAGE.md](./USAGE.md))
+ Added `Set-GitHubAuthentication` (and related methods) for securely caching the Access Token
+ Added `Set-GitHubConfiguration` (and related methods) to enable short and long-term configuration
  of the module.
+ Added ability to asynchronously see status update of REST requests.
+ Added logging and telemetry to the module (each can be disabled if desired).
+ Tests now auto-configure themselves across whatever account information is supplied in
  [Tests/Config/Settings.ps1](./Tests/Config/Settings.ps1)
+ Added support for a number of additional GitHub API's:
  + All [Miscellaneous API's](https://developer.github.com/v3/misc/)
  + Ability to fully query, update, remove, lock, and unlock Issues.
  + Enhanced pull request querying support
  + Ability tofully query, create, and remove Repositories, as well as transfer ownership,
    get tags, get/set topic and current used programming languages.
  + Enhanced user query support as well as being able update information for the current user.

### Fixes:
* Made parameter ordering consistent across all functions (OwnerName is now first, then RepositoryName)
* Normalized all parameters to use SentenceCase
* All functions that can take a Uri or OwnerName/RepositoryName now support both options.
* Made all parameter names consistent across functions:
  * `GitHubAccessToken` -> `AccessToken`
  * `RepositoryUrl` -> `Uri`
  * `Organization` -> `OrganizationName`
  * `Repository` -> `RepositoryName`
  * `Owner` -> `OwnerName`
* Normalized usage of Verbose, Info and Error streams

### Functionality Modified from 0.1.0:
- `New-GitHubLabels` was renamed to `Set-GitHubLabel` and can now optionally take in the labels
  to apply to the Repository.
- `Get-GitHubIssueForRepository` has been removed and replaced with `Get-GitHubIssue`.
  The key difference between these two is that it no longer accepts multiple repositories as single
  input, and filtering on creation/closed date can be done after the fact piping the results into
  `Where-Object` now that the returned objects from `Get-GitHubIssue` have actual `[DateTime]` values
  for the date properties.  For an updated example of doing this, refer to [example usage](USAGE.md#querying-issues).
- `Get-GitHubWeeklyIssueForRepository` has been removed and functionally replaced by `Group-GitHubIssue`.
  For an updated example of using it, refer to [example usage](USAGE.md#querying-issues)
- `Get-GitHubTopIssueRepository` has been removed.  We have [updated examples](USAGE.md#querying-issues)
  for how to accomplish the same scenario.
- `Get-GitHubPullRequestForRepository` has been removed and replaced with `Get-GitHubPullRequest`.
  The key difference between these two is that it no longer accepts multiple repositories as single
  input, and filtering on creation/merged date can be done after the fact piping the results into
  `Where-Object` now that the returned objects from `Get-GitHubPullRequest` have actual `[DateTime]` values
  for the date properties.  For an updated example of doing this, refer to [example usage](USAGE.md#querying-pull-requests).
- `Get-GitHubWeeklyPullRequestForRepository` has been removed and functionally replaced by `Group-GitHubPullRequest`.
  For an updated example of using it, refer to [example usage](USAGE.md#querying-pull-requests)
- `Get-GitHubTopPullRequestRepository` has been removed.  We have [updated examples](USAGE.md#querying-pull-requests)
  for how to accomplish the same scenario.
- `Get-GitHubRepositoryNameFromUrl` and `GitHubRepositoryOwnerFromUrl` have been removed and
  functionally replaced by `Split-GitHubUri`
- `Get-GitHubRepositoryUniqueContributor` has been removed.  We have an
  [updated example](USAGE.md#querying-contributors) for how to accomplish the same scenario.
- `GitHubOrganizationRepository` has been removed.  You can now retrieve repositories for an
  organization via `Get-GitHubRepository -OrganizationName <name>`.
- `Get-GitHubAuthenticatedUser` has been replaced with `Get-GitHubUser -Current`.

More Info: [[pr]](https://github.com/PowerShell/PowerShellForGitHub/pull/39) | [[cl]](https://github.com/PowerShell/PowerHellForGitHub/commit/eb33688e5b8d688d28e8582b76b526da3c4428be)

Author: [**@HowardWolosky**](https://github.com/HowardWolosky)

------

## [0.1.0](https://github.com/PowerShell/PowerShellForGitHub/tree/0.1.0) - (2016/11/29)
### Features:
+ Initial public release

More Info: [[cl]](https://github.com/PowerShell/PowerShellForGitHub/commit/6a3b400019d6a97ccc2f08a951fd4b2d09282eb5)

Author: [**@KarolKaczmarek**](https://github.com/KarolKaczmarek)
