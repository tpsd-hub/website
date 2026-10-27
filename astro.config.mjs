// @ts-check
import { defineConfig } from 'astro/config';
import tailwindcss from '@tailwindcss/vite';

// https://astro.build/config
export default defineConfig({
  // The site is now a single page; keep the old URL working.
  redirects: { '/beyond-the-build': '/#beyond-the-build' },
  vite: { plugins: [tailwindcss()] },
});
