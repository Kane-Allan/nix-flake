{ lib, vars, ... }:
let
  isPersonal = vars.host == "laptop";
  profileName = if isPersonal then "Personal" else "Work";

  mkExtension = slug: default_area: {
    install_url = "https://addons.mozilla.org/firefox/downloads/latest/${slug}/latest.xpi";
    installation_mode = "normal_installed";
    inherit default_area;
  };

  commonExtensions = {
    "uBlock0@raymondhill.net" = mkExtension "ublock-origin" "menupanel";
    "addon@darkreader.org" = mkExtension "darkreader" "menupanel";
    "vimium-c@gdh1995.cn" = mkExtension "vimium-c" "menupanel";
    "idcac-pub@guus.ninja" = mkExtension "istilldontcareaboutcookies" "menupanel";
  };

  hostExtensions =
    if isPersonal then
      {
        "{446900e4-71c2-419f-a6a7-df9c091e268b}" = mkExtension "bitwarden-password-manager" "navbar";
        "{732216ec-0dab-43bb-ac85-4b5e1977599d}" = mkExtension "surfshark-vpn-proxy" "navbar";
      }
    else
      {
        "KeeperFFStoreExtension@KeeperSecurityInc" = mkExtension "keeper-password-manager" "navbar";
      };

  commonWidgets = [
    "ublock0_raymondhill_net-browser-action"
    "addon_darkreader_org-browser-action"
    "vimium-c_gdh1995_cn-browser-action"
    "idcac-pub_guus_ninja-browser-action"
  ];

  hostWidgets =
    if isPersonal then
      [
        "_446900e4-71c2-419f-a6a7-df9c091e268b_-browser-action"
        "_732216ec-0dab-43bb-ac85-4b5e1977599d_-browser-action"
      ]
    else
      [ "keeperffstoreextension_keepersecurityinc-browser-action" ];

  navBarWidgets = [
    "sidebar-button"
    "back-button"
    "forward-button"
    "stop-reload-button"
    "vertical-spacer"
    "urlbar-container"
  ]
  ++ hostWidgets
  ++ [ "unified-extensions-button" ];

  toolbarState = {
    placements = {
      "widget-overflow-fixed-list" = [ ];
      "unified-extensions-area" = commonWidgets;
      "nav-bar" = navBarWidgets;
      "toolbar-menubar" = [ "menubar-items" ];
      TabsToolbar = [ ];
      "vertical-tabs" = [ "tabbrowser-tabs" ];
      PersonalToolbar = [ "personal-bookmarks" ];
    };
    seen = commonWidgets ++ hostWidgets;
    dirtyAreaCache = [
      "nav-bar"
      "vertical-tabs"
      "PersonalToolbar"
      "toolbar-menubar"
      "TabsToolbar"
      "unified-extensions-area"
    ];
    currentVersion = 24;
    newElementCount = 0;
  };
in
{
  programs.firefox = {
    enable = true;

    policies = {
      AIControls.Default = {
        Value = "blocked";
        Locked = true;
      };
      AutofillCreditCardEnabled = false;
      OfferToSaveLogins = false;
      ExtensionSettings = commonExtensions // hostExtensions;
    };

    profiles.${profileName} = {
      id = 0;
      name = profileName;
      isDefault = true;

      settings = {
        "sidebar.revamp" = true;
        "sidebar.verticalTabs" = true;
        "sidebar.verticalTabs.dragToPinPromo.dismissed" = true;
        "browser.privatebrowsing.resetPBM.enabled" = false;
        "browser.uiCustomization.navBarWhenVerticalTabs" = builtins.toJSON navBarWidgets;
        "browser.uiCustomization.state" = builtins.toJSON toolbarState;
      };

      search = lib.mkIf isPersonal {
        force = true;
        default = "searxng";
        privateDefault = "searxng";
        engines.searxng = {
          name = "SearXNG";
          urls = [
            {
              template = "https://searxng.enak-nalla.dev/search";
              params = [
                {
                  name = "q";
                  value = "{searchTerms}";
                }
              ];
            }
            {
              template = "https://searxng.enak-nalla.dev/autocompleter";
              type = "application/x-suggestions+json";
              params = [
                {
                  name = "q";
                  value = "{searchTerms}";
                }
              ];
            }
          ];
          definedAliases = [ "@sx" ];
        };
      };
    };
  };

  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "text/html" = [ "firefox.desktop" ];
      "x-scheme-handler/http" = [ "firefox.desktop" ];
      "x-scheme-handler/https" = [ "firefox.desktop" ];
      "x-scheme-handler/about" = [ "firefox.desktop" ];
      "x-scheme-handler/unknown" = [ "firefox.desktop" ];
    };
  };
}
