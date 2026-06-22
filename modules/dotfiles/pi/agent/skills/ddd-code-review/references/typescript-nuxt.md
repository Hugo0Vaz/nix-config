# Referência — DDD em TypeScript/Nuxt

Sinais a investigar ao revisar código Nuxt/TypeScript contra o contrato em `docs/ddd.md`. Cada item é uma **pergunta a fazer ao código**, não um veredito; a regra final é sempre a do `docs/ddd.md`. O atrito central aqui é diferente do Laravel: Nuxt empurra a lógica para componentes `.vue`, composables e stores, e o desafio é manter o domínio independente da camada de UI e de fetching.

## Direção de dependência entre camadas

Confira os `import` no topo de cada arquivo de domínio.

- Código de domínio importando de `components/`, `pages/`, `layouts/`, ou de APIs do Nuxt/Vue (`vue`, `#app`, `useFetch`, `useState`, `navigateTo`)? O domínio deve ser puro TypeScript, sem depender do framework.
- Domínio acoplado a fetching/HTTP (`$fetch`, `useFetch`, `ofetch`, axios)? Acesso a dados pertence à camada de infraestrutura/repositório, não ao domínio.
- Domínio importando de `stores/` (Pinia) ou de composables de UI?

## Onde mora a lógica de negócio

- Regra de negócio dentro de **componentes `.vue`** (em `<script setup>`, `computed`, handlers de evento) em vez de no domínio? Componente deveria orquestrar/exibir, não decidir regra.
- Regra de negócio dentro de **stores Pinia** ou **composables** que deveriam só coordenar estado/UI? Confira o que o `docs/ddd.md` define como responsabilidade de cada um.
- Lógica em **server routes** (`server/api/`) direto, sem passar por uma camada de aplicação/domínio?
- **Modelo anêmico:** o domínio é só `interface`/`type` com dados, e toda a lógica vive espalhada em funções utilitárias soltas? Confira se o contrato pede entidades com comportamento (classes/funções de domínio coesas).

## Value objects e invariantes em TypeScript

- **Primitive obsession:** conceitos de domínio (Email, Money, CPF, UserId) como `string`/`number` crus em vez de VOs (classes ou branded types)? 
- Validação só em tempo de tipo (estrutural) sem garantia em runtime? Um `type Email = string` não impede um valor inválido — veja se o projeto exige validação na construção do VO.
- VO mutável (objeto comum reatribuível) onde deveria ser imutável (`readonly`, `Object.freeze`, branded type)?

## Composables, stores e fronteiras

- Composable fazendo coisa demais: UI + fetching + regra de negócio no mesmo arquivo? Procure separação clara de responsabilidades conforme o doc.
- Mapeamento ausente entre **DTO/resposta de API** e **entidade de domínio** — o tipo da API é usado direto como modelo de domínio em toda a aplicação?
- Estado de domínio duplicado/divergente entre store e domínio.

## Bounded contexts e nomenclatura

- Estrutura de pastas/módulos (ex.: por feature em Nuxt) não corresponde aos bounded contexts declarados no `docs/ddd.md`?
- Imports cruzando a fronteira de um bounded context diretamente, sem passar por um contrato/porta explícita?
- Nomes de tipos/funções divergem da linguagem ubíqua definida no doc (ex.: doc diz "Assinatura", código usa `Subscription` e `Plan` de forma inconsistente).

## Específico de Nuxt

- Lógica sensível rodando no cliente que deveria ser server-only (`server/`), ou segredos/regra exposta no bundle do cliente?
- Uso de `useState`/estado global do Nuxt carregando dado de domínio que deveria estar encapsulado.
