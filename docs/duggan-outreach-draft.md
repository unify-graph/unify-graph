# Outreach Draft — Patrick Duggan (DugganUSA)

**To:** contact@dugganusa.com
**Subject:** Open-source Epstein network model — potential API collaboration

---

Hi Patrick,

I've been building an open-source investigation model of the Epstein network and wanted to reach out because our projects are complementary in a way that could be mutually useful.

**What I've built:** A typed data model (using CUE schema) of 132 entities and 398 connections, with D3 visualizations focused on structural analysis — sole connectors, evidence gaps, cluster fragility, cascade failure modeling. The core idea is mapping what's *missing*, not just what's known. The graph analysis uses NetworkX for betweenness centrality, PageRank, community detection, and k-core decomposition to surface structurally important but under-evidenced entities.

- Live site: https://unify-graph.github.io/unify-graph/
- Comparison page (positions both projects): https://unify-graph.github.io/unify-graph/compare.html
- Source: https://github.com/unify-graph/unify-graph

**How DugganUSA fits:** Your search index is the best corpus layer I've found — I've already used your API for entity discovery (scripts/discover.py queries your epstein_files index). My visualization has an "evidence gap scatter" that plots DugganUSA mention counts against documented evidence, highlighting entities your corpus found but that still lack formal evidence links.

**What I'd like to propose:**

1. **Live API search from entity inspector** — When a user clicks an entity in the graph, the inspector panel would query your API and show matching documents inline. This gives your index visibility to a different audience (people doing structural analysis rather than keyword search).

2. **Cross-reference data sharing** — I have Wikidata QIDs for 114/132 entities, ProPublica 990 data for foundations, and NetworkX graph metrics. Happy to share any of this if useful for your project.

3. **Attribution** — The comparison page already credits DugganUSA as the corpus/search layer. I'd add proper API attribution in the inspector panel and link back to your site.

No rush on any of this. If you're interested in any of it, or have ideas for how the projects could work together, I'd enjoy the conversation.

Best,
[Your name]

---

## Notes for sending
- GitHub: dugganusa
- Review the comparison page before sending to make sure DugganUSA is accurately described
- The API endpoint we already use: `https://analytics.dugganusa.com/api/v1/search?q=QUERY&indexes=epstein_files`
- Consider whether to mention the rate limiting we've been doing (0.5s delay between requests)
