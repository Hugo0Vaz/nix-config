---
name: ddd-code-review
description: Revisão de código orientada a Domain-Driven Design para projetos PHP/Laravel e TypeScript/Nuxt, usando o documento de arquitetura do próprio repositório (docs/ddd.md) como contrato a ser cobrado. Use sempre que o usuário pedir para revisar código, abrir/avaliar um PR, checar uma feature ou conferir se um trecho respeita a arquitetura DDD do projeto — mesmo que ele não diga "DDD" explicitamente, desde que o repositório tenha um docs/ddd.md ou descreva camadas/bounded contexts. Também use quando pedirem "revisão estilo PR", "code review", "isso está aderente à arquitetura?" ou "comentários por linha" em repos Laravel ou Nuxt.
---

# Revisão de código DDD (Laravel + Nuxt)

Esta skill faz revisão de código com foco em Domain-Driven Design. O diferencial dela — e a razão de existir — é que **ela não revisa contra um DDD genérico de livro. Ela revisa contra o contrato de arquitetura que o próprio repositório escreveu em `docs/ddd.md`.**

Isso importa porque revisões de DDD feitas "de memória" tendem a inventar regras que o time nunca adotou (e a gerar ruído), ou a deixar passar violações de convenções específicas do projeto. A precisão aqui vem de uma disciplina simples: **todo comentário se ancora em (a) uma linha de código real e (b) uma regra concreta — de preferência citada do `docs/ddd.md`.** Se não der para ancorar nos dois, não é uma violação; é, no máximo, uma observação.

## Visão geral do fluxo

1. Ler o contrato de arquitetura (`docs/ddd.md` e docs relacionados).
2. Definir o escopo da revisão (diff de PR, arquivos, ou pastas).
3. Mapear cada arquivo para sua camada / bounded context segundo o contrato.
4. Revisar cada arquivo carregando a referência da stack certa (`references/php-laravel.md` ou `references/typescript-nuxt.md`).
5. Classificar cada achado por severidade.
6. Emitir os comentários no formato PR.

Não pule o passo 1. Sem o contrato, a revisão perde o que a torna precisa.

## Passo 1 — Ler o contrato de arquitetura

Localize e leia, na raiz do repositório, **`docs/ddd.md`**. Procure também por documentos vizinhos que costumam complementar (ex.: `docs/architecture.md`, `docs/conventions.md`, `ADRs` em `docs/adr/`, um `README` de cada módulo/bounded context). Leia-os antes de olhar qualquer código.

Ao ler, extraia uma lista explícita das **regras cobráveis** do projeto, por exemplo:

- Quais são as camadas (Domain, Application, Infrastructure, UI/Presentation) e onde cada tipo de código deve morar.
- Direção de dependência permitida entre camadas (ex.: "Domain não conhece Infrastructure").
- Como agregados, entidades e value objects são modelados neste projeto especificamente.
- Regras de agregado: limites de transação, referência entre agregados por id vs. objeto, quem é a raiz.
- Onde validação, regras de negócio e efeitos colaterais devem ficar.
- Convenções de nomenclatura e de namespace/pasta.
- Linguagem ubíqua: termos que o código deve usar.

Anote de qual seção do `docs/ddd.md` cada regra vem — você vai citar isso nos comentários.

**Se `docs/ddd.md` não existir:** não invente o contrato. Diga ao usuário que não encontrou o documento, liste o que procurou, e ofereça duas saídas: (a) ele aponta onde está o documento de arquitetura, ou (b) você faz uma revisão DDD genérica deixando claro que ela é baseada em boas práticas gerais — e não no contrato do projeto. Não misture os dois sem avisar.

## Passo 2 — Definir o escopo

Descubra o que revisar, nesta ordem de preferência:

1. **Se o usuário indicou arquivos, pastas ou um PR/branch específico**, use isso.
2. **Se há um repositório git e um branch base** (ex.: `main`/`develop`), o cenário típico de "revisão de PR" é revisar o que mudou: `git diff --merge-base <base> -- <caminhos>` para listar arquivos e linhas alteradas. Revise principalmente as linhas adicionadas/alteradas, mas leia o arquivo inteiro em volta para ter contexto — uma linha pode estar correta isolada e errada no conjunto.
3. **Se nada disso estiver claro**, pergunte ao usuário o que ele quer revisar (o diff atual? uma pasta? um PR?) antes de gastar tempo.

