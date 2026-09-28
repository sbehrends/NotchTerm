import { GITHUB_URL } from "@/lib/site";
import Logo from "./Logo";

const LINKS = [
  { label: "GitHub", href: GITHUB_URL },
];

export default function Footer() {
  return (
    <footer className="border-t border-white/10 bg-black py-16">
      <div className="mx-auto flex max-w-7xl flex-col items-center justify-between gap-10 px-margin-mobile md:flex-row md:px-margin-desktop">
        <div className="flex flex-col items-center gap-2 md:items-start">
          <div className="flex items-center gap-2">
            <Logo idPrefix="footer-logo" className="h-6 w-6" aria-hidden />
            <span className="font-display font-bold text-white">NotchTerm</span>
          </div>
          <p className="text-sm text-white/60">Made with care for builders.</p>
        </div>

        <nav aria-label="Footer" className="flex flex-wrap justify-center gap-x-8 gap-y-3">
          {LINKS.map((l) => (
            <a
              key={l.label}
              href={l.href}
              className="text-sm font-medium text-white/60 transition-colors hover:text-accent-dim"
            >
              {l.label}
            </a>
          ))}
        </nav>
      </div>

      <p className="mx-auto mt-10 max-w-7xl px-margin-mobile text-center font-mono text-xs text-white/55 md:px-margin-desktop md:text-left">
        © 2026 NotchTerm. Not affiliated with Apple Inc.
      </p>
    </footer>
  );
}
