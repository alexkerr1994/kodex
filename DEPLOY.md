# Deploying KODEX (beta) on Railway

Target: **Railway** (PaaS) using the app's `Dockerfile`. No domain purchase needed —
Railway gives a free `*.up.railway.app` subdomain. Data lives in a **managed
PostgreSQL** database (one DB backs the app + Solid Queue/Cache/Cable); a small
**volume** holds uploaded files (avatars). **Email is off** for the beta (infra is in
place; see "Enabling email" below). Accounts are **invite-only** — created by an admin.

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

3. **Add PostgreSQL.** In the project: **+ New → Database → Add PostgreSQL**. Railway
   provisions it and exposes a `DATABASE_URL`. Link it to the web service: service →
   **Variables → + New Variable → Add Reference → `DATABASE_URL`** (from the Postgres
   service). The app reads `DATABASE_URL` in production automatically.

4. **Add a Volume** for uploaded files (avatars via Active Storage). Service →
   **Settings → Volumes → New Volume**, mount path: **`/rails/storage`**.

5. **Set environment variables** (service → **Variables**):
   - `RAILS_MASTER_KEY` = the contents of `config/master.key` (decrypts credentials / secret_key_base).
   - `DATABASE_URL` = the reference added in step 3.
   - `RAILS_ENV=production` is already baked into the image, and `RAILWAY_PUBLIC_DOMAIN`
     is injected by Railway (auto-wires the app host + allowed hosts).

6. **Generate a domain.** Service → **Settings → Networking → Generate Domain**
   → `something.up.railway.app`. Railway routes to the container port automatically
   (the entrypoint binds the server to `$PORT`).

7. **Deploy.** On boot, `bin/docker-entrypoint` runs `db:prepare` against Postgres, so
   all migrations (schema + Solid Queue/Cache/Cable tables) apply automatically. Health
   check: `/up`.

> **Keep replicas = 1** for the beta. Postgres itself scales fine, but uploaded files
> (Active Storage) sit on the single-instance volume — move Active Storage to object
> storage before running multiple web instances.

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
  deploy; they're unused on Railway. (Kamal would need its own Postgres accessory.)
- The app DB is **managed Postgres** — use Railway's automatic backups.
- Uploaded avatars (Active Storage) live under `/rails/storage` (the volume) — back it up
  too, or switch Active Storage to object storage (S3/R2) later.
