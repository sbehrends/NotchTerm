"use client";

import { useCallback, useEffect, useRef, useState } from "react";

/**
 * NotchTerminal — the signature interaction.
 *
 * A macOS desktop with a notch. A terminal panel is tucked *behind* the notch
 * and drops down on interaction, so it literally "lives in your notch".
 *   • Closed  → a clean, empty black notch pill (like the real hardware notch).
 *   • Peek    → a hint slides out on hover / focus.
 *   • Open    → a full terminal window (tab bar, new-tab, gear, close) with a
 *               live Claude session; click the notch, or ✕ / Escape to close.
 *   • Auto-peeks once shortly after load to advertise the affordance.
 *   • Fully keyboard operable; honours prefers-reduced-motion.
 *
 * All motion is CSS transform/opacity (compositor-only) — cheap and smooth.
 */

type PanelState = "closed" | "peek" | "open";

// The scripted terminal session, revealed progressively.
const CWD = "~/dev/api";
const COMMAND = 'claude "fix the failing auth test"';
const OUTPUT: { text: string; tone: "muted" | "accent" | "ok" }[] = [
  { text: "● Ran 48 tests · 1 failing: auth.spec.ts", tone: "muted" },
  { text: "✓ Traced it to a missing await in refreshToken()", tone: "ok" },
  { text: "✓ Patched src/auth/session.ts", tone: "ok" },
  { text: "✓ 48 passed · lint clean · 0 new deps", tone: "ok" },
  { text: "Committed 'fix: await token refresh' → a1b3f9d", tone: "accent" },
];

const toneClass: Record<(typeof OUTPUT)[number]["tone"], string> = {
  muted: "text-white/45",
  accent: "text-[#ffb693]",
  ok: "text-[#7ee0a0]",
};

/** A terminal block cursor. */
function Cursor() {
  return (
    <span
      className="ml-0.5 inline-block h-[1.15em] w-[0.5em] translate-y-[0.2em] bg-white/40 align-baseline"
      style={{ animation: "caret-blink 1.05s step-end infinite" }}
      aria-hidden
    />
  );
}

function usePrefersReducedMotion() {
  const [reduced, setReduced] = useState(false);
  useEffect(() => {
    const mq = window.matchMedia("(prefers-reduced-motion: reduce)");
    const update = () => setReduced(mq.matches);
    update();
    mq.addEventListener("change", update);
    return () => mq.removeEventListener("change", update);
  }, []);
  return reduced;
}

/** Reveals the command char-by-char, then the output lines one at a time. */
function useSession(active: boolean, reduced: boolean) {
  const [typed, setTyped] = useState(0); // chars of COMMAND revealed
  const [lines, setLines] = useState(0); // OUTPUT lines revealed
  const timers = useRef<ReturnType<typeof setTimeout>[]>([]);

  const clearTimers = useCallback(() => {
    timers.current.forEach(clearTimeout);
    timers.current = [];
  }, []);

  useEffect(() => {
    // Reduced motion is handled by the derived return below — no timers.
    if (!active || reduced) return;
    clearTimers();
    const push = (fn: () => void, delay: number) =>
      timers.current.push(setTimeout(fn, delay));

    let t = 480;
    for (let i = 1; i <= COMMAND.length; i++) {
      const n = i;
      // slight jitter makes the typing feel human without randomness at build
      push(() => setTyped(n), t);
      t += 26 + ((i * 7) % 22);
    }
    OUTPUT.forEach((_, i) => {
      t += i === 0 ? 440 : 560;
      const n = i + 1;
      push(() => setLines(n), t);
    });

    // On deactivate / re-run, stop timers and rewind so the next open replays.
    return () => {
      clearTimers();
      setTyped(0);
      setLines(0);
    };
  }, [active, reduced, clearTimers]);

  // With reduced motion, present the whole session at once (no animation).
  if (reduced) return { typed: COMMAND.length, lines: OUTPUT.length };
  return { typed, lines };
}

