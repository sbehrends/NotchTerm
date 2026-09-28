import { DOWNLOAD_URL, withBase } from "@/lib/site";
import type { Metadata } from "next";
import ErrorPage, {
  Pill,
  PrimaryAction,
  SecondaryAction,
} from "@/components/ErrorPage";
import { AppleIcon, TerminalIcon } from "@/components/icons";

export const metadata: Metadata = {
  title: "Page not found",
  description:
    "That page isn't here. Head back to NotchTerm — the terminal that lives in your notch.",
  robots: { index: false, follow: true },
};

export default function NotFound() {
  return (
    <ErrorPage
      code="404"
      label="Not found"
      title={
        <>
          This page isn&rsquo;t in{" "}
          <span className="whitespace-nowrap">
            your <Pill>notch.</Pill>
          </span>
        </>
      }
      body="The link is broken, or the page moved. Nothing was lost on your end — take the shortcut home and carry on."
      session={{
        cwd: "~/notchterm",
        command: "open ./the-page-you-wanted",
        lines: [
          { text: "● Resolving route…", tone: "muted" },
          {
            text: "✗ zsh: no such file or directory: ./the-page-you-wanted",
            tone: "error",
          },
          { text: "→ Try / instead", tone: "accent" },
        ],
      }}
      actions={
        <>
          <PrimaryAction href={withBase("/")}>
            <TerminalIcon className="text-[18px]" />
            Back to home
          </PrimaryAction>
          <SecondaryAction href={DOWNLOAD_URL}>
            <AppleIcon className="text-[18px]" />
            Download for Mac
          </SecondaryAction>
        </>
      }
    />
  );
}
