import {defineConfig} from '@rsbuild/core';
import { pluginReact } from '@rsbuild/plugin-react';
import { pluginModuleFederation } from '@module-federation/rsbuild-plugin';
import { pluginTypeCheck } from "@rsbuild/plugin-type-check";

export default defineConfig({
  plugins: [
    pluginModuleFederation({
      name: "user_profile", // valid name with underscore, '-' not allowed
      remotes: {
        payments: `payments@${process.env.PAYMENTS_URL}/mf-manifest.json`
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
