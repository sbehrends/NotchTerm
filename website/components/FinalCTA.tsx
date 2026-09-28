import { APP_VERSION, DOWNLOAD_URL } from "@/lib/site";
import { AppleIcon, CheckBadgeIcon } from "./icons";

export default function FinalCTA() {
  return (
    <section
      id="download"
      className="scroll-mt-24 px-margin-mobile py-section-gap md:px-margin-desktop"
    >
      <div className="mx-auto max-w-4xl text-center">
        <h2 className="font-display text-display-lg text-balance text-white">
          Ready to reclaim
          <br className="hidden sm:block" /> your screen?
        </h2>

        <div className="mt-12 flex flex-col items-center gap-7">
          <a
            href={DOWNLOAD_URL}
            className="flex items-center gap-4 rounded-full bg-accent px-11 py-5 text-xl font-bold text-primary shadow-2xl shadow-accent/25 transition-transform hover:scale-[1.03] active:scale-100"
          >
            <AppleIcon className="text-2xl" />
            Download for macOS
          </a>
          <p className="flex items-center gap-2 font-mono text-sm text-white/65">
            <CheckBadgeIcon className="text-lg text-[#7ee0a0]" />
            Version {APP_VERSION} — Universal Binary
          </p>
        </div>
      </div>
    </section>
  );
}
