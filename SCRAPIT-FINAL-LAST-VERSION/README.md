# SCRAPIT — AI-Powered Scrap Management Platform

## UI/UX upgrade summary
- Full design-token system (`--space-*`, `--radius-*`, `--shadow-*`, safe-area vars).
- Mobile-first bottom navigation with safe-area support and soft glass effect.
- Redesigned AI Scanner with status pill, logo-branded camera empty state, corner focus frame and scanning line.
- Scan Result reframed as a valuation report — Estimated Value is the visual hero.
- Inventory rewritten with dedicated mobile card layout, refined empty state using the SCRAPIT logo, horizontally scrollable filter chips.
- Buyers upgraded with verified badge overlay on avatar.
- Live Pricing retains market-dashboard layout with trend indicators and a “Prices update in” countdown.
- History retained as timeline with day-grouped entries.
- Settings grouped into Business / Notifications / Preferences / Security.
- Login preserved (dark eco-tech, glass card, dual tabs) with responsive compression at 360–480px.
- Home now surfaces a compact Recent Activity strip populated from real backend history.
- Modal turns into a bottom sheet on mobile with drag-handle affordance.
- Toast repositioned above the bottom nav using safe-area insets.
- `prefers-reduced-motion` respected globally.
- Every existing ID, `data-*` attribute and JS handler preserved.

## Run
1. `npm install`
2. `npm start`
3. Open `http://localhost:3000`

Demo account
- Email: `admin@scrapit.com`
- Password: `scrapit123`

> This backend is a development prototype. Do not use for real sensitive production data without proper security, database, authentication, validation and deployment hardening.