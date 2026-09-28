import type { ReactNode } from "react";
import Nav from "./Nav";
import Footer from "./Footer";

/**
 * ErrorPage — the shared shell behind 404 and 500.
 *
 * Same rhythm as the product page: cream hero, display headline with the
 * black notch-pill highlight, then a carbon terminal panel that reports the
 * failure the way NotchTerm itself would — as a shell session.
 */

type Line = { text: string; tone: "muted" | "accent" | "ok" | "error" };

const toneClass: Record<Line["tone"], string> = {
  muted: "text-white/45",
  accent: "text-[#ffb693]",
  ok: "text-[#7ee0a0]",
  error: "text-[#ff8f7d]",
};

export type ErrorPageProps = {
  /** Status code, shown as the mono eyebrow. */
  code: string;
  /** Short label next to the code, e.g. "NOT FOUND". */
  label: string;
  /** Headline — pass <Pill> around the word that gets the carbon highlight. */
  title: ReactNode;
  body: string;
  /** The scripted shell session shown in the terminal panel. */
  session: { cwd: string; command: string; lines: Line[] };
  /** Call-to-action buttons rendered under the copy. */
  actions: ReactNode;
};

/** The signature carbon highlight used on the hero headline. */
export function Pill({ children }: { children: ReactNode }) {
  return (
    <span className="inline-block rounded-xl bg-primary px-3 py-0.5 text-on-primary">
      {children}
    </span>
  );
}

/** A terminal block cursor (same treatment as the hero terminal). */
function Cursor() {
  return (
    <span
      className="ml-0.5 inline-block h-[1.15em] w-[0.5em] translate-y-[0.2em] bg-white/40 align-baseline"
      style={{ animation: "caret-blink 1.05s step-end infinite" }}
      aria-hidden
    />
  );
}

export default function ErrorPage({
  code,
  label,
  title,
  body,
  session,
  actions,
}: ErrorPageProps) {
  return (
    <>
      <Nav />
      {/* Column layout keeps the carbon footer pinned to the bottom on short
          pages, so the cream never runs past it. */}
      <main id="main" className="flex min-h-screen flex-col">
        <section className="relative flex-1 overflow-hidden px-margin-mobile pb-content-gap pt-32 md:px-margin-desktop md:pt-40">
          <div className="mx-auto flex max-w-3xl flex-col items-center text-center">
            <p className="mb-6 font-mono text-label-sm uppercase text-secondary">
              {code} · {label}
            </p>

            <h1 className="max-w-3xl font-display text-display-lg text-balance text-on-surface">
              {title}
            </h1>

            <p className="mt-7 max-w-xl text-pretty text-body-lg text-on-surface-variant">
              {body}
            </p>

            <div className="mt-10 flex flex-col items-center gap-4 sm:flex-row">
              {actions}
            </div>
          </div>

          {/* The failure, told as a shell session behind the notch. */}
          <figure className="relative mx-auto mt-16 w-full max-w-3xl select-none md:mt-20">
            {/* Soft ambient glow, matching the hero device. */}
            <div
              aria-hidden
              className="absolute inset-x-10 -bottom-6 top-10 -z-10 rounded-[3rem] bg-accent/20 blur-3xl"
            />

            <div className="relative overflow-hidden rounded-[1.75rem] bg-primary p-[3px] shadow-[0_40px_90px_-30px_rgba(29,27,23,0.45)] ring-1 ring-black/5 sm:rounded-[2.25rem] sm:p-[6px]">
              <div className="relative overflow-hidden rounded-[1.5rem] bg-[#17171a] sm:rounded-[1.9rem]">
                {/* The notch — tucked into the top edge, as on the device. */}
                <span
                  aria-hidden
                  className="absolute left-1/2 top-0 z-10 flex h-8 w-40 -translate-x-1/2 items-center justify-center rounded-b-[1.1rem] bg-black sm:h-9 sm:w-48 sm:rounded-b-[1.25rem]"
                >
                  <span className="h-1.5 w-1.5 rounded-full bg-[#ff8f7d] shadow-[0_0_8px_#ff8f7d]" />
                </span>

                {/* Window chrome. */}
                <div className="flex items-center gap-2 px-3 pb-2.5 pt-3">
                  <span className="flex items-center gap-2 rounded-lg bg-white/10 px-3 py-1.5 font-mono text-[11px] text-white/85 sm:text-[12px]">
                    {session.cwd}
                    <span aria-hidden className="text-white/40">
                      ✕
                    </span>
                  </span>
                  <span
                    aria-hidden
                    className="px-1 font-mono text-base leading-none text-white/40"
                  >
                    +
                  </span>
                </div>

                {/* Session. */}
                <div className="px-4 pb-8 pt-4 font-mono text-[12px] leading-relaxed sm:px-6 sm:pb-10 sm:text-[13.5px]">
                  <p className="font-semibold text-[#4dd6c8]">{session.cwd}</p>
                  <div className="mt-0.5 flex flex-wrap items-baseline">
                    <span className="mr-2 text-[#6ee787]">❯</span>
                    <span className="text-white/90">{session.command}</span>
                  </div>

                  <div className="mt-2 space-y-1">
                    {session.lines.map((l) => (
                      <p key={l.text} className={toneClass[l.tone]}>
                        {l.text}
                      </p>
                    ))}
                  </div>

                  <div className="mt-2 flex items-baseline">
                    <span className="mr-2 text-[#6ee787]">❯</span>
                    <Cursor />
                  </div>
                </div>
              </div>
            </div>

            <figcaption className="sr-only">
              A terminal session reporting the {code} error.
            </figcaption>
          </figure>
        </section>

        {/* Dark section — the "carbon" half of Cream & Carbon. */}
        <div className="bg-black text-white">
          <Footer />
        </div>
      </main>
    </>
  );
}

type ActionProps = {
  href?: string;
  onClick?: () => void;
  children: ReactNode;
};

/** Renders as a link when given an href, otherwise as a button. */
function Action({ href, onClick, children, className }: ActionProps & { className: string }) {
  return href ? (
    <a href={href} className={className}>
      {children}
    </a>
  ) : (
    <button type="button" onClick={onClick} className={className}>
      {children}
    </button>
  );
}

/** Primary (carbon) action — matches the hero download button. */
export function PrimaryAction(props: ActionProps) {
  return (
    <Action
      {...props}
      className="flex items-center gap-3 rounded-full bg-primary px-8 py-3.5 font-semibold text-on-primary shadow-xl shadow-primary/10 transition-transform hover:scale-[1.02] active:scale-100"
    />
  );
}

/** Quiet secondary action — outlined, so the carbon button stays dominant. */
export function SecondaryAction(props: ActionProps) {
  return (
    <Action
      {...props}
      className="flex items-center gap-3 rounded-full border border-on-surface/15 px-8 py-3.5 font-semibold text-on-surface transition-colors hover:border-on-surface/30 hover:bg-on-surface/[0.04]"
    />
  );
}
