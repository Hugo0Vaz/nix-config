# 🔍 Relatório de Auditoria — `nix-config`

**Repositório:** `/home/hugomvs/Projetos/nix-config`  
**Data:** 2026-06-17  
**Escopo:** Módulos NixOS, Home-Manager, scripts auxiliares, dotfiles e estrutura do flake.


---

---

## 🟡 Código Não Utilizado (Dead Code)

### 4. `noctalia.nix` — não importado por nenhum host

**Arquivos:** `modules/aspects/noctalia.nix`  
Define `flake.modules.nixos.noctalia` e `flake.modules.homeManager.noctalia` com opções `my.noctalia.enable`, `my.noctalia.config`. Nenhum host ou outro módulo referencia esses módulos. O pacote `noctalia-shell` nunca é instalado.

Se for um experimento ou feature futura, considere adicionar um comentário ou mover para um branch separado. Se for abandonado, remova.

---

### 5. `utc-time.nix` — não importado por nenhum host

**Arquivo:** `modules/aspects/utc-time.nix`  
Define `flake.modules.nixos.utc-time` com timezone UTC. Nenhum host o importa — todos os NixOS hosts usam `local-time.nix` (America/Sao_Paulo).

---

### 6. `nix-config-sync-check` — import comentado + código morto parcial

**Arquivos afetados:**
- `modules/hosts/nixos-notebook/configuration.nix:27` (comentado)
- `modules/hosts/nixos-kot225/configuration.nix:30` (comentado)
- `modules/hosts/nixos-workstation/configuration.nix:27` (comentado)
- `modules/aspects/nix-config-sync-check.nix` (módulo completo implementado mas não usado)

Em todos os 3 hosts desktop, o import está comentado e a opção `my.nixConfigSyncCheck.withNotifications = true` também está comentada. O módulo inteiro e o script `nix-config-sync-check.nix` existem mas nunca são ativados.

---

### 7. `grub-efi.nix` contém `environment.systemPackages` com `plymouth` que não precisaria

**Arquivo:** `modules/aspects/grub-efi.nix:38-40`
```nix
environment.systemPackages = with pkgs; [
  plymouth
];
```
`plymouth` como pacote de sistema só é útil para ferramentas como `plymouth-set-default-theme`. Se ninguém usa isso interativamente, é provavelmente desnecessário. O mesmo ocorre em `systemd-boot.nix`.

---

## 🟠 Más Práticas

### 8. `projman2000.nix` — arquivo com nome enganoso

O arquivo `modules/aspects/projman2000.nix` contém um módulo de deploy Laravel completo — nada relacionado a "projman2000". O nome do arquivo não corresponde ao conteúdo. Deveria ser renomeado para algo como `laravel-app.nix`.

---

### 9. `local-time.nix` — `timesyncd` + `ntp` conflitantes

**Arquivo:** `modules/aspects/local-time.nix:8-9`
```nix
services.timesyncd.enable = true;
services.ntp.enable = true;
```

Estes dois serviços são mutuamente exclusivos. `systemd-timesyncd` é um cliente SNTP simples e conflita com o daemon `ntp` completo (que usa a porta 123). No NixOS, habilitar ambos ao mesmo tempo pode causar comportamentos imprevisíveis.

**Correção:** Escolher apenas um. Se precisar de servidor NTP (para outras máquinas), use `services.ntp`. Se for apenas cliente, `services.timesyncd` é suficiente.

---

### 10. `nix-settings.nix` compartilha `permittedInsecurePackages` via HM desnecessariamente

**Arquivo:** `modules/aspects/nix-settings.nix`
O `home-manager.sharedModules` no módulo NixOS replica a lista de pacotes inseguros para o Home-Manager. Com `useGlobalPkgs = true`, isso não deveria ser necessário — e de fato está causando o warning de depreciação (item 3). Mesmo sem o warning, a lista duplicada é redundante.

---

### 11. Senha vazia no `hugo.nix` — `initialPassword`

Além de ser hardcoded (item 2), `initialPassword` é um `string` passado ao `users.users.hugomvs.initialPassword`. Esse valor fica armazenado no **mundo Nix** (armazenável como `/nix/store/*.drv`) e portanto visível a qualquer usuário do sistema via `nix-store -q`. Deveria ser movido para `hashedPassword` via sops.

---

### 12. Nomes dos atributos do flake inconsistentes — `coding-agents` vs `agents.nix`

**Arquivo:** `modules/aspects/agents.nix`
O arquivo chama-se `agents.nix` mas o módulo exportado é `coding-agents`:
```nix
flake.modules.nixos.coding-agents = ...
```
Isso cria confusão — o nome do arquivo não casa com a chave do módulo. Todos os outros aspectos usam o mesmo nome para arquivo e módulo (ex: `cli-tools.nix` → `cli-tools`, `searx.nix` → `searx`). `agents.nix` deveria ser renomeado para `coding-agents.nix`.

---

### 13. `dev-shell.nix` usa `inputs.home-manager.packages.${pkgs.stdenv.hostPlatform.system}.default`

**Arquivo:** `modules/dev-shell.nix:18`
```nix
inputs.home-manager.packages.${pkgs.stdenv.hostPlatform.system}.default
```
Esta é uma forma frágil de referenciar o home-manager. O `home-manager` expõe `packages` via `lib.makeScope` e acessar por string interpolada pode falhar se o nome do sistema divergir entre o `stdenv` nixpkgs e o do flake-parts. Prefira `inputs.home-manager.packages.${pkgs.system}.default`.

