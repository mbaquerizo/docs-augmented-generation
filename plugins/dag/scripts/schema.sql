-- DB Adapter Schema for dag-publish
-- Source: .dag/docs/design/db-adapter-schema.md
-- Version: 1

-- Schema version tracking
CREATE TABLE IF NOT EXISTS _migrations (
    id INTEGER PRIMARY KEY,
    version INTEGER NOT NULL,
    applied_at TEXT NOT NULL DEFAULT (datetime('now'))
);

-- Relation types for issue-to-issue edges (blocks, duplicates, etc.)
CREATE TABLE IF NOT EXISTS relations (
    id INTEGER PRIMARY KEY,
    name TEXT NOT NULL UNIQUE,
    created_at TEXT NOT NULL DEFAULT (datetime('now')),
    updated_at TEXT NOT NULL DEFAULT (datetime('now'))
);

-- Tags for classifying docs and issues
CREATE TABLE IF NOT EXISTS tags (
    id INTEGER PRIMARY KEY,
    name TEXT NOT NULL UNIQUE,
    created_at TEXT NOT NULL DEFAULT (datetime('now')),
    updated_at TEXT NOT NULL DEFAULT (datetime('now'))
);

-- Documents (ADRs, code explorations, pitches, etc.)
CREATE TABLE IF NOT EXISTS docs (
    id INTEGER PRIMARY KEY,
    type TEXT NOT NULL,
    title TEXT NOT NULL,
    body TEXT,
    status TEXT NOT NULL DEFAULT 'proposed',
    parent_id INTEGER REFERENCES docs(id),
    group_id TEXT,
    created_at TEXT NOT NULL DEFAULT (datetime('now')),
    updated_at TEXT NOT NULL DEFAULT (datetime('now'))
);

-- Issues (epics, stories, tasks, bugs, spikes)
CREATE TABLE IF NOT EXISTS issues (
    id INTEGER PRIMARY KEY,
    type TEXT NOT NULL,
    title TEXT NOT NULL,
    body TEXT,
    status TEXT NOT NULL DEFAULT 'open',
    parent_id INTEGER REFERENCES issues(id),
    created_at TEXT NOT NULL DEFAULT (datetime('now')),
    updated_at TEXT NOT NULL DEFAULT (datetime('now'))
);

-- Directional typed edges between issues
CREATE TABLE IF NOT EXISTS issue_relations (
    id INTEGER PRIMARY KEY,
    source_issue_id INTEGER NOT NULL REFERENCES issues(id),
    relation_id INTEGER NOT NULL REFERENCES relations(id),
    target_issue_id INTEGER NOT NULL REFERENCES issues(id),
    created_at TEXT NOT NULL DEFAULT (datetime('now')),
    updated_at TEXT NOT NULL DEFAULT (datetime('now'))
);

-- Doc-to-issue cross-references
CREATE TABLE IF NOT EXISTS doc_issues (
    id INTEGER PRIMARY KEY,
    doc_id INTEGER NOT NULL REFERENCES docs(id),
    issue_id INTEGER NOT NULL REFERENCES issues(id),
    relationship_type TEXT NOT NULL,
    created_at TEXT NOT NULL DEFAULT (datetime('now'))
);

-- Tag assignments
CREATE TABLE IF NOT EXISTS doc_tags (
    id INTEGER PRIMARY KEY,
    doc_id INTEGER NOT NULL REFERENCES docs(id),
    tag_id INTEGER NOT NULL REFERENCES tags(id),
    created_at TEXT NOT NULL DEFAULT (datetime('now'))
);

CREATE TABLE IF NOT EXISTS issue_tags (
    id INTEGER PRIMARY KEY,
    issue_id INTEGER NOT NULL REFERENCES issues(id),
    tag_id INTEGER NOT NULL REFERENCES tags(id),
    created_at TEXT NOT NULL DEFAULT (datetime('now'))
);

-- Indices
CREATE INDEX IF NOT EXISTS idx_docs_parent_id ON docs(parent_id);
CREATE INDEX IF NOT EXISTS idx_docs_type ON docs(type);
CREATE INDEX IF NOT EXISTS idx_docs_group_id ON docs(group_id);
CREATE INDEX IF NOT EXISTS idx_issues_parent_id ON issues(parent_id);
CREATE INDEX IF NOT EXISTS idx_issues_type ON issues(type);
CREATE INDEX IF NOT EXISTS idx_issue_relations_source ON issue_relations(source_issue_id);
CREATE INDEX IF NOT EXISTS idx_issue_relations_target ON issue_relations(target_issue_id);
CREATE INDEX IF NOT EXISTS idx_doc_issues_doc ON doc_issues(doc_id);
CREATE INDEX IF NOT EXISTS idx_doc_issues_issue ON doc_issues(issue_id);
CREATE INDEX IF NOT EXISTS idx_doc_tags_doc ON doc_tags(doc_id);
CREATE INDEX IF NOT EXISTS idx_doc_tags_tag ON doc_tags(tag_id);
CREATE INDEX IF NOT EXISTS idx_issue_tags_issue ON issue_tags(issue_id);
CREATE INDEX IF NOT EXISTS idx_issue_tags_tag ON issue_tags(tag_id);
