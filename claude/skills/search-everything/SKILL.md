---
name: search-everything
description: Search across multiple platforms (web + X/Twitter) for comprehensive results
user_invocable: true
---

When the user invokes /search-everything with a query:

1. Run BOTH of these searches in parallel:
   - Use `WebSearch` to search the general web
   - Use `mcp__grok__search_x` to search X/Twitter content via Grok

2. Synthesize the results into a unified summary:
   - Group findings by theme, not by source
   - Clearly attribute each piece of information to its source (Web or X)
   - Highlight any contradictions or differing perspectives between sources
   - Surface the most recent and relevant information first

3. If the query is about a person, company, or event, prioritize real-time X content for sentiment and reactions, and web results for factual/background information.
