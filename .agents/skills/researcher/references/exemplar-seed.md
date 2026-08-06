# SEED: Kitchen Sink FFI Validation Suite

> Entry point for agentic development. Follow the loop: Validation → Feedback → repeat until holdout scenarios pass and stay passing.

> **This is a worked example, not a real project.** "Corvus" is fictional. It exists to
> show the *shape* of a good seed — a hard systems problem with a real validation
> harness — because Gene Transfusion works by pointing an agent at a concrete exemplar
> rather than an abstract template. Substitute your own project throughout.
>
> Note what is deliberately absent: ticket IDs, incident IDs, customer names, internal
> repo paths. A seed feeds `RESEARCH-BRIEF.md`, which gets dispatched to external
> providers in Step 1.5 and pasted into browser Deep Research in Step 1.6. Anything you
> put here should be assumed to leave the building. Keep internal anchors in your issue
> tracker and reference them by shape ("the circular-dependency analysis"), not by ID.

---

## What We're Building

A language-agnostic, end-to-end test suite that validates Corvus's `#[ffi_export]` surface entirely from C and WASM, independent of any SDK implementation.

The suite exercises the complete peer lifecycle: initialize, configure transport, execute queries, register observers, sync documents. It becomes the authoritative validation layer for all SDK FFI contracts — not just one or two languages — and is the proposed resolution to the SDK/Core circular dependency that currently blocks cross-SDK velocity.

**One-line version:** Prove the FFI boundary is correct without touching an SDK.

---

## Why This Exists

**Current state:** Validating Rust core changes requires SDK tests. SDK tests can't pass until all SDKs implement breaking core changes. This deadlock serializes delivery across every SDK team.

**Target state:** The FFI boundary is validated independently. Core ships. SDKs consume. The circular dependency is broken at the layer where it should be broken — the ABI contract itself.

**Secondary use case:** A black-box state verifier — a tool that uses this same C FFI surface to inspect store state in SDK integration tests without instrumenting the app under test.

---

## Validation Harness

> Must be end-to-end, as close to real as possible: real binary, real sync protocol, real platform matrix.

### Holdout Scenarios (loop runs until these pass and stay passing)

| # | Scenario | Platform |
|---|----------|----------|
| 1 | Initialize a peer handle from pure C using `#[ffi_export]` symbols | Linux x86_64, ARM64, macOS |
| 2 | Configure LAN-only transport (no cloud relay) | all |
| 3 | Execute an `INSERT` and a `SELECT` through the query API | all |
| 4 | Register a store observer; receive callback on mutation | all |
| 5 | Sync a document between two in-process C peers | all |
| 6 | All of the above under WASM async constraints | headless browser |
| 7 | FFI surface is ABI-stable across two consecutive core versions | Linux x86_64 |

### What "Real Environment" Means Here

- Real prebuilt core binary fetched at build time, via the same path the `*-sys` crate uses
- Real sync protocol, no stubbed transport
- WASM tests run in a browser-like async runtime — this is where async-only constraints surface, and where web targets actually fail
- CI matrix matches current SDK CI: Linux x86_64, ARM64, macOS
- No mocking of the Rust core layer

### What Is NOT "Real" (explicitly out of scope)