Para comentários estilo PR, os números de linha precisam bater com o arquivo real (na versão nova, em caso de diff). Confira os números relendo o arquivo; não estime.

## Passo 3 — Mapear arquivos para camadas / contextos

Para cada arquivo no escopo, determine a qual camada e bounded context ele pertence **segundo o contrato** (não segundo o palpite pela pasta). Em projetos Laravel/Nuxt reais, a estrutura de pastas nem sempre reflete a camada conceitual — por isso vale conferir o que o arquivo faz, não só onde ele está. Esse mapeamento é o que permite checar a regra mais importante de DDD: a direção das dependências.

## Passo 4 — Revisar cada arquivo

Carregue a referência da stack correspondente e use-a como checklist de "sinais a investigar":

- **PHP/Laravel:** leia `references/php-laravel.md`.
- **TypeScript/Nuxt:** leia `references/typescript-nuxt.md`.

Trate cada item da referência como uma pergunta a fazer ao código, não como veredito automático. O objetivo é encontrar onde o código se afasta do contrato do projeto. Para cada candidato a achado:

- Releia o trecho e confirme que ele realmente faz o que você vai apontar. Nunca acuse com base no nome do arquivo ou em suposição.
- Identifique a regra violada e de onde ela vem (`docs/ddd.md §X`, ou um princípio de DDD da referência da stack).
- Se você não tem certeza se é violação, escreva como **pergunta** ("Isso roda dentro de uma transação que também altera outro agregado?"), não como afirmação.

## Severidade

Classifique cada comentário em um de três níveis. Use o mais baixo que for honesto — inflar severidade destrói a confiança na revisão.

- 🔴 **Bloqueante** — viola uma regra explícita do `docs/ddd.md` ou um invariante de domínio; quebra a direção de dependência entre camadas; introduz bug de regra de negócio. Não deveria entrar como está.
- 🟡 **Atenção** — desvio de convenção do projeto, modelo anêmico, primitive obsession, lógica na camada errada que ainda não é claramente proibida pelo doc. Vale corrigir, mas é discutível.
- 🔵 **Sugestão** — melhoria de clareza, nomenclatura, alinhamento com a linguagem ubíqua. Opcional.

Se um achado **não** se ancora em nenhuma regra do contrato nem em um princípio claro, ou ele é um bug objetivo (e aí descreva o bug), ou você não deveria emiti-lo como violação. Boas revisões dizem menos e com mais peso.

## Formato de saída — comentários estilo PR

Comece com um resumo curto e depois os comentários **agrupados por arquivo**, em ordem de severidade dentro de cada arquivo. Use exatamente esta estrutura:

```
## 📋 Resumo da revisão
- Arquivos analisados: <n>
- 🔴 Bloqueantes: <x> · 🟡 Atenção: <y> · 🔵 Sugestões: <z>
- Contrato usado: docs/ddd.md (seções citadas: <lista>)
- Escopo: <diff de PR / pastas / arquivos>

---

### `caminho/do/arquivo.php` — linha <i>–<j>
**🔴 Bloqueante · Regra: "<texto curto da regra>" (docs/ddd.md §<x>)**

```<linguagem>
<trecho relevante do código, curto>
```

**Problema:** <o que está errado e por quê, ligando à regra>
**Sugestão:** <como corrigir; código quando ajudar>
```

Regras do formato:

- Um comentário por problema distinto. Se o mesmo desvio se repete em vários lugares, comente uma vez bem e liste as demais ocorrências (`também em: arquivo:linha`) em vez de repetir.
- O trecho de código citado deve ser curto (as linhas que importam), não o arquivo inteiro.
- Sempre que possível, cite a seção do `docs/ddd.md`. Quando o achado vier de um princípio geral de DDD (não do doc), diga isso claramente — assim o usuário sabe distinguir "o projeto proíbe" de "boa prática sugere".
- Se não houver nenhuma violação, diga isso de forma direta no resumo. Uma revisão limpa é um resultado válido e bom; não fabrique achados para parecer útil.

## Por que a precisão importa aqui

Uma revisão com 30 comentários dos quais 10 são imprecisos é pior que uma com 6 comentários todos corretos: a primeira faz o time desconfiar de tudo e ignorar até os achados certos. Por isso esta skill prefere errar para o lado de **menos comentários, todos verificáveis** — cada um com linha real, regra nomeada e, idealmente, a seção do contrato. Quando estiver em dúvida entre apontar e calar, aponte como pergunta de severidade baixa, não como bloqueante.
