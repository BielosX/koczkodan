import {defineConfig} from '@rsbuild/core';
import { pluginReact } from '@rsbuild/plugin-react';
import { pluginModuleFederation } from '@module-federation/rsbuild-plugin';

export default defineConfig({
  plugins: [
    pluginReact(),
    pluginModuleFederation({
      name: "user_profile", // valid name with underscore, '-' not allowed
      exposes: {
        './UserProfile': './src/UserProfile.tsx'
      },
      remotes: {
        payments: `payments@${process.env.PAYMENTS_URL}/mf-manifest.json`
      },
      shared: ["react", "react-dom"]
    })
  ],
  server: {
    port: 3000,
    base: '/user-profile'
  }
});
