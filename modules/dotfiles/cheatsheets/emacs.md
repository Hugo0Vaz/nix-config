# Emacs (org + evil + ivy/projectile)

## Refile
- `C-c C-w` — refile da entrada sob o ponto (alvos: arquivos do agenda, até nível 4)
- `C-u C-c C-w` — ir até o alvo (jump) em vez de mover
- `C-u C-u C-c C-w` — voltar ao último refile
- `C-c C-x C-w` — recortar subárvore (kill) e `C-c C-x C-y` para colar
- `C-c C-x M-w` — copiar subárvore; `C-c M-w` — copiar para um alvo de refile
- `r` — refile no org-agenda (sobre a tarefa)

## Arquivamento
- `C-c C-x C-a` — arquivar subárvore (move para o arquivo `_archive`)
- `C-c C-x a` — marcar/desmarcar tag ARCHIVE (esconde sem mover)
- `C-c C-x A` — arquivar para filho "Archive" da entrada pai
- `C-c C-x C-s` — equivalente a `C-c C-x C-a` (org-archive-subtree)
- `$` — arquivar a tarefa no org-agenda; `a` — idem, com confirmação

## Salvar
- `C-x C-s` — salvar buffer atual
- `C-x s` — salvar todos os buffers (pergunta um a um)
- `:wa` — salvar todos (evil, modo normal)
- `C-x C-s` no org-agenda — salvar todos os buffers org (`org-save-all-org-buffers`)
- `:w` / `:q` / `:wq` — salvar / fechar / ambos (evil)

## Org: tarefas e capture
- `C-c c` — org-capture (d* diário, `p` projeto, `t` tarefa global, `n` nota)
- `C-c a` — org-agenda (`u` sem agenda, `e` sem prazo, `p` projetos, `j` journal)
- `C-c C-t` — mudar estado TODO (t, f, v, D, d, e, m, c)
- `C-c C-s` — agendar (SCHEDULED)
- `C-c C-d` — definir prazo (DEADLINE)
- `C-c C-q` — definir tags
- `C-c C-o` — abrir link
- `C-c C-l` — inserir/editar link
- `C-c .` — inserir timestamp ativo
- `M-RET` — nova entrada no mesmo nível
- `M-S-RET` — nova entrada TODO
- `M-left/right` — promover/rebaixar título; `M-up/down` — mover subárvore
- `TAB` / `S-TAB` — alternar visibilidade (local / global)
- `C-c C-c` — confirmar capture (em capture: `C-c C-k` cancela; `C-c C-w` refile)

## Navegação e busca
- `C-s` — swiper (busca nas linhas do buffer)
- `C-x b` — trocar de buffer (ivy)
- `C-x C-f` — abrir arquivo
- `M-x` — comandos (counsel)
- `C-j` / `C-k` — próximo / anterior no minibuffer ivy
- `C-l` ou `TAB` — confirmar item no ivy (`ivy-alt-done`)
- `C-c p p` — trocar de projeto (projectile)
- `C-c p f` — achar arquivo no projeto
- `C-c p s s` — buscar texto no projeto (projectile-ag, requer `ag`)

## Git e IA
- `C-x g` — magit-status (`s` stage, `c c` commit, `P p` push, `q` fecha)
- `M-x gptel` — chat com LLM (OpenRouter)
- `M-x gptel-send` — enviar região/buffer ao modelo

## Evil (essenciais)
- `Esc` — modo normal; `i` — inserir
- `dd` / `yy` / `p` — apagar / copiar / colar linha
- `u` / `C-r` — desfazer / refazer
- `/texto` — buscar; `n` / `N` — próximo / anterior
- `gg` / `G` — início / fim do arquivo
- `:%s/a/b/g` — substituir no arquivo

## Misc
- `C-g` — cancelar qualquer comando
- `C-x C-c` — sair do Emacs
- `C-h k` — descrever tecla; `C-h f` função; `C-h v` variável
- `C-x 1` / `C-x 0` — manter só esta janela / fechar esta janela
- `C-x 2` / `C-x 3` — dividir horizontal / vertical
