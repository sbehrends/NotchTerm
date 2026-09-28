import type { SVGProps } from "react";

/**
 * The NotchTerm mark — the small-size app icon (Figma: "Favicon (full-bleed,
 * no shadow)"), same geometry as public/favicon.svg: copper rim with the notch
 * cut through the top edge, dark screen, >_ prompt. Thick strokes keep it
 * legible at 16–48px, where the detailed icon (public/logo.png) would mush.
 *
 * `idPrefix` must be unique per instance on a page: gradient ids are global to
 * the document, so two marks sharing one prefix would emit duplicate ids.
 */
export default function Logo({
  idPrefix,
  ...props
}: SVGProps<SVGSVGElement> & { idPrefix: string }) {
  const rim = `${idPrefix}-rim`;
  const screen = `${idPrefix}-screen`;

  return (
    <svg viewBox="0 0 824 824" width="1em" height="1em" role="img" {...props}>
      <defs>
        <linearGradient
          id={rim}
          x1="117.714"
          y1="118.54"
          x2="705.598"
          y2="707.111"
          gradientUnits="userSpaceOnUse"
        >
          <stop stopColor="#EE914A" />
          <stop offset="1" stopColor="#B9561C" />
        </linearGradient>
        <linearGradient
          id={screen}
          x1="412"
          y1="56.7441"
          x2="412"
          y2="768"
          gradientUnits="userSpaceOnUse"
        >
          <stop stopColor="#08080A" />
          <stop offset="1" stopColor="#2C2D31" />
        </linearGradient>
      </defs>

      <path
        fill={`url(#${rim})`}
        d="M622.192 0.962891C667.585 2.65373 697.77 7.31476 722.988 20.1641C757.798 37.9006 786.099 66.2018 803.836 101.012C824 140.585 824 192.39 824 296V528C824 631.61 824 683.415 803.836 722.988C786.099 757.798 757.798 786.099 722.988 803.836C683.415 824 631.61 824 528 824H296C192.39 824 140.585 824 101.012 803.836C66.2018 786.099 37.9006 757.798 20.1641 722.988C0.000268181 683.415 0 631.61 0 528V296C0 192.39 0.000268181 140.585 20.1641 101.012C37.9006 66.2018 66.2018 37.9006 101.012 20.1641C126.23 7.31485 156.415 2.65376 201.807 0.962891C235.958 6.59455 262 36.2511 262 72V74C262 101.62 284.38 124 312 124H512C539.62 124 562 101.62 562 74V72C562 36.2515 588.041 6.59494 622.192 0.962891Z"
      />
      <path
        fill={`url(#${screen})`}
        d="M629.163 56.7441C659.771 57.9821 680.331 61.2797 697.564 70.0605C721.837 82.4282 741.572 102.163 753.939 126.436C768 154.03 768 190.154 768 262.4V561.6C768 633.846 768 669.97 753.939 697.564C741.572 721.837 721.837 741.572 697.564 753.939C669.97 768 633.846 768 561.6 768H262.4C190.154 768 154.03 768 126.436 753.939C102.163 741.572 82.4282 721.837 70.0605 697.564C56.0004 669.97 56 633.846 56 561.6V262.4C56 190.154 56.0004 154.03 70.0605 126.436C82.4282 102.163 102.163 82.4282 126.436 70.0605C143.669 61.2798 164.228 57.9821 194.836 56.7441C201.31 58.793 206 64.8458 206 72V74C206 132.54 253.46 180 312 180H512C570.54 180 618 132.54 618 74V72C618 64.8462 622.689 58.7932 629.163 56.7441Z"
      />
      {/* notch: black cut flush with the top edge; the rim wraps around it */}
      <path
        fill="#000"
        d="M190 0C229.77 0 262 32.23 262 72V74C262 101.62 284.38 124 312 124H512C539.62 124 562 101.62 562 74V72C562 32.23 594.23 0 634 0H190Z"
      />
      <path d="M218 320L368 428L218 536" stroke="#FFA24A" strokeWidth="84" fill="none" />
      <rect x="448" y="500" width="180" height="80" fill="#FFA24A" />
    </svg>
  );
}
