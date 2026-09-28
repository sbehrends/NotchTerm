# NotchTerm — marketing site

The landing page for **NotchTerm**, the terminal that lives in your notch.
A fully static, high-performance Next.js site built on the _Studio Cream &
Carbon_ design system (see [`DESIGN.md`](./DESIGN.md)).

## Stack & decisions

- **Next.js 16 (App Router, Turbopack) + `output: "export"`** — emits a
  self-contained `out/` directory. Zero server runtime; deploy to any static
  host / CDN. React 19.
- **Tailwind CSS v4** — design tokens live in `@theme` inside
  `app/globals.css`, so every color/size/spacing value is a first-class
  utility (`bg-surface`, `text-on-surface-variant`, `py-section-gap`, …).
- **`next/font`** — Hanken Grotesk, Inter & JetBrains Mono are self-hosted at
  build time (no Google Fonts request, no render-blocking `<link>`, no CLS).
- **Zero-dependency inline SVG icons** (`components/icons.tsx`) — no icon font.
- **Accessibility first** — semantic landmarks, skip link, visible focus,
  `prefers-reduced-motion`, keyboard-operable interactive hero.

### Verified

Lighthouse (desktop): **Performance-grade LCP 78 ms · CLS 0.00**, and
**Accessibility 100 · Best Practices 100 · SEO 100**. First Load JS ≈ 105 kB.

## Structure

```
app/
  layout.tsx      # metadata, icons, OG/Twitter, JSON-LD, fonts, skip link
  page.tsx        # composition (light hero + dark carbon sections)
  globals.css     # design tokens (@theme) + base styles + keyframes
  fonts.ts        # next/font config
  sitemap.ts      # static sitemap.xml
  manifest.ts     # PWA manifest (name, theme colors, icons)
  not-found.tsx   # 404 → exported as out/404.html
  error.tsx       # runtime error boundary (500) with retry
  500/page.tsx    # static 500 the host can serve when the app never renders
components/
  Nav / Hero / Features / FinalCTA / Footer
  NotchTerminal.tsx   # the interactive "terminal drops from the notch" hero
  ErrorPage.tsx       # shared 404/500 shell; ServerError.tsx = the 500 body
  Logo.tsx            # the mark, as inline SVG (vector twin of the app icon)
  icons.tsx
public/           # brand assets (below) + robots.txt
scripts/
  og-template.html    # source used to render public/og.png
```

## Brand assets

The icon is designed in Figma, in two versions: **detailed** (frame "NotchTerm
App Icon", for 128px and up) and **simplified** (frame "Favicon (full-bleed, no
shadow)": thicker rim and strokes, no glow, for 16–64px). `logo.png` in this
directory is the 1024² render of the detailed frame. Everything in `public/`
is derived from those two frames:

| File | Size | Source | Used for |
| --- | --- | --- | --- |
| `logo.png` | 512² | detailed | master mark (transparent, macOS grid padding), PWA 512, JSON-LD logo |
| `icon-192.png` | 192² | detailed | PWA / Android home screen |
| `apple-icon.png` | 180² | detailed | iOS home screen (cream plate, iOS masks it) |
| `favicon.ico` | 16/32/48 | simplified | legacy browser fallback |
| `favicon.svg` / `icon.svg` | vector | simplified | modern favicon; crisp at 16px |
| `og.png` | 1200×630 | `logo.png` | Open Graph / Twitter card |

`components/Logo.tsx` is the simplified mark as inline SVG for in-page use (nav,
footer): vector, so it stays sharp at 24–32px. It takes an `idPrefix` prop
because its gradient ids are document-global; give each instance its own.

## Deploying (GitHub Pages)

`.github/workflows/website.yml` builds this folder and deploys `out/` to GitHub
Pages on every push to `main` that touches `website/**` (or on manual dispatch).
Commits that touch only the macOS app don't trigger it.

The site is a **project site** at <https://sbehrends.github.io/NotchTerm/>, so it
is served under `/NotchTerm`:

- `basePath` in `next.config.mjs` and `BASE_PATH` in `lib/site.ts` must match.
- Next prefixes its own assets and `next/link` hrefs. Anything else root-relative
  (plain `<a href="/">`, metadata icons, manifest entries) goes through
  `withBase()` from `lib/site.ts`.
- `public/robots.txt` hardcodes the sitemap URL — update it if the URL changes.

One-time setup: repo Settings → Pages → Source: **GitHub Actions**. The repo must
be public (or on a paid plan) for Pages to serve.

## Develop

```bash
npm install
npm run dev        # http://localhost:3000/NotchTerm/
npm run build      # static export → ./out
npm run lint       # eslint (flat config; `next lint` was removed in v16)
npx serve out      # preview the production export
```

## The signature interaction

`NotchTerminal` renders a MacBook-style display with a notch. A terminal panel
is tucked _behind_ the notch and drops down on hover/focus/click, running a
scripted Claude session. It auto-peeks once on load to advertise the
affordance, is fully keyboard-operable, and disables all motion under
`prefers-reduced-motion`. Motion is compositor-only (transform/opacity).
