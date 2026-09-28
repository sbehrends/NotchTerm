// Flat config (ESLint 9). Next 16 removed `next lint`; run ESLint directly.
import nextCoreWebVitals from "eslint-config-next/core-web-vitals";

const config = [
  ...nextCoreWebVitals,
  { ignores: ["out/**", ".next/**", "node_modules/**"] },
];

export default config;