- Cloud relay sync (LAN-only for this seed)
- SDK-layer tests (those belong to the SDK teams' own suites)
- Performance benchmarking
- Bluetooth / transport-layer permissioning (separate CI infrastructure problem)

---

## Feedback Loop

Each run of the validation harness produces a feedback signal fed back into the inputs:

| Output | Fed Back As |
|--------|-------------|
| Pass/fail per holdout scenario | Patch scope for next iteration |
| `#[ffi_export]` symbol coverage map | Identifies gaps; drives new export PRs |
| ABI drift report (version N vs N+1) | Triggers FFI annotation fixes |
| WASM async failure traces | Identifies missing `async`/`Sync` bounds in the export surface |
| SDK integration test failures | Reclassified: FFI-layer bug vs. SDK-layer bug |

**Loop exit condition:** All holdout scenarios green across all target platforms, on two consecutive core version bumps.

---

## Apply More Tokens

> For every obstacle, ask: how can we convert this problem into a representation the model can understand?

| Obstacle | Token Form |
|----------|------------|
| Incomplete `#[ffi_export]` surface | Paste the generated C header as direct context |
| Which scenarios to cover | The SDK test-category breakdown (Init, Auth, Store Ops, Sync, Transports, Presence, Attachments, Observers, Transactions, …) as holdout spec |
| Incident replays | A past disconnect-loop incident as an adversarial sync scenario: does the C peer reproduce the infinite replay? |
| CI failure logs | CI traces as token input for debugging flaky WASM async tests |
| Existing SDK tests | Existing SDK test cases converted to C equivalents — what the C suite must cover to reach parity |
| WASM async constraints | Web CI failures as annotated failure transcripts |
| Customer integration context | A real customer-shaped configuration scenario the suite must exercise |

> Each row above names an internal artifact **by shape**, not by ID. That is the
> discipline: it tells the agent what kind of evidence to go get, without putting a
> ticket number into a file that will be pasted into a browser.

---

## Open Questions (Resolved)

> Keep the resolutions, not just the questions. The reasoning is the reusable part —
> a future agent needs to know *why* the boundary landed where it did, or it will
> relitigate the decision.

1. **Does the current `#[ffi_export]` surface cover enough to initialize a peer and configure LAN transport entirely from C, or do new exports need to land first?**

   **Yes — sufficient.** An existing pure-C example application (~1 KLOC, SDL2 + an immediate-mode UI) already drives the full peer lifecycle through the C FFI: init, P2P mesh sync, cloud-relay sync with auth, CRUD via parameterized queries, sync subscriptions, and the presence graph. It is the existence proof that holdout scenarios 1–5 are reachable from `#[ffi_export]` symbols today, with no new exports required to start the loop. Use it as the reference shape when porting holdout scenarios into the suite.

2. **Which WASM runtime is the test target — Node, or a headless browser?**

   **Headless Chrome + Firefox**, matching the established pattern in the repo's existing WASM test script. Node is rejected: it bypasses the browser async executor that web targets actually run against, so async-only failures would not surface. Running WASM tests in-browser is already the convention across the store, time, auth, and blob-storage crates, and CI installs both browsers for the WASM job. Sub-question worth flagging separately: whether to additionally cover a WASI target for a server-side/CLI variant (relevant to the black-box verifier in the secondary use case) — currently the repo only targets browser WASM.

3. **Does the black-box verifier share the same C test harness, or is it a downstream consumer of a stable harness?**

   **Downstream consumer.** The verifier does not exist yet — it is a forward-looking design — so we get to set the boundary. Set it as a consumer: it links against the same core binary and reuses the `#[ffi_export]` coverage map this suite produces, but ships as its own binary with its own UX (state inspection, store dumps) and its own release cadence. Reason: the kitchen-sink suite's job is to prove the FFI contract; the verifier's job is to *use* a known-good FFI contract from outside an app. Coupling them would force every UX change in the verifier through the validation harness's CI gate, and would entangle two release cadences for no architectural benefit. Worth flagging: an existing in-tree test-protocol tool takes a different approach — protocol-over-TCP into a Rust-SDK test app — and is not a substitute for C-FFI validation. The two are complementary; the verifier may end up speaking that protocol *and* linking the core binary, but that does not change the harness boundary.

4. **Who owns the ABI drift report format — this suite, or the `*-sys` crate?**

   **This suite owns the format. The `*-sys` crate stays a thin binary distributor.** The inputs already exist in-tree: a generated C header and a structured metadata JSON file, both emitted by the header-generation crate and committed to the repo. The suite consumes those two artifacts at versions N and N+1, diffs them, and produces the drift report. The `*-sys` crate only fetches the prebuilt binary and runs toolchain-mismatch checks — it does not parse headers or validate annotations, and pulling drift detection into a sys-crate would violate the convention that sys-crates are thin veneers. Hybrid escape hatch if downstream consumers need the report at install time: the suite remains the source of truth for the schema, and the report is published as an artifact alongside core releases for the sys-crate to surface opaquely.

---

*Seed authored: 2026-04-30. Loop not yet started. Holdout scenarios: not yet green.*
