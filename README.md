
# ICP Decentralized AI Tutor — Starter

This is an end‑to‑end starter you can deploy locally with `dfx`.
It includes Motoko canisters for **profile**, **assessment**, **vector index**, a mock **llm**, the **tutor** orchestrator, and a minimal React frontend.

> The LLM canister here is a **mock** so you can run everything offline. Swap it with a real LLM canister later.

## Prereqs
- DFX SDK: `sh -ci "$(curl -fsSL https://smartcontracts.org/install.sh)"`
- Node 18+ and pnpm/npm/yarn

## Run (Local)
```bash
# in repo root
dfx start --background

# deploy canisters
dfx deploy

# note canister IDs
dfx canister id tutor

# (optional) seed content into vector index
dfx canister call vector upsert_chunk '(record { id="c1"; topic="algebra"; chunk="Pythagorean theorem: a^2 + b^2 = c^2"; emb=vec {1.0;2.0;3.0}; url="https://example.org/pythagoras" })'

# build frontend
cd frontend
npm install
npm run dev   # http://localhost:5173
```

### Hook the frontend to your local tutor canister
Update `frontend/src/App.tsx` and set `TUTOR_CANISTER_ID` to the value from `dfx canister id tutor`.

## Production
Deploy canisters to `ic` and serve the built frontend via the `frontend` asset canister (already configured in `dfx.json`).

## Next steps
- Replace mock LLM with a real LLM canister (expose `promptVariant` and `embed`).
- Add Internet Identity login and secure per‑principal reads/writes.
- Implement Elo/BKT in `tutor` and connect to `assessment` grading.
- Expand `vector` similarity to HNSW or PQ if your corpus grows.
```

# Decentralized-Ai-tutor
