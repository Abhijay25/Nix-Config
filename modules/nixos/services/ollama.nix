{ ... }: {
  # Disabled. Nothing on this machine was actually issuing inference requests —
  # the daemon only woke on a timer to refresh its model-recommendations cache,
  # which is pure network and CPU cost on a 15 W laptop tuned for battery life.
  # Re-enable here (and set `package = pkgs.ollama-cpu;` — no CUDA/ROCm on doge)
  # if local inference is wanted again; `enable = false` also keeps it off boot.
  services.ollama.enable = false;
}
