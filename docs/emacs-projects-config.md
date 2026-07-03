# Emacs Project Configuration Plan

## Goal

Load all projects in `~/Projetos` and also the `pk` project in `~/Documentos/org`.

## Option 1: Projectile (recommended)

```elisp
(use-package projectile
  :ensure t
  :init
  (projectile-mode +1)
  :bind-keymap ("C-c p" . projectile-command-map)
  :custom
  (projectile-project-search-path
   '(("~/Projetos")           ; scan all immediate subdirs
     ("~/Documentos/org" . 1) ; treat "org" itself as a project
     )))
```

- `("~/Projetos")` — searches **immediate subdirectories** (`~/Projetos/foo`, `~/Projetos/bar`).
- `("~/Documentos/org" . 1)` — the `1` (or `t`) means "treat this directory itself as a project".
- Ensure a marker exists in `~/Documentos/org`:
  ```sh
  touch ~/Documentos/org/.projectile
  ```
- Run `M-x projectile-discover-projects-in-search-path` (or it happens automatically on first use).

## Option 2: project.el (built-in)

No bulk-scan equivalent; use `project-known-projects` and `project-remember-projects-under`:

```elisp
(project-remember-projects-under "~/Projetos/" t)
(project-remember-projects-under "~/Documentos/org" t)
```

- The `t` makes it recursive.
- Each root must have a marker (`.git`, `.project`, etc.).

## Notes

- Projectile is richer; project.el is built-in and lighter.
- For the `pk` project to be recognized as such, give it a recognizable marker (`.projectile` for Projectile, `.git`/`.project` for project.el).
