import {defineConfig} from '@rsbuild/core';
import { pluginReact } from '@rsbuild/plugin-react';
import { pluginModuleFederation } from '@module-federation/rsbuild-plugin';
import { pluginTypeCheck } from "@rsbuild/plugin-type-check";

const cdn_url = process.env.CDN_URL;

export default defineConfig({
  output: {
    assetPrefix: cdn_url ? `${cdn_url}/user-profile` : undefined,
  },
  plugins: [
    pluginModuleFederation({
      name: "user_profile", // valid name with underscore, '-' not allowed
      remotes: {
        payments: `payments@${process.env.CDN_URL}/payments/mf-manifest.json`
      },
      exposes: {
        './UserProfile': './src/UserProfile.tsx'
      },
      shared: {
        "react": {
          singleton: true,
        },
        "react-dom": {
          singleton: true,
        },
        "ramda": {
          singleton: true,
        }
      },
    }),
    pluginTypeCheck(),
    pluginReact(),
  ],
  server: {
    port: 3000,
    base: '/user-profile',
  },
});