---

### 14. `shell.nix` referencia `pass` nos aliases — dependência implícita

**Arquivo:** `modules/aspects/shell.nix`
Os aliases `pr`, `aidme`, `commitme`, `crushme`, `codeme` executam `$(pass tokens/...)`. O pacote `pass` é instalado em `cli-tools.nix`, mas essa dependência é implícita. Se alguém usar `shell.nix` sem `cli-tools.nix`, os aliases quebram silenciosamente.

---

### 15. Hardcoded paths específicos de usuário em vários lugares sem `mkDefault`

- `modules/aspects/nix-config-sync-check.nix:4` — `repoPath = "/home/hugomvs/Projetos/nix-config"`
- `modules/aspects/tmux-sessionizer.nix:6` — `projDir = "/home/hugomvs/Projetos"`
- **Host configs** hardcodam `piDotfileRoot` com caminhos absolutos de `/home/hugomvs/...`

Se outra pessoa usar este repo, esses paths quebram. Deveriam usar `config.home.homeDirectory` (dentro do HM) ou `lib.mkDefault` com paths relativos ao home.

---

## 🟢 Inseguranças e Riscos

### 16. Pacotes inseguros explicitamente permitidos globalmente

**Arquivo:** `modules/aspects/nix-settings.nix`
```nix
"nodejs-20.20.2"       # Node.js 20 EOL desde out/2024
"nodejs-slim-20.20.2"  # Versão slim também EOL
"electron-39.8.10"     # Electron 39 — múltiplos CVEs conhecidos
```

Estes são permitidos **globalmente** em todos os hosts, incluindo o servidor que expõe serviços web. Idealmente, pacotes inseguros deveriam ser permitidos apenas nos hosts específicos que precisam deles, não globalmente via `nix-settings`.

---

### 17. `vaultwarden.nix` — comentário sobre SIGNUPS_ALLOWED confuso

**Arquivo:** `modules/aspects/vaultwarden.nix:27`
```nix
# Turn this off after creating your first user.
SIGNUPS_ALLOWED = false;
```
O comentário sugere uma ação futura, mas `SIGNUPS_ALLOWED` já está `false`. O comentário é enganoso e deveria ser removido ou atualizado.

---

## 📋 Resumo de Itens por Severidade

| # | Severidade | Item | Categoria |
|---|-----------|------|-----------|
| 1 | 🔴 Crítico | `projman2000.nix` colide com `cli-tools.nix` | Bug de namespace |
| 2 | 🔴 Crítico | Senha hardcoded em `hugo.nix` | Segurança |
| 3 | 🔴 Crítico | Warning depreciação HM + nixpkgs.config (todos hosts) | Compatibilidade futura |
| 4 | 🟡 Médio | `noctalia.nix` — dead code | Código não usado |
| 5 | 🟡 Médio | `utc-time.nix` — dead code | Código não usado |
| 6 | 🟡 Médio | `nix-config-sync-check` — import comentado | Código não usado |
| 7 | 🟡 Baixo | `plymouth` em systemPackages desnecessário | Código não usado |
| 8 | 🟠 Médio | `projman2000.nix` nome enganoso | Má prática |
| 9 | 🟠 Médio | `timesyncd` + `ntp` conflitantes | Má prática |
| 10 | 🟠 Médio | `permittedInsecurePackages` duplicado em HM | Má prática |
| 11 | 🟠 Médio | `initialPassword` vaza no /nix/store | Segurança |
| 12 | 🟡 Baixo | `agents.nix` vs `coding-agents` inconsistente | Nomenclatura |
| 13 | 🟡 Baixo | `dev-shell.nix` interpolação frágil | Manutenibilidade |
| 14 | 🟡 Baixo | Dependência implícita em `pass` nos aliases | Manutenibilidade |
| 15 | 🟡 Baixo | Hardcoded paths de usuário | Portabilidade |
| 16 | 🟢 Info | Pacotes inseguros globais | Segurança |
| 17 | 🟢 Info | Comentário enganoso `vaultwarden.nix` | Documentação |

---

## 🔧 Correções Prioritárias Recomendadas

1. **Imediato:** Renomear `projman2000.nix` → chave `projman2000` (não `cli-tools`)
2. **Imediato:** Remover `initialPassword = "123456789"` de `hugo.nix`, usar sops
3. **Imediato:** Mover `nixpkgs.config` para fora dos `home-manager.sharedModules` e resolver o warning de depreciação
4. **Curto prazo:** Remover ou ativar o `nix-config-sync-check` — não deixar comentado
5. **Curto prazo:** Escolher entre `timesyncd` ou `ntp` no `local-time.nix`
6. **Médio prazo:** Remover `noctalia.nix` e `utc-time.nix` se abandonados, ou documentar
7. **Médio prazo:** Renomear `agents.nix` → `coding-agents.nix` para consistência
8. **Médio prazo:** Substituir hardcoded paths por `config.home.homeDirectory` ou opções configuráveis

---

O repositório está funcional (`nix flake check` passa), mas acumula débito técnico significativo, especialmente os itens 1-3 que podem causar falhas silenciosas ou quebra de segurança.
