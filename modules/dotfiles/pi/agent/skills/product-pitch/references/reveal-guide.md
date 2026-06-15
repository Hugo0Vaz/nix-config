# Guia técnico — reveal.js + design

## Estrutura

Um único arquivo HTML autocontido, reveal.js via CDN (sem build, abre direto no navegador e versiona bem no repo). Use `assets/template.html` como base.

Cada slide é uma `<section>` dentro de `.slides`. Slides verticais (sub-tópicos) são `<section>` aninhados.

```html
<div class="reveal">
  <div class="slides">
    <section class="capa"> ... </section>
    <section> ... </section>
  </div>
</div>
```

## Design tokens

Defina tudo em CSS custom properties no topo, para ser fácil ajustar e aplicar a marca. Valores default (tema escuro, confiante, bom para investidor):

```css
:root {
  --pitch-bg: #0b0e14;
  --pitch-fg: #f5f7fa;
  --pitch-muted: #9aa4b2;
  --pitch-accent: #4f7cff;      /* trocar pela cor da marca se achada no repo */
  --pitch-font: 'Inter', system-ui, sans-serif;
  --pitch-heading-weight: 700;
}
```

Aplicar a marca do repo: se encontrou cor primária (tailwind config, variáveis CSS, `:root` da landing) → `--pitch-accent`. Se encontrou logo → colocar na capa e, discretamente, no rodapé dos slides.

## Tipografia e layout

- Escala generosa: headline ~2.2em, corpo ~1em. Investidor lê de longe numa sala.
- Máx ~6 linhas de texto por slide. Se passar disso, quebre em dois slides.
- Headlines à esquerda ou centralizadas, consistente no deck inteiro.
- Use `<aside class="notes">` para o roteiro de fala do fundador (não aparece no slide; aparece no modo speaker, tecla `s`).

## Placeholders

Dados faltando = classe visível, nunca número fabricado:

```css
.placeholder {
  background: rgba(255, 196, 0, .15);
  border: 1px dashed var(--pitch-accent);
  padding: .1em .4em; border-radius: 4px;
}
```

```html
<span class="placeholder">[[TAM a confirmar]]</span>
```

## Gráficos de tração

Se houver dados reais, um gráfico simples vale mais que texto. Opções: SVG inline (sem dependência) ou Chart.js via CDN. Só desenhe a curva se os números forem reais — caso contrário, slide com placeholder pedindo os dados.

## Inicialização

```html
<script src="https://cdn.jsdelivr.net/npm/reveal.js@5/dist/reveal.js"></script>
<script>
  Reveal.initialize({
    hash: true,
    slideNumber: 'c/t',
    transition: 'fade',
    width: 1280, height: 720
  });
</script>
```

Atalhos úteis para mencionar ao usuário: `f` tela cheia, `s` modo speaker (com notas e timer), `o` visão geral, `esc` sair.
