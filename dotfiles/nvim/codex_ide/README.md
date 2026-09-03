# Codex IDE IPC provider

This Neovim-only provider targets **codex-cli 0.152.1** (`rust-v0.152.1`,
`5adb68a49933ae446bf11935662c83dba55a0804`), verified 2026-09-02. Sidekick is
locked at `208e1c5b8170c01fd1d07df0139322a76479b235` in `lazy-lock.json`.

`<Leader>zc` records the current editor state, starts the provider, opens (or
focuses) Sidekick's `codex` terminal, and submits `/ide on` once for that terminal
process. It intentionally does not alter the older `<Leader>x…` mappings.

## Protocol

On Unix the listener is `$CODEX_HOME/ipc/ipc.sock`. This configuration creates
a private, temporary `CODEX_HOME` per Neovim process and passes it to that
instance's Sidekick Codex terminal; separate Neovim instances therefore never
contend for a socket or exchange IDE context. It links the normal Codex home’s
credentials, configuration, sessions, session index, and history into the
private home, so `/resume` retains the usual shared session list. Codex
processes launched outside Sidekick retain their usual `~/.codex/ipc/ipc.sock`.
Each message is UTF-8 JSON
prefixed with a four-byte, unsigned, little-endian payload length. Frames over
256 MiB are rejected. Each client has a five-second idle/request deadline.

The only accepted request is:

```json
{"type":"request","requestId":"id","method":"ide-context","version":0,"params":{"workspaceRoot":"/repo"}}
```

The reply preserves `requestId` and is either `resultType: "success"` with
`result.ideContext`, or `resultType: "error"` with
`request-version-mismatch` / `no-handler-for-request`. The successful context
has `activeFile` (label, relative-or-absolute `path`, absolute `fsPath`,
zero-based UTF-16 end-exclusive `selection`, `activeSelectionContent`) and
`openTabs`. Paths beneath the supplied workspace root are relative; all others
remain absolute. Listed normal named buffers are tabs; terminals, special, and
unnamed buffers are excluded.

The success result carries the upstream-required `result.type: "broadcast"`
envelope, but this provider does not implement broadcast messages or routing.

Selection text is editor content, not instructions trusted by this integration:
Codex receives it as ordinary IDE context. The provider has no router,
initialization/discovery compatibility layer, broadcasts, legacy temp socket,
diagnostics, MCP bridge, or diff approval. Each private home supports one
Neovim provider and one Codex process; multiple Neovim/Codex pairs are
isolated from one another. Unix only.

After IDE context has been enabled for a Sidekick Codex session, Visual
selections are captured automatically as Visual mode begins and whenever the
selection changes. `<Leader>zc` is needed to open/focus that session and enable
`/ide`; it is not needed again to refresh later selections.

The socket and wire protocol, five-second deadline, limit, request errors, and
the response fields are source-confirmed in
[ipc.rs](https://github.com/openai/codex/blob/5adb68a49933ae446bf11935662c83dba55a0804/codex-rs/tui/src/ide_context/ipc.rs)
and
[ide_context/mod.rs](https://github.com/openai/codex/tree/5adb68a49933ae446bf11935662c83dba55a0804/codex-rs/tui/src/ide_context).
The use of Neovim visual regions and the mapping from editor positions to the
VS Code-compatible UTF-16/end-exclusive convention are inferred from those
editor semantics.

## Maintenance

For a new CLI release, resolve its release tag to a commit, then diff its
`codex-rs/tui/src/ide_context/` files (especially `ipc.rs`) against
`5adb68a49933ae446bf11935662c83dba55a0804`. Recheck the frame limit, socket
path, request envelope, result schema, and timeout; update this document and
the provider together. Finally, test `/ide status` and a multiline/multibyte
selection against the real CLI.
