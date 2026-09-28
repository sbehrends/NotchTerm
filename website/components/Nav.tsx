import { APP_VERSION } from "@/lib/site";
import Logo from "./Logo";

export default function Nav() {
  return (
    <header className="fixed inset-x-0 top-0 z-50 border-b border-on-surface/5 bg-background/70 backdrop-blur-md">
      <nav
        aria-label="Primary"
        className="mx-auto flex max-w-7xl items-center justify-between px-margin-mobile py-3 md:px-margin-desktop"
      >
        <a href="#main" className="flex items-center gap-2.5">
          <Logo idPrefix="nav-logo" className="h-8 w-8" aria-hidden />
          <span className="font-display text-xl font-bold tracking-tight text-on-surface">
            NotchTerm
          </span>
          <span className="rounded-full bg-on-surface/[0.06] px-2 py-0.5 font-mono text-[10px] font-semibold text-on-surface-variant">
            v{APP_VERSION}
          </span>
        </a>
      </nav>
    </header>
  );
}
