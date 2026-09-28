import type { MetadataRoute } from "next";
import { withBase } from "@/lib/site";

export const dynamic = "force-static";

export default function manifest(): MetadataRoute.Manifest {
  return {
    name: "NotchTerm — The terminal that lives in your notch",
    short_name: "NotchTerm",
    description:
      "A fast, native macOS terminal that lives in your notch. Toggle it with a gesture, get Claude inline, stay in flow.",
    start_url: withBase("/"),
    display: "standalone",
    background_color: "#fef9f1",
    theme_color: "#fef9f1",
    icons: [
      { src: withBase("/icon-192.png"), sizes: "192x192", type: "image/png" },
      { src: withBase("/logo.png"), sizes: "512x512", type: "image/png" },
      { src: withBase("/favicon.svg"), sizes: "any", type: "image/svg+xml" },
    ],
  };
}
