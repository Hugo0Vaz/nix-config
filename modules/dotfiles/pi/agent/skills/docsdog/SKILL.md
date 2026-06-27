---
name: docsdog-ucs-uss
description: Analisa um sistema existente e gera a especificação de casos de uso (UCS) e especificação de histórias de usuário (USS) seguindo o framework DocsDog — incluindo documentos de índice e individuais com os templates Cockburn e de user story. Use quando o usuário pedir para gerar/extrair casos de uso, histórias de usuário, UCS, USS, ou documentação funcional a partir de um codebase existente, especialmente se o repositório já usa ou referencia o DocsDog.
---

# DocsDog — Gerar UCS e USS a partir de sistema existente

Esta skill analisa um sistema existente e gera dois artefatos DocsDog completos:

- **UCS** (Use Case Specification) — catálogo de casos de uso com documentos individuais por caso de uso.
- **USS** (User Story Specification) — catálogo de user stories com documentos individuais por história.

A skill segue estritamente os templates e convenções do DocsDog: Cockburn para casos de uso, formato "As a... I want... so that..." para user stories, e identificadores no padrão `docsdog:<kind>:<id>`.

## Visão geral do fluxo

1. **Discovery** — varrer o codebase para extrair atores, funcionalidades, regras de negócio e integrações.
2. **Gerar documentos de índice** — `ucs.md` e `uss.md`.
3. **Gerar documentos individuais** — `UC-NNN.md` por caso de uso, `US-NNN.md` por user story.
4. **Cross-reference** — amarrar IDs entre índices e documentos, garantir que todo ator e user class aparece em pelo menos um documento.

O resultado é um diretório `docs/` pronto para ser versionado e mantido com o código.

---

## Passo 1 — Discovery (análise do sistema)

Explore o codebase e produza notas de trabalho com estas 4 categorias. Não pule nenhuma — cada categoria alimenta seções específicas dos templates.

### 1.1 Atores / User Classes

Identifique todo papel, persona, sistema externo, scheduler ou dispositivo que interage com o sistema. Para cada um, anote:

- **Nome** — papel, não pessoa ou instância (ex.: "Customer", não "John"; "Payment Gateway", não "Stripe").
- **Tipo** — Primary (inicia interação para atingir um objetivo) ou Secondary (participa mas não inicia).
- **Objetivos / Responsabilidades** — o que esse ator quer ou faz.
- **Frequência** — once, daily, weekly, monthly, on-demand, continuous.

Onde procurar:
- Rotas (web.php, api.php, router.ts), controllers, comandos CLI (artisan, console).
- Middleware de autenticação/autorização (guards, policies, roles).
- Event listeners, job handlers, scheduled tasks.
- README, docs, ou qualquer documentação existente.

### 1.2 Funcionalidades / Áreas funcionais

Agrupe as funcionalidades do sistema em domínios coerentes (ex.: auth, orders, billing, admin, notifications). Para cada grupo:

- Liste as operações principais que o sistema oferece.
- Identifique o fluxo principal (happy path) de cada operação.
- Anote variações, alternativas e edge cases visíveis no código.

Onde procurar:
- Services, use cases, actions, controllers, handlers.
- Commands e queries (CQRS).
- Form requests, validators — revelam precondições e regras de negócio.
- State machines, enums de status — revelam ciclos de vida.

### 1.3 Regras de negócio

Extraia constraints, validações, ciclos de vida de status e invariantes do código:

- Validações em form requests, value objects, regras customizadas.
- Condições de guarda em serviços e policies.
- Estados e transições (enums com allowed transitions).
- Limites e thresholds (ex.: "pedidos acima de R$ 10.000 requerem revisão manual").

### 1.4 Integrações externas

Liste sistemas externos com os quais o código interage:

- Payment gateways, email services, SMS, filas (queues), message brokers.
- APIs de terceiros, webhooks recebidos e enviados.
- Armazenamento (buckets, CDNs, bancos externos).

