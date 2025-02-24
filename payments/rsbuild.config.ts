import { defineConfig } from '@rsbuild/core';
import { pluginReact } from '@rsbuild/plugin-react';
import { pluginModuleFederation } from '@module-federation/rsbuild-plugin';
import { pluginTypeCheck } from "@rsbuild/plugin-type-check";

export default defineConfig({
  output: {
    assetPrefix: process.env.PAYMENTS_CDN_URL,
  },
  plugins: [
    pluginModuleFederation({
      name: "payments",
      exposes: {
        './Payments': './src/Payments.tsx'
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
      }
    }),
    pluginTypeCheck(),
    pluginReact(),
  ],
  server: {
    port: 3001,
    base: '/payments',
  },
});
