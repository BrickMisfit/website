# BrickMisfit Website

The source files for the **BrickMisfit** website, published through GitHub Pages.

- Website: https://brickmisfit.github.io/website/
- GitHub repository: https://github.com/BrickMisfit/website
- YouTube: https://youtube.com/@thebrickmisfit
- Instagram: https://www.instagram.com/thebrickmisfit/
- Discord: https://discord.gg/xfMkHYcvC

## 1. Initial setup (Windows)

Install [Git for Windows](https://git-scm.com/downloads/win), then open PowerShell and check the installation:

```powershell
git --version
```

Set your Git commit identity once. Use the email address associated with your GitHub account (or your GitHub-provided no-reply address):

```powershell
git config --global user.name "BrickMisfit"
git config --global user.email "thebirckmisfit@gmail.com"
```

Clone the existing repository. Do not create a separate repository or copy files into a new Git history:

```powershell
New-Item -ItemType Directory -Path "C:\GitHub" -Force
Set-Location "C:\GitHub"
git clone https://github.com/BrickMisfit/website.git
Set-Location "C:\GitHub\website"
git status
```

The examples below assume the clone is in `C:\GitHub\website`. You may choose another location; the publishing script uses its own directory (`$PSScriptRoot`) to find the repository.

## 2. Authentication

Git for Windows normally includes **Git Credential Manager**. When Git prompts you to authenticate during the first push, sign in to GitHub and complete the browser authorization. Do not put a GitHub password or personal access token in the script or repository.

## 3. Website files and updates

The site is a static HTML/CSS/JavaScript project. Typical paths include:

| Path | Purpose |
| --- | --- |
| `index.html` | Homepage and latest build |
| `builds.html` | Completed and upcoming builds |
| `builds/` | Individual build journals |
| `collection.html` | Collection page |
| `mocs.html` | Custom builds and concepts |
| `videos.html` | Video library |
| `resources.html` | Brick-related resources |
| `about.html` | About and community links |
| `css/style.css` | Website appearance |
| `js/videos-data.js` | Video entries and YouTube IDs |
| `js/upcoming-build.js` | Upcoming build card |
| `js/collection-data.js` | Collection catalog data |
| `images/` | Website images |

When receiving a website update ZIP, extract it **into the cloned repository root**, keeping its folders intact. Review the replaced files before publishing. For new videos, edit `js/videos-data.js` rather than rebuilding the videos page; add the newest entry at the top.

## 4. Publish changes with PowerShell

Save `Publish-BrickMisfit.ps1` in the repository root, alongside this README:

```text
C:\GitHub\website\Publish-BrickMisfit.ps1
```

Open PowerShell and run:

```powershell
Set-Location "C:\GitHub\website"
.\Publish-BrickMisfit.ps1
```

The script checks that Git and the repository are available, detects the current branch, fetches its remote counterpart, and stops if the remote branch is ahead. It then shows changes, asks whether to stage **all** modified/new/deleted files, displays the staged summary, requests a commit message, and asks before committing and pushing.

Provide the message on the command line if preferred:

```powershell
.\Publish-BrickMisfit.ps1 -Message "Add Brick Resources page"
```

For a run without interactive confirmations **or a commit-message prompt**, supply both `-Message` and `-Yes`:

```powershell
.\Publish-BrickMisfit.ps1 -Message "Update website content" -Yes
```

**Caution:** `-Yes` stages and commits every changed file in the repository. Use it only after reviewing the changes. The script does not force-push or automatically resolve remote conflicts.

## 5. Review changes before publishing

Useful Git commands:

```powershell
git status
git diff
git diff --stat
```

After publishing, check the repository and live site:

- https://github.com/BrickMisfit/website
- https://brickmisfit.github.io/website/

GitHub Pages deploys according to the repository's configured Pages settings. Publication may take a few minutes; check the repository's **Actions** tab or **Settings > Pages** if an update is not visible.

## 6. If the script stops because GitHub has newer changes

The script intentionally stops instead of overwriting remote work. First inspect your working tree:

```powershell
git status
```

If you have **no uncommitted local changes**, update the current branch:

```powershell
git pull --rebase origin main
```

Replace `main` with your actual branch if different (`git branch --show-current`). If you **do** have local edits, commit or safely stash them before rebasing, and resolve any conflicts rather than discarding work. Then rerun the publishing script.

## 7. Common issues

**`git` is not recognized:** Install Git for Windows and reopen PowerShell.

**PowerShell blocks the script:** If the script was downloaded and you trust its contents, run:

```powershell
Unblock-File -Path ".\Publish-BrickMisfit.ps1"
```

If your organization's execution policy still blocks it, check the policy with `Get-ExecutionPolicy -List` before making changes.

**Authentication fails:** Confirm you can sign in to GitHub through Git Credential Manager and have push access to `BrickMisfit/website`.

**No changes to publish:** Nothing new has been staged; check `git status` and confirm you edited files in the cloned directory.

## 8. Suggested daily workflow

1. Open `C:\GitHub\website` and edit or extract the updated site files.
2. Preview/test the changes locally.
3. Review `git status` and `git diff`.
4. Run `Publish-BrickMisfit.ps1` with a descriptive commit message.
5. Confirm the push and check the GitHub Pages site.

> Keep this README and `Publish-BrickMisfit.ps1` committed to the repository so the publishing process stays documented and version-controlled.
