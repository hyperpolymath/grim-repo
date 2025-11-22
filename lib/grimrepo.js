// ==UserScript==
// @name         GrimRepo Scripts
// @namespace    https://grimrepo.dev/
// @version      1.0.0
// @description  Modular audit-grade tooling for narratable repositories
// @author       GrimRepo Contributors
// @match        https://gitlab.com/*
// @match        https://github.com/*
// @match        https://bitbucket.org/*
// @grant        GM_getValue
// @grant        GM_setValue
// @license      MIT AND Palimpsest-0.8
// ==/UserScript==

// SPDX-License-Identifier: MIT AND Palimpsest-0.8

/**
 * Minimal JavaScript glue code for GrimRepo
 * Core logic is in ReScript (compiles to WASM for performance)
 */

(function() {
  'use strict';

  // Import ReScript-compiled modules (will be bundled)
  // In production, this would load the WASM module

  const VERSION = '1.0.0';

  // Platform detection
  function detectPlatform() {
    const hostname = window.location.hostname.toLowerCase();

    if (hostname.includes('gitlab')) return 'gitlab';
    if (hostname.includes('github')) return 'github';
    if (hostname.includes('bitbucket')) return 'bitbucket';

    return 'unknown';
  }

  // Extract repository context from URL
  function getRepositoryContext() {
    const platform = detectPlatform();

    if (platform === 'unknown') {
      return null;
    }

    const path = window.location.pathname;
    const parts = path.split('/').filter(p => p.length > 0);

    if (parts.length < 2) {
      return null;
    }

    return {
      platform,
      repoOwner: parts[0],
      repoName: parts[1],
      currentPath: '/' + parts.slice(2).join('/')
    };
  }

  // Initialize GrimRepo
  function init() {
    const context = getRepositoryContext();

    if (!context) {
      console.log('[GrimRepo] Not on a supported platform or repository page');
      return;
    }

    console.log(`[GrimRepo] v${VERSION} initialized on ${context.platform} for ${context.repoOwner}/${context.repoName}`);

    // Future: Inject UI, run audits, etc.
    // For now, just log that we're ready
  }

  // Auto-initialize when DOM is ready
  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', init);
  } else {
    init();
  }

  // Expose API for programmatic use
  window.GrimRepo = {
    version: VERSION,
    detectPlatform,
    getRepositoryContext,
    init
  };

})();