export default function NotchTerminal() {
  const reduced = usePrefersReducedMotion();
  const [state, setState] = useState<PanelState>("closed");
  const [pinned, setPinned] = useState(false);
  const autoPeekDone = useRef(false);

  const active = state === "open" || state === "peek";
  const isOpen = state === "open";
  const { typed, lines } = useSession(active, reduced);
  const done = typed >= COMMAND.length && lines >= OUTPUT.length;

  // One-time auto-peek to advertise the interaction.
  useEffect(() => {
    if (reduced || autoPeekDone.current) return;
    const show = setTimeout(() => {
      if (!pinned) setState("peek");
    }, 1100);
    const hide = setTimeout(() => {
      autoPeekDone.current = true;
      if (!pinned) setState("closed");
    }, 3200);
    return () => {
      clearTimeout(show);
      clearTimeout(hide);
    };
  }, [reduced, pinned]);

  const peek = () => {
    if (!pinned) setState("peek");
  };
  const retract = () => {
    if (!pinned) setState("closed");
  };
  const open = () => {
    setPinned(true);
    setState("open");
    autoPeekDone.current = true;
  };
  const close = () => {
    setPinned(false);
    setState("closed");
    autoPeekDone.current = true;
  };
  const toggle = () => (pinned ? close() : open());

  // The terminal only drops when fully open. Hovering instead widens the
  // notch (Dynamic-Island style), so peek/closed both keep it tucked away.
  const translate = isOpen ? "translateY(0%)" : "translateY(-102%)";

  return (
    <figure
      className="relative mx-auto w-full max-w-5xl select-none"
      onMouseEnter={peek}
      onMouseLeave={retract}
      onKeyDown={(e) => {
        if (e.key === "Escape" && isOpen) close();
      }}
    >
      {/* Soft ambient glow beneath the device (design: diffused, low-opacity). */}
      <div
        aria-hidden
        className="absolute inset-x-8 -bottom-8 top-16 -z-10 rounded-[3rem] bg-accent/20 blur-3xl"
      />

      {/* The display / bezel. */}
      <div className="relative overflow-hidden rounded-[1.75rem] bg-primary p-[3px] shadow-[0_40px_90px_-30px_rgba(29,27,23,0.45)] ring-1 ring-black/5 sm:rounded-[2.25rem] sm:p-[6px]">
        {/* Screen (clips the terminal so it tucks up behind the top edge). */}
        <div className="relative aspect-[16/10] overflow-hidden rounded-[1.5rem] sm:rounded-[1.9rem]">
          {/* Scenic desktop wallpaper — sky over a lake, so the black terminal pops. */}
          <div
            aria-hidden
            className="absolute inset-0 bg-gradient-to-b from-[#2f74b5] via-[#5ba3d6] to-[#0e3d55]"
          >

          </div>

          {/* Bottom hint (discoverability on the web). */}
          <p className="pointer-events-none absolute inset-x-0 bottom-3.5 text-center font-mono text-[10px] uppercase tracking-[0.22em] text-white/55 sm:text-[11px]">
            {isOpen
              ? "Esc or ✕ to tuck away"
              : state === "peek"
                ? "Tap to open the terminal"
                : "Hover or tap the notch ↓"}
          </p>

          {/* Terminal window — hangs from the top, clipped when tucked up. */}
          <div
            id="notch-terminal"
            role="region"
            aria-label="NotchTerm terminal preview"
            aria-hidden={state === "closed"}
            className="absolute inset-x-0 top-0 z-20 mx-auto flex h-[86%] w-[94%] origin-top flex-col overflow-hidden rounded-b-[1.25rem] bg-[#050506]/95 shadow-[0_30px_60px_-15px_rgba(0,0,0,0.6)] ring-1 ring-white/10 backdrop-blur-sm will-change-transform sm:w-[90%]"
            style={{
              transform: translate,
              transition: reduced
                ? undefined
                : "transform 640ms var(--ease-out-soft)",
            }}
          >
            {/* Tab bar / window chrome. */}
            <div className="flex items-center gap-2 px-3 pt-3 pb-2.5">
              <span className="flex items-center gap-2 rounded-lg bg-white/10 px-3 py-1.5 font-mono text-[11px] text-white/85 sm:text-[12px]">
                sergiobehr…/Documents
                <span
                  aria-hidden
                  className="text-white/40 transition-colors hover:text-white/70"
                >
                  ✕
                </span>
              </span>
              <span
                aria-hidden
                className="px-1 font-mono text-base leading-none text-white/40"
              >
                +
              </span>
              <span className="flex-1" />
              <button
                type="button"
                onClick={close}
                aria-label="Close terminal"
                tabIndex={isOpen ? 0 : -1}
                className="rounded p-0.5 font-mono text-sm leading-none text-white/45 transition-colors hover:text-white/90"
              >
                ✕
              </button>
            </div>

            {/* Session. */}
            <div className="flex-1 overflow-hidden px-4 pb-4 font-mono text-[12px] leading-relaxed sm:text-[13.5px]">
              <p className="font-semibold text-[#4dd6c8]">{CWD}</p>
              <div className="mt-0.5 flex flex-wrap items-baseline">
                <span className="mr-2 text-[#6ee787]">❯</span>
                <span className="text-white/90">
                  {COMMAND.slice(0, typed)}
                  {!done && typed < COMMAND.length && <Cursor />}
                </span>
              </div>

              <div className="mt-2 space-y-1">
                {OUTPUT.slice(0, lines).map((l) => (
                  <p key={l.text} className={toneClass[l.tone]}>
                    {l.text}
                  </p>
                ))}
              </div>

              {done && (
                <div className="mt-2 flex items-baseline">
                  <span className="mr-2 text-[#6ee787]">❯</span>
                  <Cursor />
                </div>
              )}
            </div>
          </div>

          {/* The notch — a clean black pill that expands sideways on hover
              (Dynamic-Island style) and drops the terminal on tap. Fades out
              when open so the terminal top reads as one clean surface. */}
          <button
            type="button"
            onClick={toggle}
            onFocus={peek}
            onBlur={retract}
            aria-expanded={isOpen}
            aria-controls="notch-terminal"
            aria-label={isOpen ? "Close terminal" : "Open terminal"}
            className={`absolute left-1/2 top-0 z-30 -translate-x-1/2 overflow-hidden rounded-b-[1.1rem] bg-black outline-offset-4 sm:rounded-b-[1.25rem] ${
              state === "peek"
                ? "h-11 w-[17rem] sm:h-12 sm:w-[21rem]"
                : "h-8 w-40 sm:h-9 sm:w-48"
            }`}
            style={{
              opacity: isOpen ? 0 : 1,
              pointerEvents: isOpen ? "none" : "auto",
              transition: reduced
                ? "opacity 300ms"
                : "width 420ms var(--ease-out-soft), height 420ms var(--ease-out-soft), opacity 260ms",
            }}
          >
            {/* Affordance revealed as the island grows. */}
            <span
              className="pointer-events-none absolute inset-0 flex items-center justify-center gap-2 text-white/75 transition-opacity duration-200"
              style={{ opacity: state === "peek" ? 1 : 0 }}
            >
              <span className="h-1.5 w-1.5 rounded-full bg-[#6ee787] shadow-[0_0_8px_#6ee787]" />
              <span className="font-mono text-[11px] tracking-wide">
                Open terminal
              </span>
              <svg
                viewBox="0 0 24 24"
                className="h-3.5 w-3.5"
                aria-hidden
                style={
                  reduced
                    ? undefined
                    : { animation: "notch-hint 2.2s ease-in-out infinite" }
                }
              >
                <path
                  d="M6 9l6 6 6-6"
                  fill="none"
                  stroke="currentColor"
                  strokeWidth={2}
                  strokeLinecap="round"
                  strokeLinejoin="round"
                />
              </svg>
            </span>
          </button>
        </div>
      </div>

      <figcaption className="sr-only">
        Interactive preview: a terminal that drops down from the macOS notch.
      </figcaption>
    </figure>
  );
}
