# Narrativa do pitch de captação (slide a slide)

Estrutura enxuta baseada no cânone de decks de investidor (Sequoia / Y Combinator / Guy Kawasaki 10/20/30). São ~11 slides. Não force todos se não fizer sentido para o estágio, mas a espinha dorsal (problema → solução → mercado → tração → ask) é inegociável.

Para cada slide: **uma ideia, headline afirmativa, pouco texto.** O slide é o apoio visual; a fala do fundador carrega o detalhe.

## 1. Capa
- Nome do produto/empresa + logo.
- **Uma frase** que diz o que a empresa faz ("Stripe para X", "o jeito mais rápido de Y"). Sem jargão.
- *Fonte no repo*: nome (package.json/README), tagline (topo do README, landing).

## 2. Problema
- A dor, concreta e específica. De quem é a dor e quanto custa hoje.
- Idealmente 1 estatística que dimensione a dor.
- *Fonte no repo*: seção "Why"/"Motivation"/"Problem" do README; issues recorrentes.

## 3. Solução
- Como o produto resolve a dor. O "aha".
- O que muda na vida do usuário — não a lista de features.
- *Fonte no repo*: descrição principal do README, "Features", landing copy.

## 4. Produto (como funciona)
- 2-4 passos ou um fluxo simples mostrando o produto em ação.
- Screenshot/diagrama se houver. Evite parede de texto técnico.
- *Fonte no repo*: docs de uso, "Getting Started", arquitetura, imagens em `docs/`/`assets/`.

## 5. Mercado (TAM / SAM / SOM)
- Tamanho do mercado e por que é grande o bastante para um retorno de fundo.
- TAM (total) → SAM (endereçável) → SOM (alcançável). Com fonte.
- **Quase nunca está no repo.** Pedir ao usuário. Placeholder `[[TAM: a confirmar — fonte?]]` se faltar.

## 6. Modelo de negócio
- Como ganha dinheiro: preço, unidade de cobrança, margens se souber.
- *Fonte no repo*: às vezes em `pricing`/landing. Geralmente perguntar.

## 7. Tração
- A prova de que está funcionando: usuários, receita, crescimento %, retenção, contratos, waitlist.
- Gráfico "para cima e à direita" se houver dados reais.
- Se for pré-tração, dizer com honestidade e mostrar sinais de validação (pilotos, cartas de intenção, ritmo de release).
- *Fonte no repo*: CHANGELOG/tags dão ritmo de execução, mas **números de negócio precisam vir do usuário.** Nunca inventar.

## 8. Concorrência / diferencial
- Quem mais resolve isso e por que vocês ganham. Matriz 2x2 ou tabela é eficaz.
- Diferencial defensável (tecnologia, dado, rede, velocidade).
- *Fonte no repo*: diferencial técnico dá pra inferir da stack/arquitetura; lista de concorrentes geralmente perguntar.

## 9. Time
- Fundadores, o que fazem, por que são as pessoas certas para este problema ("founder-market fit").
- *Fonte no repo*: `CONTRIBUTORS`/`AUTHORS`/commits dão nomes, mas bios e narrativa precisam vir do usuário.

## 10. Roadmap / visão
- Para onde vai nos próximos 12-18 meses. Marcos, não wishlist.
- *Fonte no repo*: `ROADMAP.md`, milestones, issues marcadas.

## 11. O Ask
- Quanto está captando, em que vai usar (categorias: ex. 50% produto, 30% GTM, 20% time), e que marco isso destrava.
- **O slide mais importante de um pitch de captação.** Se o usuário não deu, é a primeira coisa a perguntar.
- Nunca está no repo. Sempre do usuário.

## Adaptação por estágio
- **Pré-seed/seed**: peso em problema, solução, time, visão. Tração pode ser sinais qualitativos.
- **Série A+**: peso em tração e métricas. Mercado e modelo precisam estar sólidos.

Se o repo indicar estágio early (poucos releases, sem pricing, projeto recente), incline a narrativa para problema/solução/visão e seja explícito que tração é early.
