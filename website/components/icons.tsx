import type { SVGProps } from "react";

/**
 * Inline, tree-shaken SVG icons — no icon font, no external request, no CLS.
 * Stroke icons use 1.75px rounded caps/joins to match the UI geometry.
 */

type IconProps = SVGProps<SVGSVGElement>;

const stroke = {
  fill: "none" as const,
  stroke: "currentColor",
  strokeWidth: 1.75,
  strokeLinecap: "round" as const,
  strokeLinejoin: "round" as const,
};

function Base({ children, ...props }: IconProps & { children: React.ReactNode }) {
  return (
    <svg
      viewBox="0 0 24 24"
      width="1em"
      height="1em"
      aria-hidden="true"
      focusable="false"
      {...props}
    >
      {children}
    </svg>
  );
}

/** Apple wordmark glyph (filled) — for "Download for Mac". */
export function AppleIcon(props: IconProps) {
  return (
    <Base {...props}>
      <path
        fill="currentColor"
        d="M16.365 1.43c0 1.14-.417 2.2-1.11 2.98-.837.94-2.2 1.66-3.34 1.57-.14-1.12.42-2.31 1.09-3.05.75-.83 2.06-1.44 3.14-1.5.02.14.02.28.02.42v-.42Zm3.09 16.2c-.56 1.29-.83 1.86-1.55 3-1.01 1.59-2.43 3.57-4.19 3.58-1.57.02-1.97-1.02-4.1-1.01-2.13.01-2.57 1.03-4.14 1.01-1.76-.02-3.11-1.81-4.12-3.4C-1.4 18.6-1.68 12.53 1.03 9.32c1.11-1.32 2.86-2.16 4.51-2.16 1.68 0 2.74 1.03 4.13 1.03 1.35 0 2.17-1.03 4.11-1.03 1.47 0 3.03.8 4.14 2.18-3.64 1.99-3.05 7.18.53 8.29Z"
      />
    </Base>
  );
}

export function TerminalIcon(props: IconProps) {
  return (
    <Base {...props}>
      <rect x="3" y="4" width="18" height="16" rx="2.5" {...stroke} />
      <path d="m7 9 3 3-3 3M13 15h4" {...stroke} />
    </Base>
  );
}

export function EyeIcon(props: IconProps) {
  return (
    <Base {...props}>
      <path d="M2.5 12S6 5.5 12 5.5 21.5 12 21.5 12 18 18.5 12 18.5 2.5 12 2.5 12Z" {...stroke} />
      <circle cx="12" cy="12" r="3" {...stroke} />
    </Base>
  );
}

export function SparkIcon(props: IconProps) {
  return (
    <Base {...props}>
      <path d="M12 3v4M12 17v4M4.5 12h4M15.5 12h4" {...stroke} />
      <path
        d="M12 8.5c.6 2 .9 2.4 2.9 3 -2 .6-2.3 1-2.9 3 -.6-2-.9-2.4-2.9-3 2-.6 2.3-1 2.9-3Z"
        {...stroke}
      />
    </Base>
  );
}

export function BoltIcon(props: IconProps) {
  return (
    <Base {...props}>
      <path d="M13 2 4.5 13H11l-1 9 8.5-11H12l1-9Z" {...stroke} />
    </Base>
  );
}

export function KeyboardIcon(props: IconProps) {
  return (
    <Base {...props}>
      <rect x="2.5" y="6" width="19" height="12" rx="2.5" {...stroke} />
      <path
        d="M6 9.5h.01M9.5 9.5h.01M13 9.5h.01M16.5 9.5h.01M6 13h.01M18 13h.01M9 13h6"
        {...stroke}
      />
    </Base>
  );
}

export function PlayIcon(props: IconProps) {
  return (
    <Base {...props}>
      <circle cx="12" cy="12" r="9" {...stroke} />
      <path d="m10 8.5 5 3.5-5 3.5V8.5Z" fill="currentColor" stroke="currentColor" strokeWidth={1.5} strokeLinejoin="round" />
    </Base>
  );
}

export function CheckBadgeIcon(props: IconProps) {
  return (
    <Base {...props}>
      <path
        d="M12 2.5 14.4 4l2.8-.2 1 2.6 2.3 1.6-.7 2.7.7 2.7-2.3 1.6-1 2.6-2.8-.2L12 21.5 9.6 20l-2.8.2-1-2.6-2.3-1.6.7-2.7-.7-2.7 2.3-1.6 1-2.6 2.8.2L12 2.5Z"
        {...stroke}
      />
      <path d="m8.5 12 2.4 2.4 4.6-4.8" {...stroke} />
    </Base>
  );
}

/** Circular arrows — "try again" on the error pages. */
export function RetryIcon(props: IconProps) {
  return (
    <Base {...props}>
      <path d="M20 11a8 8 0 1 0-.6 4" {...stroke} />
      <path d="M20 4.5V11h-6.5" {...stroke} />
    </Base>
  );
}

export function ArrowDownIcon(props: IconProps) {
  return (
    <Base {...props}>
      <path d="M12 5v14M6 13l6 6 6-6" {...stroke} />
    </Base>
  );
}
