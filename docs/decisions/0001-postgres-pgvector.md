# 0001: Use Postgres with pgvector for all storage

- Date: Day 1
- Status: accepted
- Deciders: Team

## Context
We need relational data (labs, papers, grants) and vector search (embeddings) with a small team and a 4-week timeline.

## Options considered
1. Postgres + pgvector in one database (Supabase)
2. Postgres + a separate vector database (Pinecone, Qdrant)

## Decision
Option 1. One database, one connection string, joins between vectors and metadata, free tier is enough.

## Consequences
Simpler ops. If we outgrow pgvector we can migrate, but that is unlikely at our scale.
