# Deploying KODEX (beta) on Railway

Target: **Railway** (PaaS) using the app's `Dockerfile`. No domain purchase needed —
Railway gives a free `*.up.railway.app` subdomain. **SQLite** persists on a mounted
volume. **Email is off** for the beta (infra is in place; see "Enabling email" below).
Accounts are **invite-only** — created manually by an admin.

## One-time setup

1. **Get the code to Railway.** Easiest is GitHub:
   - This folder isn't a git repo yet. Initialize and push:
     ```bash
     git init && git add -A && git commit -m "Initial commit"
     gh repo create kodex --private --source=. --push   # or push to a repo you made
     ```
   - (Alternative, no GitHub: `npm i -g @railway/cli`, `railway login`, `railway init`, `railway up`.)

2. **Create the project.** Railway → **New Project → Deploy from GitHub repo** → pick the repo.
   Railway reads `railway.json` and builds the `Dockerfile` automatically.

3. **Add a Volume** (critical — SQLite + uploads live here). Service → **Variables/Settings →
   Volumes → New Volume**, mount path: **`/rails/storage`**.

4. **Set environment variables** (service → **Variables**):
   - `RAILS_MASTER_KEY` = the contents of `config/master.key` (decrypts credentials / secret_key_base).
   - That's the only required one. `RAILS_ENV=production` is already baked into the image,
     and `RAILWAY_PUBLIC_DOMAIN` is injected by Railway (auto-wires the app host + allowed hosts).

5. **Generate a domain.** Service → **Settings → Networking → Generate Domain**
   → `something.up.railway.app`. Railway routes to the container port automatically
   (the entrypoint binds the server to `$PORT`).

6. **Deploy.** On boot, `bin/docker-entrypoint` runs `db:prepare`, so all migrations
   (including `holiday_region` and `note_views`) apply automatically. Health check: `/up`.

> **Keep replicas = 1.** SQLite is a single-file DB on a single volume; do not scale to
> multiple instances. Fine for a beta.

## Create admins (manual, invite-only)

Open a shell on the service (Railway → service → **⋯ → Shell**, or `railway run` from the CLI):

```bash
EMAIL=you@example.com PASSWORD='a-strong-password' NAME='Your Name' ADMIN=true bin/rails users:create
```

Drop `ADMIN=true` to create a normal member. Reset a password later with:

```bash
EMAIL=someone@example.com PASSWORD='new-password' bin/rails users:set_password
```

(Or use `bin/rails console` → `User.create!(email:, password:, name:, role: :admin)`.)

## Enabling email later (password reset + invites)

Everything is wired; it's inert until `SMTP_ADDRESS` is set. When ready:

1. Pick a provider (Resend / Postmark / SES / Mailgun) and **verify your sending domain**
   (add their SPF + DKIM, and a DMARC record in DNS). Free tiers are fine for a beta.
2. Add these Railway variables (Resend example):
   - `SMTP_ADDRESS=smtp.resend.com`
   - `SMTP_PORT=587`
   - `SMTP_USER_NAME=resend`
   - `SMTP_PASSWORD=<your API key>`
   - `SMTP_DOMAIN=<your-sending-domain>`
   - `MAIL_FROM=KODEX <no-reply@your-domain>`
   - `APP_HOST=<your-domain>` *(only if you attach a custom domain; otherwise the
     Railway subdomain is used automatically)*
3. Redeploy. Password reset and network/calendar/referral invites will start sending.

## Notes

- `config/deploy.yml` + `.kamal/secrets` remain for an optional self-hosted **Kamal**
  deploy; they're unused on Railway.
- Uploaded avatars and all SQLite data live under `/rails/storage` (the volume) — back it up.
