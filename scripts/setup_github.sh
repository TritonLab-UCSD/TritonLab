#!/usr/bin/env bash
# Creates TritonLab labels, milestones, and Day 1 + Week 1 issues using the GitHub CLI.
#
# Usage:
#   gh auth login
#   REPO=your-org/tritonlab ./scripts/setup_github.sh                  # no assignees
#   REPO=your-org/tritonlab A=userA B=userB C=userC ./scripts/setup_github.sh  # with assignees
set -euo pipefail

: "${REPO:?Set REPO=org/tritonlab}"
# A, B, C are optional. Leave them unset to create issues without assignees
# and assign them later on the board.
A="${A:-}"; B="${B:-}"; C="${C:-}"

echo "==> Labels"
label() { gh label create "$1" --repo "$REPO" --color "$2" --description "$3" --force; }
label data      1f77b4 "Ingestion, warehouse, entity resolution"
label ml        9467bd "Embeddings, ranking, classifiers, evaluation"
label llm       e377c2 "Prompts, RAG, guardrails, LLM evals"
label frontend  2ca02c "Streamlit app and API"
label infra     7f7f7f "Repo, CI, database, deployment"
label docs      bcbd22 "Documentation"
label feature   17becf "Planned work"
label bug       d62728 "Something is broken"
label spike     ff7f0e "Time-boxed research"
label stretch   c5b0d5 "Only if ahead of schedule"
label day-1     000000 "Day 1 setup"

echo "==> Milestones"
milestone() {
  gh api "repos/$REPO/milestones" -f title="$1" -f description="$2" >/dev/null 2>&1 \
    || echo "   (milestone '$1' may already exist)"
}
milestone "Day 1: Setup"            "Repo, database, app skeleton, data dictionary, sample data"
milestone "Week 1: End to end"      "Profile in, real recommendations, summaries, and drafts out"
milestone "Week 2: Make it smart"   "Grants, entity resolution, re-ranking, guardrails, tracker"
milestone "Week 3: Production"      "Automated, deployed, polished"
milestone "Week 4: Beta and launch" "Real users, public launch, write-ups"

echo "==> Issues"
issue() {
  # issue <title> <labels> <assignee> <milestone> <body>
  local assignee_args=()
  if [ -n "$3" ]; then assignee_args=(--assignee "$3"); fi
  gh issue create --repo "$REPO" --title "$1" --label "$2" "${assignee_args[@]}" \
    --milestone "$4" --body "$5" >/dev/null
  echo "   created: $1"
}

D1="Day 1: Setup"
W1="Week 1: End to end"

# ---------------- Day 1 ----------------
issue "Repo setup: branch protection, board, CI check" "infra,day-1" "$A" "$D1" "## Goal
Make the repo enforce our workflow.

