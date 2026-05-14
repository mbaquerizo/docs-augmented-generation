<!--
Insert context about what adapters are: publishing instructions that are configurable within the plugin.

There are 2 adapter types: documentation (i.e. local, Confluence, Notion, DB), and issue-tracking (i.e. local, Jira, Linear, DB)
Each adapter type will have a structured schema with data about how to publish, and each adapter will be designed to know what to do with that data. This configuration will be scoped to the project.
Once these are set, the sibling skills that publish anything will use the configured adapter settings.

Potential gotcha: mixing local and cloud adapters can affect references, need to design a fallback for local references in cloud docs/issues (i.e. how to link to local) - either disallow (local docs and issues only), partially disallow (local issue-tracking can link to cloud ADR/code exploration, but not vice versa), or copy (risks contamination/context overload)
-->