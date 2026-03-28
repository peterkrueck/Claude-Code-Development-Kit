# Deployment & Infrastructure

<!-- Operational reference for hosting, accounts, secrets, and CI/CD.
     This file helps Claude understand your deployment environment. -->

## Hosting

<!-- Where is each component deployed? -->

<!--
Example:
| Component | Provider | Plan | Region |
|-----------|----------|------|--------|
| Backend API | Vercel / Railway / Supabase | Free | us-east-1 |
| Website | Cloudflare Pages / Vercel | Free | Global CDN |
| Database | PostgreSQL (Supabase / Neon / RDS) | Free | us-east-1 |
-->

## Accounts & Services

<!-- External services the project depends on. Don't include secrets here. -->

<!--
Example:
- **Domain**: example.com registered on Cloudflare
- **Email**: Cloudflare email routing to personal inbox
- **AI Services**: OpenAI (GPT-4), Mistral (Voxtral Mini)
- **Payments**: Stripe for subscriptions
-->

## Secrets & Environment Variables

<!-- List what secrets exist and where they're stored. NEVER put actual values here. -->

<!--
Example:
| Secret | Purpose | Where Stored |
|--------|---------|-------------|
| OPENAI_API_KEY | LLM API access | .env (local), hosting secrets (prod) |
| STRIPE_SECRET_KEY | Payment processing | .env (local), hosting secrets (prod) |
| ADMIN_SECRET | Dashboard auth | .env (local), hosting secrets (prod) |
-->

## CI/CD

<!-- How is code tested and deployed? -->

<!--
Example:
- **Tests on push**: Unit tests run on every push via GitHub Actions
- **E2E on main**: E2E tests run on push to main only
- **Deployment**: Manual via `/deploy` skill (no auto-deploy)
-->

## Monitoring

<!-- What monitoring exists? Health checks, alerting, dashboards. -->
