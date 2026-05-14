# shared

Support plugin providing shared adapters for documentation and issue-tracking.

Other plugins reference these adapters by path to publish documents and tickets
to their configured destinations. See `adapters/README.md` for the adapter
pattern and `.docs-driven/config.json` for configuration.

This is a support dependency, not a feature plugin. It must be present for any
plugin that publishes documentation or issues.
