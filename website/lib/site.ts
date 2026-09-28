// Keep APP_VERSION in sync with MARKETING_VERSION in the app's project.yml.
export const APP_VERSION = "0.3";
export const MIN_MACOS = "15";

// Served as a GitHub Pages project site, so everything lives under /NotchTerm.
// Keep BASE_PATH in sync with basePath in next.config.mjs.
export const BASE_PATH = "/NotchTerm";
export const SITE_URL = `https://sbehrends.github.io${BASE_PATH}`;

/** Prefix a root-relative path with BASE_PATH (for URLs Next doesn't rewrite). */
export const withBase = (path: string) => `${BASE_PATH}${path}`;

export const GITHUB_URL = "https://github.com/sbehrends/NotchTerm";
export const DOWNLOAD_URL = `${GITHUB_URL}/releases`;
