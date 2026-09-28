/** @type {import('next').NextConfig} */
const nextConfig = {
  // Fully static site — emits a self-contained `out/` directory that can be
  // served from any CDN or static host with zero runtime.
  output: "export",
  // GitHub Pages project site: https://sbehrends.github.io/NotchTerm/
  // Keep in sync with BASE_PATH in lib/site.ts.
  basePath: "/NotchTerm",
  reactStrictMode: true,
  // next/image optimization requires a server; disable it for static export
  // and rely on correctly-sized, modern-format assets instead.
  images: { unoptimized: true },
  // Emit `path/index.html` so links work without a server rewrite layer.
  trailingSlash: true,
  productionBrowserSourceMaps: false,
};

export default nextConfig;
