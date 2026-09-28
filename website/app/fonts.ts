import { Hanken_Grotesk, Inter, JetBrains_Mono } from "next/font/google";

// Self-hosted at build time by next/font — no runtime request to Google, no
// render-blocking <link>, and automatic size-adjust to eliminate CLS.

// Display / headline face — used at heavy weights with tight tracking.
export const hanken = Hanken_Grotesk({
  subsets: ["latin"],
  weight: ["600", "700", "800"],
  display: "swap",
  variable: "--font-hanken",
});

// Body / UI face — maximum legibility.
export const inter = Inter({
  subsets: ["latin"],
  weight: ["400", "500", "600", "700"],
  display: "swap",
  variable: "--font-inter",
});

// Technical / mono face — terminal, labels, version metadata.
export const jetbrainsMono = JetBrains_Mono({
  subsets: ["latin"],
  weight: ["400", "500", "700"],
  display: "swap",
  variable: "--font-jetbrains",
});
