{ lib, ... }:
{
  flake.modules.nixos.glance =
    { ... }:
    {
      services.glance = {
        enable = true;
        settings = {
          server = {
            host = "127.0.0.1";
            port = 6969;
            proxied = true;
          };

          pages = [
            {
              name = "Home";
              columns = [
                {
                  size = "small";
                  widgets = [
                    {
                      type = "calendar";
                      first-day-of-week = "monday";
                    }
                    {
                      type = "weather";
                      location = "São Paulo, Brazil";
                      units = "metric";
                      hour-format = "24h";
                    }
                    {
                      type = "clock";
                      hour-format = "24h";
                    }
                  ];
                }
                {
                  size = "full";
                  widgets = [
                    {
                      type = "hacker-news";
                      limit = 15;
                      collapse-after = 5;
                    }
                    {
                      type = "rss";
                      title = "Tech Blogs";
                      limit = 15;
                      collapse-after = 5;
                      cache = "6h";
                      feeds = [
                        {
                          url = "https://selfh.st/rss/";
                          title = "selfh.st";
                          limit = 5;
                        }
                        {
                          url = "https://www.joshwcomeau.com/rss.xml";
                          title = "Josh Comeau";
                        }
                        {
                          url = "https://samwho.dev/rss.xml";
                          title = "samwho";
                        }
                      ];
                    }
                    {
                      type = "releases";
                      cache = "2h";
                      repositories = [
                        "glanceapp/glance"
                        "nixos/nixpkgs"
                        "immich-app/immich"
                        "syncthing/syncthing"
                        "tailscale/tailscale"
                      ];
                    }
                  ];
                }
                {
                  size = "small";
                  widgets = [
                    {
                      type = "search";
                      search-engine = "duckduckgo";
                      bangs = [
                        {
                          title = "YouTube";
                          shortcut = "!yt";
                          url = "https://www.youtube.com/results?search_query={QUERY}";
                        }
                        {
                          title = "GitHub";
                          shortcut = "!gh";
                          url = "https://github.com/search?q={QUERY}";
                        }
                        {
                          title = "Nix Packages";
                          shortcut = "!nix";
                          url = "https://search.nixos.org/packages?query={QUERY}";
                        }
                      ];
                    }
                    {
                      type = "bookmarks";
                      groups = [
                        {
                          title = "Self-Hosted";
                          links = [
                            {
                              title = "Vaultwarden";
                              url = "https://vaultwarden.hugovaz.dev";
                            }
                            {
                              title = "SearXNG";
                              url = "https://searx.hugovaz.dev";
                            }
                            {
                              title = "Pastebin";
                              url = "https://pastebin.hugovaz.dev";
                            }
                          ];
                        }
                        {
                          title = "Dev";
                          links = [
                            {
                              title = "GitHub";
                              url = "https://github.com";
                            }
                            {
                              title = "NixOS Search";
                              url = "https://search.nixos.org";
                            }
                          ];
                        }
                      ];
                    }
                    {
                      type = "server-stats";
                      servers = [
                        {
                          name = "NixOS Server";
                          type = "local";
                        }
                      ];
                    }
                  ];
                }
              ];
            }
          ];
        };
      };

      security.acme = {
        acceptTerms = true;
        defaults.email = lib.mkDefault "admin@hugovaz.dev";
      };

      services.nginx = {
        recommendedTlsSettings = true;
        recommendedGzipSettings = true;
        recommendedOptimisation = true;

        virtualHosts."glance.hugovaz.dev" = {
          enableACME = true;
          forceSSL = true;
          locations."/" = {
            proxyPass = "http://127.0.0.1:6969";
            proxyWebsockets = true;
          };
        };
      };

      networking.firewall.allowedTCPPorts = lib.mkAfter [ 80 443 ];
    };
}