## Steps
- Push the scaffold to main.
- Settings > Branches: protect main (require PR, 1 approval, CI status check \`lint-and-test\`, no direct pushes).
- Settings > General: allow squash merge only, auto-delete head branches.
- Create a GitHub Project (board) with columns Backlog, Ready, In Progress, In Review, Done and link this repo.
- Add teammates as collaborators with Write access.

## Done when
- [ ] A test PR cannot merge without passing CI and one approval.
- [ ] All issues appear on the board."

issue "Database: Supabase Postgres + pgvector + initial schema" "infra,data,day-1" "$B" "$D1" "## Goal
Shared database everyone can use.

## Steps
- Create a Supabase project (free tier). Save the connection string.
- Put \`DATABASE_URL\` in your \`.env\` and share it with teammates privately (not in the repo).
- Add \`DATABASE_URL\` as a GitHub Actions secret for later.
- Run \`make db-init\` to apply \`db/migrations/001_init.sql\`.

## Done when
- [ ] All tables exist in the Supabase table editor.
- [ ] Every teammate runs \`make db-init\` or a test query successfully from their machine."

issue "App skeleton: FastAPI, Streamlit, LLM helper, Docker" "frontend,llm,infra,day-1" "$C" "$D1" "## Goal
Everyone can run the app locally and call the LLM.

## Steps
- Confirm \`make api\` serves /health and \`make app\` shows API status.
- Get an LLM API key, set \`LLM_API_KEY\` and \`LLM_MODEL\` in \`.env\`.
- Add a tiny script or test proving \`llm.client.complete()\` returns text.
- Confirm \`docker build .\` succeeds.
- Create the team Discord/Slack channel and post the standup time.

## Done when
- [ ] App and API run locally for all three people.
- [ ] A successful LLM call is demonstrated."

issue "Finalize data dictionary and contracts" "docs,data,day-1" "$A" "$D1" "## Goal
Agree on every table before splitting up. (Whole team, 1 hour. Person A edits.)

## Steps
- Walk through \`docs/data_dictionary.md\` table by table.
- Change anything that doesn't fit the chosen domain; update \`db/migrations\` to match.

## Done when
- [ ] PR merged with all three approvals."

issue "Sample dataset: 15 labs from Person A" "data,day-1" "$A" "$D1" "Add 15 labs to \`data/sample/labs_sample.csv\` (name, PI, website, 3 recent paper titles + abstracts, undergrad evidence).

## Done when
- [ ] 15 complete rows committed."
issue "Sample dataset: 15 labs from Person B" "data,day-1" "$B" "$D1" "Add 15 labs to \`data/sample/labs_sample.csv\` (name, PI, website, 3 recent paper titles + abstracts, undergrad evidence).

## Done when
- [ ] 15 complete rows committed."
issue "Sample dataset: 15 labs from Person C" "data,day-1" "$C" "$D1" "Add 15 labs to \`data/sample/labs_sample.csv\` (name, PI, website, 3 recent paper titles + abstracts, undergrad evidence).

## Done when
- [ ] 15 complete rows committed."

issue "Student profiles: 2 each (6 total)" "ml,day-1" "$B" "$D1" "Each person adds 2 realistic profiles to \`data/sample/student_profiles.csv\`. Person B coordinates and checks variety (year, major, specificity).

## Done when
- [ ] 6 profiles committed."

issue "Fill in docs/team.md and working agreements" "docs,day-1" "$C" "$D1" "Names, GitHub usernames, signature pieces, standup time, channel, sprint lead for Week 1.

## Done when
- [ ] PR merged."

# ---------------- Week 1 ----------------
issue "OpenAlex connector: UCSD researchers and papers" "data,feature" "$A" "$W1" "## Goal
Pull UCSD researchers and 2021+ papers in our domain into the \`raw\` schema.

## Steps
- Look up UC San Diego's OpenAlex institution ID.
- Filter works by institution + domain topics, from 2021 onward.
- Use \`mailto=\$OPENALEX_EMAIL\` for the polite pool; cursor paging; retries.
- Upsert on OpenAlex ID so reruns don't duplicate.

## Done when
- [ ] Researchers and papers load into raw tables.
- [ ] Rerunning creates no duplicates.
- [ ] Unit test for parsing one API response."

issue "Reconstruct abstracts, dbt staging models and tests" "data,feature" "$A" "$W1" "## Goal
Clean, tested staging tables.

## Steps
- Rebuild abstracts from OpenAlex \`abstract_inverted_index\`.
- dbt staging models: researchers, papers, authorships.
- dbt tests: unique and not_null on keys.

## Done when
- [ ] \`make dbt\` passes on the full pull."

issue "Faculty directory scraper + rule-based linking to OpenAlex" "data,feature" "$A" "$W1" "## Goal
Get names, titles, departments, and emails from public faculty pages and link to OpenAlex.

## Steps
- requests + BeautifulSoup; respect robots.txt; rate limit; contact email in User-Agent.
- Rule: last name + first initial + UCSD affiliation.
- Build \`lab\` v1: one lab per PI.

## Done when
- [ ] Most domain faculty are linked, and the link rate is reported in the PR."

issue "Embedding pipeline + recommend(profile, k)" "ml,feature" "$B" "$W1" "## Goal
First working recommender on the 45-lab sample.

## Steps
- Embed abstracts with a small sentence-transformer model.
- Lab vector = recency-weighted mean of its abstracts. Store in \`embedding\`.
- \`matching.recommend(profile, k)\` returns top-k labs by cosine similarity.

## Done when
- [ ] Any profile returns top 10 in under 1 second."

issue "BM25 baseline + labeled eval set" "ml,feature" "$B" "$W1" "## Goal
A baseline to beat and labels to measure against.

## Steps
- BM25 over lab abstracts with rank-bm25.
- For each of the 6 profiles, pool top 15 from both methods.
- Run a 30-minute team labeling session: good fit / maybe / poor fit.

## Done when
- [ ] \`matching/eval/labels.csv\` committed."

issue "Eval script: precision@10, NDCG@10, MLflow" "ml,feature" "$B" "$W1" "## Goal
Measure every model the same way.

## Steps
- Compute precision@10 and NDCG@10 from the labeled set.
- Log every run to MLflow (model, params, metrics).
- Compare embeddings vs BM25.

## Done when
- [ ] Results table for both methods in \`matching/README.md\`."

issue "Streamlit pages: profile form, results, lab page" "frontend,feature" "$C" "$W1" "## Goal
The screens students will use, on sample data first.

## Steps
- Profile form: interests, courses, skills, resume PDF upload with text extraction.
- Results list with lab name, PI, match score.
- Lab detail page with papers and contact info.

## Done when
- [ ] All three pages work on sample data."

issue "Paper explainer prompt v1" "llm,feature" "$C" "$W1" "## Goal
Plain-language summaries of a lab's recent papers.

## Steps
- \`llm/prompts/paper_explainer_v1.txt\`: use only the provided abstracts, undergraduate reading level, cite each paper.

## Done when
- [ ] Readable summaries for 5 sample labs pasted into the PR."

issue "Outreach draft prompt v1 + editable draft UI" "llm,frontend,feature" "$C" "$W1" "## Goal
A grounded first-draft email.

## Steps
- Retrieve the lab's abstracts from the DB; reference one specific paper; connect to the student's profile.
- Editable text box in the app.

## Done when
- [ ] Drafts generate for sample labs and each names a real paper."

issue "FastAPI endpoints + connect app to real DB" "frontend,feature" "$C" "$W1" "## Goal
App runs on real data through the API.

## Steps
- \`/recommend\`, \`/lab/{id}\`, \`/draft\`.
- Streamlit calls the API instead of reading sample files.

## Done when
- [ ] End-to-end: profile in, real recommendations and a draft out."

issue "Friday: Week 1 demo, retro, handoffs" "docs" "$A" "$W1" "## Steps
- Demo the end-to-end flow.
- Retro: keep, change, try.
- Handoff notes in \`docs/handoffs/\` using the template: A->C (Data), B->A (ML), C->B (LLM + App).
- 30-minute walkthroughs.
- Create Week 2 issues.

## Done when
- [ ] Three handoff notes merged and Week 2 issues exist."

echo "==> Done. Add all issues to your Project board (Project > Settings > Workflows > Auto-add, or add manually)."
