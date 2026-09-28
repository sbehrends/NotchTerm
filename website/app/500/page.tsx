import type { Metadata } from "next";
import ServerError from "@/components/ServerError";

/**
 * Static 500 page. `app/error.tsx` covers runtime errors inside the app; this
 * route gives the host a real document to serve when the app never renders.
 * Static export emits it as `out/500/index.html`.
 */
export const metadata: Metadata = {
  title: "Server error",
  description:
    "Something broke on our end. The error has been logged — try again in a moment.",
  robots: { index: false, follow: false },
};

export default function ServerErrorPage() {
  return <ServerError />;
}
