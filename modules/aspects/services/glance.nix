{ lib, ... }:
{
  flake.modules.nixos.glance =
    { ... }:
    {
      services.glance = {
        enable = true;
        settings = {
          theme = {
            background-color = "0 0 16";
            primary-color = "43 59 81";
            positive-color = "61 66 44";
            negative-color = "6 96 59";
          };

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
                      location = "Belo Horizonte, Brazil";
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
                  ];
                }
                {
                  size = "small";
                  widgets = [
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
                            {
                              title = "Firelfy";
                              url = "https://firefly.hugovaz.dev/login";
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
                          name = "NixOS Server (Skinner)";
                          type = "local";
                        }
                      ];
                    }
                  ];
                }
              ];
            }
            {
              name = "News";
              columns = [
                {
                  size = "full";
                  widgets = [
                    {
                      type = "group";
                      widgets = [
                        {
                          type = "rss";
                          title = "Folha de S.Paulo";
                          limit = 15;
                          collapse-after = 10;
                          cache = "2h";
                          feeds = [
                            { url = "https://feeds.folha.uol.com.br/emcimadahora/rss091.xml"; }
                          ];
                        }
                        {
                          type = "rss";
                          title = "UOL";
                          limit = 15;
                          collapse-after = 10;
                          cache = "2h";
                          feeds = [
                            { url = "http://rss.home.uol.com.br/index.xml"; }
                          ];
                        }
                        {
                          type = "rss";
                          title = "The Rio Times";
                          limit = 15;
                          collapse-after = 10;
                          cache = "2h";
                          feeds = [
                            { url = "https://riotimesonline.com/feed/"; }
                          ];
                        }
                        {
                          type = "rss";
                          title = "Brasil Wire";
                          limit = 15;
                          collapse-after = 10;
                          cache = "2h";
                          feeds = [
                            { url = "http://www.brasilwire.com/feed/"; }
                          ];
                        }
                        {
                          type = "rss";
                          title = "Jornal de Brasília";
                          limit = 15;
                          collapse-after = 10;
                          cache = "2h";
                          feeds = [
                            { url = "https://jornaldebrasilia.com.br/feed/"; }
                          ];
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