Cada um será um secondary actor no UCS.

---

## Passo 2 — Gerar documentos de índice

A saída vai em `docs/`. Crie primeiro os dois índices.

### 2.1 `docs/ucs.md` — Use Case Specification

Estrutura exata:

```markdown
# Use Case Specification
## For {project name}

Version 0.1
Prepared by {author}
{organization}
{date_modified}

## Table of Contents
- 1. Introduction
  - 1.1 Document Purpose
  - 1.2 Product Scope
  - 1.3 Definitions, Acronyms, and Abbreviations
  - 1.4 References
  - 1.5 Document Overview
- 2. System Context
  - 2.1 System Boundary
  - 2.2 Actor Catalog
  - 2.3 Use Case Diagram
- 3. Use Case Inventory
  - 3.1 Status Lifecycle
  - 3.2 Level Convention
- 4. Use Case Templates
- 5. Appendixes

## Revision History
| Name | Date | Reason For Changes | Version |
|------|------|--------------------|---------|
|      |      |                    |         |

## 1. Introduction
### 1.1 Document Purpose
{2–4 frases: por que este UCS existe, o que contém, quem deve usá-lo}

### 1.2 Product Scope
{3–5 frases: nome do produto, boundary, áreas cobertas e adiadas}

### 1.3 Definitions, Acronyms, and Abbreviations
| Term          | Definition |
|---------------|------------|
| Actor         | A role played by a person, system, or device that interacts with the system to achieve a goal |
| Extension     | An alternate flow branching from a step in the main success scenario (Cockburn) |
| Precondition  | A condition that must be true before the use case can begin |
| Primary Actor | The actor that initiates the use case to achieve a goal |
| Scope         | The boundary of the system under design — the "black box" the use case describes (Cockburn) |
| UCS           | Use Case Specification — This document |
{adicione termos específicos do domínio conforme necessário}

### 1.4 References
{Liste SRS, ADR Log, UX specs, etc. com título, autor, versão, data, URL}

### 1.5 Document Overview
{3–5 frases sobre navegação e convenções do documento}

## 2. System Context
### 2.1 System Boundary
{2–4 frases descrevendo o que está dentro vs. fora do sistema}

### 2.2 Actor Catalog
| Actor            | Type     | Description / Responsibilities | Participates In (UC IDs) |
|------------------|----------|--------------------------------|--------------------------|
{preencha com cada ator identificado no Passo 1.1}

### 2.3 Use Case Diagram
{Diagrama Mermaid ou PlantUML com atores, use cases e relações include/extend}
```

Use este template Mermaid como ponto de partida:

```mermaid
flowchart LR
    subgraph System [{system name}]
        UC001[UC-001: {name}]
        UC002[UC-002: {name}]
    end
    Customer((Customer)) --> UC001
    Admin((Admin)) --> UC002
```

```markdown
## 3. Use Case Inventory
| ID     | Use Case Name | Primary Actor | Level   | Priority | Status | SRS Reference |
|--------|---------------|---------------|---------|----------|--------|---------------|
| UC-001 |               |               |         |          |        |               |
{preencha com cada caso de uso que será detalhado; atualize após gerar os individuais}

### 3.1 Status Lifecycle
draft → reviewed → approved → implemented → verified
(deferred e waived são estados terminais alternativos)

### 3.2 Level Convention
| Level       | Purpose                                      | Example                                      |
|-------------|----------------------------------------------|----------------------------------------------|
| Summary     | High-level business process, multiple goals  | "Process Order from Placement to Fulfillment" |
| User-goal   | Primary unit of work, single sitting         | "Place an Order"                              |
| Subfunction | Reusable sub-step called by other use cases  | "Validate Payment Method"                     |

## 4. Use Case Templates
| Template | Style | Description |
|----------|-------|-------------|
| `uc-template.md` | Cockburn (full) | Comprehensive — for complex, multi-stakeholder use cases |
| `uc-template-minimal.md` | UML Simplified | Streamlined — for standard or well-understood use cases |

## 5. Appendixes
{Referências a personas, jornadas de usuário, diagramas de processo}
```

