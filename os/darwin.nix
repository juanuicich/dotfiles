{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    # macOS GUI Utilities
    rectangle           # GUI window manager
  ];

  services = {
  };

  system.defaults = {
    dock.autohide = true;
    finder.AppleShowAllExtensions = true;
    finder.FXPreferredViewStyle = "clmv";  # column view
    finder.ShowStatusBar = true;
    finder.ShowPathbar = true;
    finder.ShowTabView = true;
    finder.ShowSidebar = true;
    finder.ShowToolbar = true;
    screencapture.location = "~/Pictures/screenshots";
    screensaver.askForPasswordDelay = 0;
    security.pam.services.sudo_local.touchIdAuth = true;
  }
}
