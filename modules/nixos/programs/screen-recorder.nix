{ ... }: {
  # Backend for the noctalia screen_recorder bar widget, which shells out to
  # gpu-screen-recorder. The module also generates the setcap wrappers needed
  # for promptless KMS capture.
  programs.gpu-screen-recorder.enable = true;
}