### 2.2 `docs/uss.md` — User Story Specification

Estrutura exata:

```markdown
# User Story Specification
## For {project name}

Version 0.1
Prepared by {author}
{organization}
{date_modified}

## Table of Contents
- 1. Introduction
  - 1.1 Document Purpose
  - 1.2 Product Scope
  - 1.3 Definitions, Acronyms, and Abbreviations
  - 1.4 References
  - 1.5 Document Overview
- 2. Product Overview
  - 2.1 Product Perspective
  - 2.2 User Classes
- 3. Story Inventory
  - 3.1 Status Lifecycle
  - 3.2 Priority Convention
  - 3.3 Effort Convention
- 4. Story Template
- 5. Appendixes

## Revision History
| Name | Date | Reason For Changes | Version |
|------|------|--------------------|---------|
|      |      |                    |         |

## 1. Introduction
### 1.1 Document Purpose
{2–4 frases: por que esta USS existe, o que contém, quem deve usá-la}

### 1.2 Product Scope
{3–5 frases: nome do produto, boundary, features cobertas e excluídas}

### 1.3 Definitions, Acronyms, and Abbreviations
| Term | Definition |
|------|------------|
| SRS  | Software Requirements Specification |
| UCS  | Use Case Specification |
| US   | User Story — A short description of a feature from the user's perspective |
| USS  | User Story Specification — This document |
{adicione termos específicos do domínio}

### 1.4 References
{Liste SRS, UCS, ADR Log, UX designs com título, autor, versão, data, URL}

### 1.5 Document Overview
{3–5 frases sobre navegação e convenções do documento}

## 2. Product Overview
### 2.1 Product Perspective
{Contexto: sistema novo, substituto, parte de uma família? Relações com outros sistemas.}

### 2.2 User Classes
| User Class | Description / Goals | Frequency |
|------------|---------------------|-----------|
{preencha com cada user class identificada no Passo 1.1}

## 3. Story Inventory
| ID     | Title | User Class | Priority | Effort | Status | SRS Reference |
|--------|-------|------------|----------|--------|--------|---------------|
| US-001 |       |            |          |        |        |               |
{preencha com cada história; atualize após gerar os individuais}

### 3.1 Status Lifecycle
draft → ready → in-progress → done
(deferred e waived são estados terminais alternativos)

### 3.2 Priority Convention
| Priority | Description |
|----------|-------------|
| critical | Must be delivered; blocking progress on core functionality |
| high     | Important; should be delivered soon |
| medium   | Valuable; deliver when capacity permits |
| low      | Nice to have; deliver if and when possible |

### 3.3 Effort Convention
| Effort | Description |
|--------|-------------|
| XS     | Trivial — a few hours |
| S      | Small — a day or two |
| M      | Medium — a few days |
| L      | Large — a week or more |
| XL     | Extra large — must be split into smaller stories |

## 4. Story Template
| Template | Description |
|----------|-------------|
| `us-template.md` | Full — with guidance comments |
| `us-template-bare.md` | Bare — placeholders only |

## 5. Appendixes
{Personas, journey maps, design references}
```

---

## Passo 3 — Gerar documentos individuais

### 3.1 Casos de Uso (`docs/uc/UC-NNN.md`)

Use o **template Cockburn completo**. A numeração é zero-padded 3 dígitos (`UC-001`, `UC-002`, ...). Atribua IDs na ordem de importância (prioridade), não na ordem de descoberta.

Estrutura de cada `UC-NNN.md`:

