// SPDX-License-Identifier: PMPL-1.0-or-later
// GrimPager: Perpetual auto-paging with ReScript optimization
// License: https://github.com/hyperpolymath/palimpsest-license
// Version: 1.0.0

// --- MODULE 1: TYPES (The Schema) ---
module Types = {
  type action =
    | Standard      // Normal page append
    | Iframe        // Load in iframe
    | Dynamic       // AJAX-based loading

  type rule = {
    url: Js.Re.t,              // URL pattern matcher
    next: string,              // Next page link selector
    page: string,              // Content container selector
    action: option<action>,    // Loading strategy
    preload: option<bool>,     // Preload next page?
  }

  type engineState = {
    mutable loading: bool,
    mutable pageNum: int,
    mutable lastScrollY: float,
  }
}

// --- MODULE 2: DATABASE (Homoiconic Rule Set) ---
// This replaces thousands of lines of JSON with type-safe ReScript
module Database = {
  open Types

  // Helper for concise rule creation
  let rule = (~url, ~next, ~page, ~action=?, ~preload=?, ()) => {
    url: Js.Re.fromStringWithFlags(url, ~flags="i"),
    next,
    page,
    action,
    preload,
  }

  // Curated rule set (expandable to thousands)
  let rules = [
    // Search Engines
    rule(~url="google\\..*/search", ~next="#pnnext", ~page="#center_col", ()),
    rule(~url="bing\\.com/search", ~next=".sb_pagN", ~page="#b_results", ()),
    rule(~url="duckduckgo\\.com", ~next=".result--more", ~page="#links", ()),

    // Developer Platforms
    rule(~url="github\\.com/[^/]+/[^/]+/issues", ~next=".pagination > a:last-child", ~page=".js-navigation-container", ()),
    rule(~url="github\\.com/[^/]+/[^/]+/commits", ~next=".pagination > a:last-child", ~page=".commits-list-container", ()),
    rule(~url="stackoverflow\\.com/questions", ~next=".s-pagination--item:last-child", ~page="#questions", ()),
    rule(~url="gitlab\\.com", ~next=".next_page", ~page=".projects-list", ()),

    // Video Platforms
    rule(~url="youtube\\.com/results", ~next="#load-more-button", ~page="#contents", ~action=Dynamic, ()),
    rule(~url="bilibili\\.com/video", ~next="a.next", ~page=".bangumi-list", ()),

    // Social Media
    rule(~url="twitter\\.com|x\\.com", ~next="", ~page="[data-testid='primaryColumn']", ~action=Dynamic, ()),
    rule(~url="reddit\\.com/r/", ~next="", ~page="#siteTable", ~action=Dynamic, ()),

    // News & Blogs
    rule(~url="medium\\.com", ~next="", ~page="article", ~action=Dynamic, ()),
    rule(~url="dev\\.to", ~next=".crayons-pagination__link--next", ~page=".crayons-story", ()),

    // Package Registries
    rule(~url="npmjs\\.com/search", ~next=".pagination > a:last-child", ~page=".search-results", ()),
    rule(~url="crates\\.io/crates", ~next=".pagination > .next", ~page=".crate-rows", ()),
    rule(~url="pypi\\.org/search", ~next=".button--next", ~page=".package-snippet", ()),
  ]
}

// --- MODULE 3: ENGINE (The Core Logic) ---
module Engine = {
  open Types

  // DOM Bindings
  @val @scope("document")
  external querySelector: string => Js.Nullable.t<Dom.element> = "querySelector"

  @val @scope("document")
  external querySelectorAll: string => array<Dom.element> = "querySelectorAll"

  @val @scope("window")
  external scrollY: float = "scrollY"

  @val @scope("document") @scope("body")
  external clientHeight: float = "clientHeight"

  @val @scope("window")
  external innerHeight: float = "innerHeight"

