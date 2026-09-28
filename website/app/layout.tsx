import {
  APP_VERSION,
  DOWNLOAD_URL,
  GITHUB_URL,
  MIN_MACOS,
  SITE_URL,
  withBase,
} from "@/lib/site";
import type { Metadata, Viewport } from "next";
import { hanken, inter, jetbrainsMono } from "./fonts";
import "./globals.css";

export const metadata: Metadata = {
  metadataBase: new URL(SITE_URL),
  title: {
    default: "NotchTerm — The terminal that lives in your notch",
    template: "%s · NotchTerm",
  },
  description:
    "NotchTerm tucks a fast, native macOS terminal into your notch. Toggle it with a top-edge gesture, get Claude assistance inline, and stay in flow — no window management, no CMD-Tab.",
  applicationName: "NotchTerm",
  keywords: [
    "macOS terminal",
    "notch",
    "dynamic island",
    "Apple Silicon",
    "developer tools",
    "Claude",
    "terminal app",
  ],
  authors: [{ name: "NotchTerm" }],
  creator: "NotchTerm",
  alternates: { canonical: `${SITE_URL}/` },
  openGraph: {
    type: "website",
    url: `${SITE_URL}/`,
    siteName: "NotchTerm",
    title: "NotchTerm — The terminal that lives in your notch",
    description:
      "A fast, native macOS terminal that lives in your notch. Toggle it with a gesture, get Claude inline, stay in flow.",
    locale: "en_US",
    images: [
      {
        url: `${SITE_URL}/og.png`,
        width: 1200,
        height: 630,
        alt: "NotchTerm — the terminal that lives in your notch",
      },
    ],
  },
  twitter: {
    card: "summary_large_image",
    title: "NotchTerm — The terminal that lives in your notch",
    description:
      "A fast, native macOS terminal that lives in your notch. Toggle it with a gesture, get Claude inline, stay in flow.",
    images: [`${SITE_URL}/og.png`],
  },
  robots: {
    index: true,
    follow: true,
    googleBot: { index: true, follow: true, "max-image-preview": "large" },
  },
  icons: {
    // SVG first for modern browsers; .ico is the fallback for the rest.
    icon: [
      { url: withBase("/favicon.svg"), type: "image/svg+xml" },
      { url: withBase("/favicon.ico"), sizes: "16x16 32x32 48x48" },
      { url: withBase("/icon-192.png"), type: "image/png", sizes: "192x192" },
      { url: withBase("/logo.png"), type: "image/png", sizes: "512x512" },
    ],
    shortcut: withBase("/favicon.ico"),
    apple: { url: withBase("/apple-icon.png"), sizes: "180x180" },
  },
  manifest: withBase("/manifest.webmanifest"),
  category: "technology",
};

export const viewport: Viewport = {
  themeColor: [
    { media: "(prefers-color-scheme: light)", color: "#fef9f1" },
    { media: "(prefers-color-scheme: dark)", color: "#000000" },
  ],
  colorScheme: "light",
  width: "device-width",
  initialScale: 1,
};

const jsonLd = {
  "@context": "https://schema.org",
  "@type": "SoftwareApplication",
  name: "NotchTerm",
  url: `${SITE_URL}/`,
  image: `${SITE_URL}/og.png`,
  logo: `${SITE_URL}/logo.png`,
  applicationCategory: "DeveloperApplication",
  operatingSystem: `macOS ${MIN_MACOS}+`,
  description:
    "A fast, native macOS terminal that lives in your notch, with inline Claude assistance.",
  offers: { "@type": "Offer", price: "0", priceCurrency: "USD" },
  softwareVersion: APP_VERSION,
  downloadUrl: DOWNLOAD_URL,
  codeRepository: GITHUB_URL,
};

export default function RootLayout({
  children,
}: Readonly<{ children: React.ReactNode }>) {
  return (
    <html
      lang="en"
      className={`${hanken.variable} ${inter.variable} ${jetbrainsMono.variable}`}
    >
      <body className="font-sans text-body-md text-on-surface bg-background antialiased">
        <a
          href="#main"
          className="sr-only focus:not-sr-only focus:fixed focus:left-4 focus:top-4 focus:z-[100] focus:rounded-full focus:bg-primary focus:px-5 focus:py-2.5 focus:text-on-primary focus:font-mono focus:text-label-sm"
        >
          Skip to content
        </a>
        {children}
        <script
          type="application/ld+json"
          // Structured data for rich results; static string, safe to inline.
          dangerouslySetInnerHTML={{ __html: JSON.stringify(jsonLd) }}
        />
      </body>
    </html>
  );
}