```markdown
---
status: "{draft | reviewed | approved | implemented | verified | deferred | waived}"
date: {YYYY-MM-DD}
priority: "{critical | high | medium | low}"
frequency: "{once | daily | weekly | monthly | on-demand | continuous}"
source: {SRS requirement ID ou user story reference}
---

# {verb-phrase use case name}

| Use Case ID | UC-NNN |
|-------------|--------|

## Scope
{system boundary — deve bater com a Section 2.1 do ucs.md}

## Level
{Summary | User-goal | Subfunction}

## Primary Actor
{role, not person}

## Secondary Actors
{external systems, services, or supporting roles}

## Stakeholders & Interests
| Stakeholder       | Interest / Concern |
|-------------------|---------------------|
| {actor}           | {what they care about — be specific} |
| Marketing         | {ex.: conversion analytics} |
| Privacy Officer   | {ex.: PII minimized} |
| CFO               | {ex.: no double charges} |

Regra: vá além dos atores óbvios. Surface concerns de compliance, auditoria, analytics, financeiro.

## Preconditions
{system-enforced guarantees. Formato: "The system guarantees that..."}

## Minimal Guarantees
{what the system promises even on failure. Se nenhuma, escreva "None" explicitamente.}

## Success Guarantees
{postconditions after success. Seja específico: estado do sistema, dados, situação do ator.}

## Trigger
{the event that starts the use case. Ex.: "Customer taps 'Place Order'."}

## Main Success Scenario
1. {Actor} {action}. The System {response}.
2. {Actor} {action}. The System {response}.
{3–9 passos. Cada passo é uma interação ator↔sistema.}

## Extensions
{extensões hierárquicas por passo:
- **3a. {extension name}:**
    1. System {response}.
    2. Actor {action}.
    3. Return to step N.
- **3b. {extension name}:**
    ...}

Regras das extensões:
- Numeração hierárquica a partir do passo do main success scenario (3a, 3a1, 3b).
- Toda extensão termina com return, goto outro passo, ou fim do use case.
- Inclua timeouts, cancelamentos, falhas de validação, race conditions.
- Para extensões complexas que merecem sub-use case, referencie: "→ See UC-004".

## Related Information
| Category       | Detail |
|----------------|--------|
| Performance    | {targets, p95, latencies} |
| Business Rule  | {regras de negócio relevantes} |
| UI Reference   | {wireframes, mockups} |
| Open Question  | {decisões pendentes} |
| Related UCs    | {UC IDs relacionados} |

## More Information
{links, design notes, assumptions, traceability references}
```

### 3.2 User Stories (`docs/us/US-NNN.md`)

Numeração zero-padded 3 dígitos (`US-001`, `US-002`, ...).

Estrutura de cada `US-NNN.md`:

```markdown
---
status: "{draft | ready | in-progress | done | deferred | waived}"
date: {YYYY-MM-DD}
priority: "{critical | high | medium | low}"
effort: "{XS | S | M | L | XL}"
source: {SRS requirement ID ou epic reference}
---

# {short title}

## User Story
> As a **{role}**, I want **{feature/capability}** so that **{benefit/reason}**.

## Acceptance Criteria
* Given {precondition}, When {action}, Then {expected outcome}.
* Given {precondition}, When {action}, Then {expected outcome}.
{cada critério deve ser independentemente verificável com yes/no}

## Notes
{implementation hints, constraints, dependencies, risks, or open questions}

## More Information
{links, references, traceability}
```

Regras para user stories:
- A role deve ser concreta — uma user class do USS Section 2.2, não um cargo.
- O benefit deve ser o porquê real, não uma reformulação da feature.
- Se não consegue articular o benefit, a história pode não estar pronta — marque como `draft`.

---

## Passo 4 — Cross-reference e traceability

Após gerar todos os documentos:

