"use client";

import { useEffect } from "react";
import ServerError from "@/components/ServerError";

/**
 * Runtime error boundary for the app. `reset()` re-renders the failed segment,
 * so "Try again" recovers without a full page reload.
 */
export default function Error({
  error,
  reset,
}: {
  error: Error & { digest?: string };
  reset: () => void;
}) {
  useEffect(() => {
    // Surface the digest in the console so a report can be tied to a build.
    console.error(error);
  }, [error]);

  return <ServerError retry={reset} />;
}