  // GM API Bindings
  module GM = {
    @scope("GM") @val
    external getValue: (string, 'a) => promise<'a> = "getValue"

    @scope("GM") @val
    external setValue: (string, 'a) => promise<unit> = "setValue"

    @scope("GM") @val
    external xmlHttpRequest: {..} => promise<{..}> = "xmlHttpRequest"

    @scope("GM") @val
    external addStyle: string => unit = "addStyle"

    @scope("GM") @val
    external registerMenuCommand: (string, unit => unit) => unit = "registerMenuCommand"
  }

  // State management
  let state: engineState = {
    loading: false,
    pageNum: 1,
    lastScrollY: 0.0,
  }

  // Find matching rule for current URL
  let findRule = (currentUrl: string): option<rule> => {
    Database.rules->Belt.Array.getBy(r => Js.Re.test_(r.url, currentUrl))
  }

  // Smart fallback detection (when no rule matches)
  let detectPagination = (): option<(string, string)> => {
    // Common pagination patterns
    let nextPatterns = [
      "a.next", "a.next-page", ".pagination-next",
      "a[rel='next']", ".pager-next", "a:contains('Next')",
    ]

    let contentPatterns = [
      "main", "article", ".content", "#content",
      ".posts", ".items", ".results",
    ]

    let findFirst = (patterns) => {
      patterns->Belt.Array.reduce(None, (acc, pattern) => {
        switch acc {
        | Some(_) => acc
        | None => {
            let elem = querySelector(pattern)
            Js.Nullable.toOption(elem)->Belt.Option.map(_ => pattern)
          }
        }
      })
    }

    switch (findFirst(nextPatterns), findFirst(contentPatterns)) {
    | (Some(next), Some(page)) => Some((next, page))
    | _ => None
    }
  }

  // Load next page content
  let loadNextPage = async (nextUrl: string, pageSelector: string) => {
    if state.loading {
      Js.Console.warn("⏳ Already loading...")
      ()
    } else {
      state.loading = true
      Js.Console.log(`📄 Loading: ${nextUrl}`)

      try {
        let response = await GM.xmlHttpRequest({
          "method": "GET",
          "url": nextUrl,
        })

        // Parse HTML response
        let parser = %raw(`new DOMParser()`)
        let doc = %raw(`parser.parseFromString(response.responseText, "text/html")`)

        let newContent = %raw(`doc.querySelector(pageSelector)`)
        let currentContainer = querySelector(pageSelector)

        switch Js.Nullable.toOption(currentContainer) {
        | Some(container) => {
            %raw(`container.appendChild(newContent)`)
            state.pageNum = state.pageNum + 1
            Js.Console.log(`✅ Page ${Belt.Int.toString(state.pageNum)} loaded`)
          }
        | None => Js.Console.error("❌ Container not found")
        }

        state.loading = false
      } catch {
      | exn => {
          Js.Console.error2("❌ Load failed:", exn)
          state.loading = false
        }
      }
    }
  }

  // Scroll detection
  let onScroll = (nextSelector: string, pageSelector: string) => {
    let currentScroll = scrollY
    let threshold = clientHeight -. innerHeight -. 500.0

    if currentScroll > threshold && currentScroll > state.lastScrollY {
      let nextLink = querySelector(nextSelector)

      switch Js.Nullable.toOption(nextLink) {
      | Some(link) => {
          let href = %raw(`link.href`)
          if href != "" {
            loadNextPage(href, pageSelector)->ignore
          }
        }
      | None => Js.Console.warn("⚠️ No next link found")
      }
    }

    state.lastScrollY = currentScroll
  }

  // Initialize engine
  let init = (version: string) => {
    Js.Console.log(`🚀 GrimPager v${version} - Perpetual Scrolling Engine`)

    let currentUrl = %raw(`window.location.href`)

    // Try to find a rule
    let matchedRule = findRule(currentUrl)

    switch matchedRule {
    | Some(rule) => {
        Js.Console.log("✓ Rule matched - Activating auto-pager")

        // Set up scroll listener
        %raw(`window.addEventListener("scroll", () => onScroll(rule.next, rule.page))`)

        // Add visual indicator
        GM.addStyle(`
          .grimpager-indicator {
            position: fixed;
            bottom: 20px;
            right: 20px;
            padding: 10px 15px;
            background: rgba(0, 0, 0, 0.8);
            color: #fff;
            border-radius: 5px;
            font-family: monospace;
            font-size: 12px;
            z-index: 999999;
          }
        `)
      }
    | None => {
        Js.Console.log("ℹ️ No rule found - Attempting smart detection")

        switch detectPagination() {
        | Some((next, page)) => {
            Js.Console.log(`🔍 Auto-detected: next=${next}, page=${page}`)
            %raw(`window.addEventListener("scroll", () => onScroll(next, page))`)
          }
        | None => Js.Console.log("❌ Could not detect pagination")
        }
      }
    }

    // Register menu commands
    GM.registerMenuCommand("GrimPager: Toggle", () => {
      Js.Console.log("Menu clicked")
    })
  }
}

// --- MODULE 4: ENTRY POINT ---
@val external version: string = "METADATA_VERSION"
Engine.init(version)
