import { DOWNLOAD_URL, MIN_MACOS } from "@/lib/site";
import NotchTerminal from "./NotchTerminal";
import { AppleIcon, PlayIcon } from "./icons";

export default function Hero() {
  return (
    <section className="relative overflow-hidden px-margin-mobile pb-content-gap pt-32 md:px-margin-desktop md:pt-40">
      <div className="mx-auto flex max-w-5xl flex-col items-center text-center">
        <h1 className="max-w-4xl font-display text-display-lg text-balance text-on-surface">
          The terminal that lives in{" "}
          <span className="whitespace-nowrap">
            your{" "}
            <span className="inline-block rounded-xl bg-primary px-3 py-0.5 text-on-primary">
              notch.
            </span>
          </span>
        </h1>

        <p className="mt-7 max-w-xl text-pretty text-body-lg text-on-surface-variant">
          A fast, native macOS terminal tucked into your notch. Toggle it with a
          top-edge gesture, get Claude assistance inline, and stay in flow — no
          window management, no CMD-Tab.
        </p>

        <div className="mt-10 flex flex-col items-center gap-4 sm:flex-row">
          <a
            href={DOWNLOAD_URL}
            className="flex items-center gap-3 rounded-full bg-primary px-8 py-3.5 font-semibold text-on-primary shadow-xl shadow-primary/10 transition-transform hover:scale-[1.02] active:scale-100"
          >
            <AppleIcon className="text-[18px]" />
            Download for Mac
          </a>
        </div>

        <p className="mt-4 font-mono text-xs text-on-surface/45">
          Free · Universal Binary · macOS {MIN_MACOS}+
        </p>
      </div>

      <div className="mt-16 md:mt-20">
        <NotchTerminal />
      </div>
    </section>
  );
}
