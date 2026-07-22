# website-godaddy-publishing

Automated website deployment to GoDaddy (cPanel) via SFTP using GitHub Actions.

## How It Works

On every push to the `main` or `master` branch, GitHub Actions automatically deploys the repository contents to your GoDaddy cPanel hosting via SFTP.

## Setup: GitHub Secrets

Before the workflow can run, you must configure the following GitHub repository secrets:

| Secret | Description |
|---|---|
| `CPANEL_SFTP_HOST` | Your cPanel / GoDaddy SFTP hostname (e.g. `ftp.yourdomain.com`) |
| `CPANEL_SFTP_PORT` | SFTP port (typically `22`) |
| `CPANEL_SFTP_USERNAME` | Your cPanel SFTP username |
| `CPANEL_SFTP_PASSWORD` | Your cPanel SFTP password |
| `CPANEL_SFTP_REMOTE_PATH` | Remote path to deploy to (e.g. `/public_html`) |

### Setting Secrets via GitHub CLI

```bash
cd /path/to/your/repo
gh auth login
REPO=$(gh repo view --json nameWithOwner -q .nameWithOwner)
echo "$REPO"

gh secret set CPANEL_SFTP_HOST --repo "$REPO"
gh secret set CPANEL_SFTP_PORT --repo "$REPO"
gh secret set CPANEL_SFTP_USERNAME --repo "$REPO"
gh secret set CPANEL_SFTP_PASSWORD --repo "$REPO"
gh secret set CPANEL_SFTP_REMOTE_PATH --repo "$REPO"

gh secret list --repo "$REPO"
```

### Setting Secrets via GitHub UI

1. Go to your repository on GitHub.
2. Click **Settings** → **Secrets and variables** → **Actions**.
3. Click **New repository secret** and add each secret listed above.

## Workflow File

The deployment workflow is located at `.github/workflows/deploy.yml`.

## Notes

- Only website files are deployed; the `.github/` and `.git/` directories are excluded from the upload.
- Files deleted from the repository are **not** automatically removed from the server. To clean up stale files, log in via SFTP or the cPanel File Manager and delete them manually.
