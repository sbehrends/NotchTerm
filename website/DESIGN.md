---
name: Studio Cream & Carbon
colors:
  surface: '#fef9f1'
  surface-dim: '#ded9d2'
  surface-bright: '#fef9f1'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#f8f3eb'
  surface-container: '#f2ede5'
  surface-container-high: '#ede7e0'
  surface-container-highest: '#e7e2da'
  on-surface: '#1d1b17'
  on-surface-variant: '#444748'
  inverse-surface: '#32302b'
  inverse-on-surface: '#f5f0e8'
  outline: '#747878'
  outline-variant: '#c4c7c7'
  surface-tint: '#5f5e5e'
  primary: '#000000'
  on-primary: '#ffffff'
  primary-container: '#1c1b1b'
  on-primary-container: '#858383'
  inverse-primary: '#c8c6c5'
  secondary: '#a04100'
  on-secondary: '#ffffff'
  secondary-container: '#fe6b00'
  on-secondary-container: '#572000'
  tertiary: '#000000'
  on-tertiary: '#ffffff'
  tertiary-container: '#1d1c16'
  on-tertiary-container: '#87847c'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#e5e2e1'
  primary-fixed-dim: '#c8c6c5'
  on-primary-fixed: '#1c1b1b'
  on-primary-fixed-variant: '#474746'
  secondary-fixed: '#ffdbcc'
  secondary-fixed-dim: '#ffb693'
  on-secondary-fixed: '#351000'
  on-secondary-fixed-variant: '#7a3000'
  tertiary-fixed: '#e7e2d9'
  tertiary-fixed-dim: '#cac6be'
  on-tertiary-fixed: '#1d1c16'
  on-tertiary-fixed-variant: '#494740'
  background: '#fef9f1'
  on-background: '#1d1b17'
  surface-variant: '#e7e2da'
typography:
  display-lg:
    fontFamily: Hanken Grotesk
    fontSize: 72px
    fontWeight: '800'
    lineHeight: 80px
    letterSpacing: -0.04em
  headline-lg:
    fontFamily: Hanken Grotesk
    fontSize: 48px
    fontWeight: '700'
    lineHeight: 56px
    letterSpacing: -0.03em
  headline-lg-mobile:
    fontFamily: Hanken Grotesk
    fontSize: 36px
    fontWeight: '700'
    lineHeight: 44px
    letterSpacing: -0.02em
  headline-md:
    fontFamily: Hanken Grotesk
    fontSize: 24px
    fontWeight: '600'
    lineHeight: 32px
    letterSpacing: -0.01em
  body-lg:
    fontFamily: Inter
    fontSize: 18px
    fontWeight: '400'
    lineHeight: 28px
  body-md:
    fontFamily: Inter
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
  label-sm:
    fontFamily: Geist
    fontSize: 12px
    fontWeight: '500'
    lineHeight: 16px
    letterSpacing: 0.05em
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  base: 8px
  section-gap: 120px
  content-gap: 48px
  gutter: 24px
  margin-desktop: 64px
  margin-mobile: 20px
---

## Brand & Style

This design system is built on a foundation of sophisticated utility, blending the warmth of physical editorial design with the precision of modern macOS interfaces. It targets professionals and enthusiasts who value aesthetic refinement as much as functional performance.

The visual style is **Corporate Modern with a Minimalist Editorial edge**. It utilizes high-contrast typography and a warm, paper-like background to reduce eye strain while maintaining a premium feel. The interface feels established and deliberate, moving away from generic tech aesthetics toward a more artisanal, software-as-craft approach. It evokes an emotional response of trust, clarity, and "high-end" utility.

## Colors

The palette is anchored by **#F7F2E9 (Cream)**, providing a rich, organic base that differentiates the UI from standard white-label software. 

- **Primary Carbon (#1A1A1A):** Used for all primary actions, heavy headings, and high-impact UI elements. It provides the "ink" to the cream's "paper."
- **Secondary Orange (#FF6B00):** Retained as a functional accent. This is used sparingly for interactive highlights, notifications, or critical call-to-actions to ensure they pop against the neutral base.
- **Surface Neutrals:** Successive layers of depth use slightly darker or more desaturated versions of the cream base to maintain a soft, tonal hierarchy.

## Typography

The typographic system is bold and authoritative. **Hanken Grotesk** is the primary display face, used at heavy weights (Bold/ExtraBold) with tight letter-spacing to mimic high-end editorial layouts. 

For body copy, **Inter** provides maximum legibility and a neutral, systematic feel that balances the expressive headlines. **Geist** is utilized for labels and technical metadata, providing a clean, developer-centric aesthetic for small-scale information. Headlines should often utilize "tight" leading to create a dense, impactful visual block.

## Layout & Spacing

The layout follows a **Fluid Grid** model with generous vertical breathing room. 

- **Desktop:** 12-column grid with 24px gutters. Sections are separated by large 120px gaps to create a premium, unhurried pace.
- **Alignment:** Centralized content blocks for marketing and landing pages; left-aligned, structured grids for application views.
- **Rhythm:** An 8px base unit governs all internal component spacing (padding, gaps within cards).
- **Mobile:** Transition to a 4-column grid with 20px side margins. Typography scales down significantly to ensure display heads do not wrap awkwardly.

## Elevation & Depth

This design system avoids traditional heavy shadows in favor of **Tonal Layers** and **Subtle Ambient Occlusion**.

- **Surface Tiers:** Background is the base Cream. Cards and containers use a slightly lighter or 1px bordered surface to indicate elevation.
- **Shadows:** Only used for primary floating elements (like the main CTA buttons). These shadows are extremely diffused, low-opacity (#000 at 15%), and large, simulating a soft light source from directly above.
- **Depth:** Depth is often achieved through contrast rather than shadows—placing a Carbon element directly on a Cream surface creates an immediate "top-level" feel without needing a drop shadow.

## Shapes

The shape language is **Modern & Rounded**. It mirrors the hardware curves of macOS and modern mobile devices. 

Standard components (buttons, input fields) use a 0.5rem (8px) radius. Larger containers, such as feature cards or the central "Dynamic" element, use 1.5rem (24px) to create a soft, approachable frame for content. Icons should follow a consistent stroke weight (1.5px to 2px) with rounded caps and joins to match the UI's geometry.

## Components

- **Buttons:** 
  - *Primary:* Solid Carbon (#1A1A1A) background with Cream text. Sharp, high-contrast, with a subtle 12px blur shadow.
  - *Secondary:* Transparent background with a thin 1px Carbon border.
  - *Accent:* Used for "Sale" or "New" tags—Solid Orange (#FF6B00) with Carbon text.
- **Cards:** No border-color by default; use a subtle tonal shift or a very soft, large shadow to define the boundary against the cream background.
- **Input Fields:** Thick 2px borders when focused. Use Geist for placeholder text to maintain the technical aesthetic.
- **Chips/Badges:** Pill-shaped with a light-grey or tinted-cream background. Text is always Label-SM (Uppercase).
- **Iconography:** Large, centered icons for feature grids. Icons should be monochrome Carbon unless indicating an active state (Orange).