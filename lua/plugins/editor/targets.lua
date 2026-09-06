-- Seek-ahead a/i text objects: edit `ci)`, `ci"`, `caa` from anywhere on the
-- line without first moving into the pair. `cin)` / `cil)` jump to the
-- next / last pair. No counts, no symbol-layer navigation.
return {
  "wellle/targets.vim",
  event = "VeryLazy",
}
