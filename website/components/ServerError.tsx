import { withBase } from "@/lib/site";
import ErrorPage, { Pill, PrimaryAction, SecondaryAction } from "./ErrorPage";
import { RetryIcon, TerminalIcon } from "./icons";

/**
 * The 500 body, shared by the runtime error boundary (`app/error.tsx`) and the
 * static `/500` route hosts can point at. Pass `retry` when a client boundary
 * can re-render the failed segment.
 */
export default function ServerError({ retry }: { retry?: () => void }) {
  return (
    <ErrorPage
      code="500"
      label="Server error"
      title={
        <>
          Something broke on{" "}
          <span className="whitespace-nowrap">
            our <Pill>end.</Pill>
          </span>
        </>
      }
      body="Not your machine, not your config — ours. The error has been logged. Give it another go in a moment, or head back home."
      session={{
        cwd: "~/notchterm",
        command: "notchterm serve --page requested",
        lines: [
          { text: "● Building response…", tone: "muted" },
          { text: "✗ Error 500: unexpected server response", tone: "error" },
          { text: "→ Logged · retrying is safe", tone: "accent" },
        ],
      }}
      actions={
        <>
          {retry && (
            <PrimaryAction onClick={retry}>
              <RetryIcon className="text-[18px]" />
              Try again
            </PrimaryAction>
          )}
          {retry ? (
            <SecondaryAction href={withBase("/")}>
              <TerminalIcon className="text-[18px]" />
              Back to home
            </SecondaryAction>
          ) : (
            <PrimaryAction href={withBase("/")}>
              <TerminalIcon className="text-[18px]" />
              Back to home
            </PrimaryAction>
          )}
        </>
      }
    />
  );
}