1. **Atualize a tabela de inventário do UCS** (`docs/ucs.md` Section 3) com todos os UC-IDs gerados, preenchendo nome, ator primário, nível, prioridade e status.
2. **Atualize a tabela de inventário do USS** (`docs/uss.md` Section 3) com todos os US-IDs gerados.
3. **Garanta cobertura de atores**: todo ator no Actor Catalog (UCS Section 2.2) deve aparecer em pelo menos um caso de uso. Se houver ator órfão, crie um UC adicional ou justifique no UCS.
4. **Garanta cobertura de user classes**: toda user class no USS Section 2.2 deve aparecer no `As a **{role}**` de pelo menos uma user story.
5. **Cross-reference UC ↔ US**: na coluna `SRS Reference` do inventário UCS, referencie as user stories quando aplicável. Na seção "Related UCs" de cada UC, mencione US IDs relevantes. Em "More Information" de cada US, mencione UC IDs relacionados.

---

## Estrutura de saída

```
docs/
├── ucs.md          # Use Case Specification (índice)
├── uss.md          # User Story Specification (índice)
├── uc/
│   ├── UC-001.md
│   ├── UC-002.md
│   └── ...
└── us/
    ├── US-001.md
    ├── US-002.md
    └── ...
```

---

## Regras de qualidade

Estas regras são cobráveis — se um documento gerado não as satisfaz, ele não está pronto.

### Regras gerais
- IDs seguem `docsdog:<kind>:<id>` (ex.: `docsdog:usecase:UC-001`, `docsdog:userstory:US-032`). Arquivos são nomeados `<PREFIX>-NNN.md` com zero-padding de 3 dígitos.
- Status só pode usar valores do conjunto definido no front matter de cada template.
- Prioridades seguem a convenção do USS Section 3.2 (critical/high/medium/low).

### Regras de caso de uso (Cockburn)
- Todo UC tem: primary actor, trigger, e main success scenario com passos numerados.
- Extensões usam numeração hierárquica Cockburn (3a, 3a1, 3b), não listas planas de alternate/exception flows.
- Minimal guarantees são obrigatórios — escreva "None" se não houver, mas não omita a seção.
- Stakeholders & Interests devem incluir stakeholders não-óbvios (compliance, auditoria, analytics, financeiro).
- Main success scenario: 3–9 passos. Se ultrapassar, divida em summary + subfunction use cases.
- Scope deve bater com o System Boundary do UCS Section 2.1.

### Regras de user story
- Toda US segue o formato `As a **{role}**, I want **{feature}** so that **{benefit}**.`
- Acceptance criteria usam o formato `Given ... When ... Then ...` e são independentemente verificáveis.
- A role no "As a..." deve corresponder a uma user class listada no USS Section 2.2.

### Regra de decisão de template
Default: Cockburn completo para casos de uso. Só use UML Simplified (minimal) para CRUD trivial, operações internas sem múltiplos stakeholders, ou quando o usuário explicitamente pedir minimal. O ato de preencher Stakeholders & Interests frequentemente revela requisitos ocultos — por isso o default é Cockburn.

---

## Identificadores DocsDog

Ao referenciar artefatos, use a sintaxe de DocsDog Identifier:

```
<namespace>:<kind>:<identifier>
```

Exemplos:

| Artefato | Identifier |
|----------|------------|
| Caso de uso | `docsdog:usecase:UC-001` |
| User story | `docsdog:userstory:US-032` |
| Requisito | `docsdog:requirement:REQ-014` |
| Regra de negócio | `docsdog:rule:BR-008` |
| ADR | `docsdog:adr:ADR-004` |
| Evento | `docsdog:event:InvoiceCreated` |
| Comando | `docsdog:command:CreateInvoice` |
| API endpoint | `docsdog:api:POST:/invoices` |

Predicates padrão para traceability nos documentos:
- `implements` — UC implementa um requisito
- `traces-to` — US traça para um UC ou requisito
- `requires` — UC requer outro UC como precondição
- `validates` — UC valida uma regra de negócio
- `emits` — UC emite um evento de domínio
- `decision` — UC é restringido por um ADR

Use esses predicates nas seções "More Information" e "Related Information" para estabelecer rastreabilidade entre artefatos.
