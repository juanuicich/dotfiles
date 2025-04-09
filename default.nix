{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    btop      # Interactive process viewer
    curl      # HTTP requests
    fzf       # Command-line fuzzy finder
    git       # Version control
    gnupg     # GNU Pretty Good Privacy (PGP)
    jq        # JSON processor
    lnav      # Curses-based tool for viewing log files
    vim       # Text editor
    zsh       # Shell
  ];
}
