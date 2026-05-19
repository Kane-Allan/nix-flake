{
  programs = {
    git = {
      enable = true;
      settings = {
        user = {
          name = "Kane Allan";
          email = "121622489+EnakNalla@users.noreply.github.com";
        };
        init.defaultBranch = "main";
        pull.rebase = true;
        push.autoSetupRemote = true;
        core.editor = "nvim";
      };
    };
    gh.enable = true;
  };
}
