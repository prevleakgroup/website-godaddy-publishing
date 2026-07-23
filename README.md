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

## Firebase Hosting (Multi-site Targets)

This repository also supports Firebase Hosting target-based deploys using:

- `admin-panel` → `apps/admin/dist`
- `marketing-landing` → `apps/landing/out`

### 1) Firebase config files

- `firebase.json` defines both hosting targets.
- `.firebaserc` must map each target to a real Firebase Hosting site for your project.

`.firebaserc` placeholders to replace:

- `__FIREBASE_PROJECT_ID__`
- `__ADMIN_PANEL_SITE_ID__`
- `__MARKETING_LANDING_SITE_ID__`

You must replace these values before first real deploy. Replace them directly in `.firebaserc` or run the target apply commands below.

### 2) Build commands (must produce deploy directories)

Use your app build pipeline so these directories exist before deploy:

- `apps/admin/dist`
- `apps/landing/out`

Example build commands:

```bash
npm run build --workspace apps/admin
npm run build --workspace apps/landing
```

Quick verification:

```bash
test -d apps/admin/dist || (echo "Missing apps/admin/dist. Build admin first." && exit 1)
test -d apps/landing/out || (echo "Missing apps/landing/out. Build landing first." && exit 1)
```

### 3) Apply hosting target mappings

Run once per Firebase project (replace placeholders):

```bash
firebase target:apply hosting admin-panel __ADMIN_PANEL_SITE_ID__ --project __FIREBASE_PROJECT_ID__
firebase target:apply hosting marketing-landing __MARKETING_LANDING_SITE_ID__ --project __FIREBASE_PROJECT_ID__
```

Verify mappings:

```bash
firebase target --project __FIREBASE_PROJECT_ID__
```

### 4) Deploy commands

Deploy admin only:

```bash
firebase deploy --only hosting:admin-panel --project __FIREBASE_PROJECT_ID__
```

Deploy landing only:

```bash
firebase deploy --only hosting:marketing-landing --project __FIREBASE_PROJECT_ID__
```

Deploy both:

```bash
firebase deploy --only hosting:admin-panel,hosting:marketing-landing --project __FIREBASE_PROJECT_ID__
```

### 5) Common failure guardrails

- **Error:** `Hosting target admin-panel not detected in firebase.json` or similar  
  **Fix:** Ensure `firebase.json` includes the correct `target` names and re-run deploy.

- **Error:** `Deploy target admin-panel not configured for project`  
  **Fix:** Re-run:
  `firebase target:apply hosting admin-panel __ADMIN_PANEL_SITE_ID__ --project __FIREBASE_PROJECT_ID__`

- **Error:** `Directory 'apps/admin/dist' does not exist` (or `apps/landing/out`)  
  **Fix:** Run the corresponding build command first and verify directory exists.

### 6) GitHub Actions support

Use `.github/workflows/firebase-hosting-deploy.yml` (manual trigger) for target-specific CI deploys:

- Input `project_id`: your Firebase project id
- Input `target`: `admin-panel`, `marketing-landing`, or `all`
- Required secret: `FIREBASE_TOKEN`

Generate `FIREBASE_TOKEN` and save it in repository secrets:

```bash
firebase login:ci
# copy the printed token and add it as FIREBASE_TOKEN in GitHub Secrets
```

## Notes

- Only website files are deployed; the `.github/` and `.git/` directories are excluded from the upload.
- Files deleted from the repository are **not** automatically removed from the server. To clean up stale files, log in via SFTP or the cPanel File Manager and delete them manually.
