# GitHub Pages

The landing page is plain HTML and CSS in `docs/index.html` and `docs/style.css`.
It uses the existing screenshots and needs no build tools.

## Preview locally

From the repository root:

```sh
python3 -m http.server 8765 --directory docs
```

Open http://localhost:8765.

## Publish

1. Commit and push the page and `.github/workflows/pages.yml` to `main`.
2. In the repository's **Settings → Pages → Build and deployment**, choose **GitHub Actions** as the source.
3. Run **Deploy GitHub Pages** from the Actions tab if the initial push happened before Pages was enabled.

After a successful deployment, the site is available at:
https://lutfullahkabalak.github.io/prayer-times-for-mac/

Future changes to `docs/` on `main` deploy automatically. Publishing a GitHub
release also redeploys the site. Before upload, `scripts/update-site-download.py`
resolves the latest stable release ZIP and updates all three download links and
the schema URLs in the deployed HTML. Buttons download the ZIP directly without
opening the release page. A missing ZIP fails deployment instead of publishing
a broken download link. No browser-side JavaScript or API call is needed.

For a local preview with the latest URLs, run:

```sh
python3 scripts/update-site-download.py
```

GitHub documentation:
https://docs.github.com/en/pages/getting-started-with-github-pages/using-custom-workflows-with-github-pages

## Search and AI discovery

The homepage includes a canonical URL, crawler meta tag, social sharing tags,
and JSON-LD describing the SoftwareApplication, website, and visible FAQ.
`sitemap.xml` lists the canonical homepage. `llms.txt` provides factual English
and Turkish context with authoritative links, and is linked from the homepage.
It is a proposed convention, not a guarantee of ingestion or recommendation by
any AI service. No invented ratings, reviews, or affiliation claims are included.
SoftwareApplication markup alone does not guarantee Google rich results; the
project currently has no verified review/rating data for that eligibility.

### GitHub project-path limitation

This site lives at `/prayer-times-for-mac/`. Crawlers look for robots.txt at
`https://lutfullahkabalak.github.io/robots.txt`, so the project-level robots.txt
cannot control crawling. Merge the supplied sitemap declaration and rules into
the root robots.txt in the separate `lutfullahkabalak.github.io` user-site repo,
preserving any existing policies for other projects. An absent robots.txt does
not by itself block crawling. Some tools also discover llms.txt only at the host
root; link this project's llms.txt from the root site if you maintain one.

### After publication

1. Verify the public canonical URL and sitemap return HTTP 200.
2. Add a URL-prefix property for the full project URL in Google Search Console.
3. Complete ownership verification using the HTML file or meta tag supplied by
   Google; do not add a placeholder verification token.
4. Submit the full sitemap URL and request indexing of the homepage.
5. Validate JSON-LD with Schema.org Validator; use Google Rich Results Test to
   check Google-specific eligibility, which is separate from schema validity.
6. Link the public website from the GitHub repository's About website field and
   README after publication. Keep features and download details accurate.

References:
- https://developers.google.com/search/docs/appearance/structured-data/software-app
- https://developers.google.com/search/docs/crawling-indexing/robots/create-robots-txt
- https://llmstxt.org/
