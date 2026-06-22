---
name: product-pitch
description: Gera um pitch deck de captação (apresentação para investidores) a partir do repositório do próprio produto. A skill inventaria o repo (README, docs, CHANGELOG, package.json etc.), extrai o que conseguir sobre o produto e monta uma apresentação em slides HTML (reveal.js) seguindo a narrativa clássica de pitch para investidor. Use sempre que o usuário pedir um "pitch", "pitch deck", "deck de investidor", "apresentação para captação", "slides do produto para investidores" ou similar dentro de um repositório de produto — mesmo que ele não diga explicitamente "reveal.js" ou "HTML". Também use quando o pedido for atualizar/regenerar um deck existente a partir de mudanças no repo.
---

# Product Pitch

Cria um **pitch deck de captação** (foco em investidores) como uma apresentação **reveal.js** autocontida, usando o conteúdo do repositório como fonte de verdade.

A ideia central: o repositório já contém boa parte do material (o que o produto faz, como funciona, estágio técnico). Um deck de investidor precisa disso **e** de coisas que não vivem no código (tamanho de mercado, tração/números, time, modelo de negócio, o pedido de investimento). O trabalho da skill é extrair o primeiro grupo automaticamente e **pedir explicitamente** o segundo, em vez de inventar.

## Princípio que não pode ser quebrado

Nunca inventar números, tração, projeções ou tamanho de mercado. Investidor confia no deck. Se um dado não está no repo nem foi fornecido pelo usuário, deixe um *placeholder* visível (ex.: `[[TAM a confirmar]]`) e liste no final o que precisa ser preenchido. Um deck honesto com lacunas marcadas é muito melhor que um deck "completo" com dados fabricados.

## Fluxo

### 1. Inventariar o repositório

Antes de qualquer coisa, mapeie o que existe. Procure (na raiz e em subpastas comuns):

- `README*` — geralmente a melhor fonte para problema, solução, o que o produto faz
- `docs/`, `documentation/`, `*.md` na raiz — visão, arquitetura, casos de uso
- `package.json`, `pyproject.toml`, `Cargo.toml`, `go.mod` — nome, descrição, stack, dependências (sinaliza maturidade técnica)
- `CHANGELOG*`, releases/tags — ritmo de evolução (proxy de tração/execução)
- `LICENSE`, `CONTRIBUTING*` — abertura/comunidade
- `landing/`, `website/`, `marketing/` — copy já pronta, posicionamento, branding
- Arquivos de marca: logo (`logo.*`, `assets/`, `public/`), cores em CSS/tailwind config, `favicon`

Use `find`/`ls` para listar e leia os arquivos relevantes. Não leia o código-fonte inteiro — foque em docs, descrições e metadados. O objetivo é entender **o que é o produto e em que estágio está**, não auditar a implementação.

### 2. Extrair e mapear para os slots do pitch

Para cada slide da narrativa (ver `references/pitch-structure.md`), classifique cada slot em um de três estados:

- **Extraído** — está claramente no repo. Use, e cite mentalmente de onde veio.
- **Inferido** — dá pra deduzir com confiança razoável (ex.: a stack indica que o produto é técnico/early-stage). Use, mas com moderação e sem afirmar números.
- **Faltando** — não está no repo e não é inferível com segurança. Vira placeholder + entra na lista de lacunas.

Tipicamente **extraível** de um repo: problema, solução, como o produto funciona, diferencial técnico, estágio do produto, stack.

Tipicamente **faltando** (precisa perguntar ao usuário): tamanho de mercado (TAM/SAM/SOM), tração e métricas (usuários, receita, crescimento), modelo de negócio/precificação, time e bios, concorrência detalhada, e **o ask** (quanto está captando e em quê vai usar).

### 3. Confirmar o essencial com o usuário

Não despeje 15 perguntas. Apresente um resumo do que extraiu ("entendi que o produto é X, resolve Y, está no estágio Z") para o usuário validar, e peça **apenas o essencial para um pitch de investidor** que não estava no repo. No mínimo confirme:

- **O ask**: valor da rodada e uso dos recursos (sem isso não é pitch de captação)
- **Tração**: qualquer métrica real que exista (ou explicitar que é pré-tração)
- **Mercado**: existe um número de TAM ou uma fonte?
- **Time**: quem são os fundadores e por que são as pessoas certas

Se o usuário não tiver algum desses, tudo bem — marque como placeholder e siga. Não trave o fluxo.

### 4. Montar o deck

Leia `references/pitch-structure.md` para a narrativa slide-a-slide e `references/reveal-guide.md` para a parte técnica (estrutura do HTML, design tokens, como aplicar a marca do produto).

Construa um único arquivo HTML autocontido (reveal.js via CDN) a partir do template em `assets/template.html`. Regras de qualidade:

- **Idioma**: gere o deck no idioma predominante do repo (default português se o README estiver em português), salvo pedido em contrário.
- **Concisão**: regra de ouro do pitch — pouco texto por slide, uma ideia por slide. Headlines afirmativas ("Reduzimos X em 80%"), não rótulos ("Solução").
- **Marca**: se achou logo e cores no repo, aplique nos design tokens. Senão, use o tema default e marque a cor de acento como placeholder.
- **Placeholders visíveis**: dados faltando aparecem como `[[texto a confirmar]]` em destaque, nunca como número inventado.

### 5. Entregar

Salve o deck em local sensato no repo (ex.: `pitch/index.html` ou `pitch/deck.html`) e, se a ferramenta `present_files` estiver disponível, apresente o arquivo. Feche com uma **lista curta das lacunas** que ficaram como placeholder, para o usuário saber exatamente o que preencher antes de mandar para um investidor.

## Atualizar um deck existente

Se já existe um deck no repo e o pedido é regenerar/atualizar: leia o deck atual para preservar dados que o usuário preencheu manualmente (o ask, números de tração, bios), re-inventarie o repo para o que mudou, e reconstrua mantendo esses dados. Não sobrescreva tração real com placeholder.
