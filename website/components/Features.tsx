import type { ComponentType, SVGProps } from "react";
import { BoltIcon, EyeIcon, KeyboardIcon, SparkIcon } from "./icons";

type Feature = {
  icon: ComponentType<SVGProps<SVGSVGElement>>;
  title: string;
  body: string;
};

const FEATURES: Feature[] = [
  {
    icon: EyeIcon,
    title: "Always available",
    body: "Toggle the terminal with a top-edge gesture or hover. It stays tucked away until the exact moment you need it.",
  },
  {
    icon: SparkIcon,
    title: "Claude integration",
    body: "Native, low-latency access to Claude in the terminal. Get coding help without ever switching windows.",
  },
  {
    icon: BoltIcon,
    title: "System native",
    body: "Built for Apple Silicon and macOS. An optimized Swift backend keeps CPU near zero when idle.",
  },
  {
    icon: KeyboardIcon,
    title: "Zero friction",
    body: "No window management. No CMD-Tab cycles. Just pure flow state in your existing screen real estate.",
  },
];

export default function Features() {
  return (
    <section id="features" className="py-section-gap scroll-mt-24">
      <div className="mx-auto max-w-7xl px-margin-mobile md:px-margin-desktop">
        <div className="mx-auto mb-16 max-w-2xl text-center">
          <p className="mb-4 font-mono text-label-sm uppercase text-accent-dim">
            Why NotchTerm
          </p>
          <h2 className="font-display text-headline-lg text-balance text-white">
            A terminal that gets out of your way
          </h2>
        </div>

        <ul className="grid grid-cols-1 gap-gutter sm:grid-cols-2 lg:grid-cols-4">
          {FEATURES.map(({ icon: Icon, title, body }) => (
            <li
              key={title}
              className="group rounded-xl border border-white/5 bg-white/[0.03] p-7 transition-colors hover:border-white/10 hover:bg-white/[0.05]"
            >
              <span className="flex h-11 w-11 items-center justify-center rounded-lg bg-accent/10 text-[22px] text-accent-dim">
                <Icon />
              </span>
              <h3 className="mt-6 font-display text-headline-md text-white">
                {title}
              </h3>
              <p className="mt-3 text-body-md leading-relaxed text-white/55">
                {body}
              </p>
            </li>
          ))}
        </ul>
      </div>
    </section>
  );
}
