// Snowpack Configuration File
// See all supported options: https://www.snowpack.dev/reference/configuration
const fs = require('fs');

module.exports = {
  mount: {
      src: "/dist",
      public: "/"
  },
  plugins: [
      'snowpack-plugin-elm',
      '@snowpack/plugin-sass',
      '@snowpack/plugin-typescript'
  ],
  packageOptions: {
      source: 'remote',
      types: true
  },
  devOptions: {
    /* ... */
  },
  buildOptions: {
    /* ... */
  },
  routes: [{ 
      match: "routes", 
      src: ".*", 
      dest: "/index.html" 
  }]
};
