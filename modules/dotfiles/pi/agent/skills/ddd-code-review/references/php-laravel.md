# Referência — DDD em PHP/Laravel

Lista de sinais a investigar ao revisar código Laravel contra o contrato em `docs/ddd.md`. Cada item é uma **pergunta a fazer ao código**, não um veredito. A regra final é sempre a do `docs/ddd.md`; esta referência só ajuda a saber onde olhar. O atrito central do DDD em Laravel é que o framework é fortemente Active Record (Eloquent), o que empurra contra um domínio que ignora persistência — boa parte dos achados gira em torno disso.

## Direção de dependência entre camadas

A regra mais importante. Confira os `use`/namespaces no topo de cada arquivo de domínio.

- Código em `Domain/` que importa de `Infrastructure/`, `App\Models` (Eloquent), `Illuminate\*`, facades (`DB`, `Cache`, `Http`, `Auth`), ou de `Application/`? A camada de domínio deve ser a mais interna e não conhecer as de fora.
- Uso de helpers globais do Laravel dentro do domínio (`now()`, `config()`, `request()`, `auth()`, `event()` do framework)? Acoplam o domínio ao framework.
- Application chamando diretamente Eloquent/Query Builder em vez de passar por um repositório?

## Eloquent vazando para o domínio

- Entidade de domínio que **estende `Model`** (`class Pedido extends Model`)? Isso funde regra de negócio com mapeamento de persistência e Active Record — quase sempre contra a ideia de domínio persistence-ignorant. Confira o que o `docs/ddd.md` diz sobre entidades vs. models Eloquent.
- Repositórios que **retornam models Eloquent ou `Builder`/`Collection` de Eloquent** para fora da Infrastructure, em vez de entidades/objetos de domínio?
- Regra de negócio dentro de scopes, accessors/mutators, ou eventos de model (`booted`, `creating`) onde deveria estar no domínio?
- Mapeamento ausente: não há tradução entre o model de persistência e a entidade de domínio (eles são a mesma classe)? Confirme se o projeto adota mapeamento explícito.

## Onde mora a lógica de negócio

- Regra de negócio em **Controllers**, **FormRequests**, **Jobs**, **Listeners** ou **Commands** do Artisan, em vez de em entidades/agregados/serviços de domínio?
- **Modelo anêmico:** entidade só com getters/setters e toda a lógica num "Service" procedural? Confira se o contrato pede comportamento rico nas entidades.
- Validação de **invariante de domínio** feita só via validação de request (camada de UI), sem o domínio se proteger?

## Agregados e value objects

- Um caso de uso altera **mais de um agregado na mesma transação**? Costuma indicar limite de agregado errado. Veja o que o doc define como raiz e fronteira.
- Agregado referenciando outro **por objeto/relacionamento Eloquent** em vez de **por id**? 
- **Primitive obsession:** conceitos do domínio (CPF, Dinheiro, Email, Cpf, Status) representados como `string`/`int`/`float` soltos em vez de Value Objects? Confira se o projeto define VOs.
- Value Object **mutável** ou sem validação no construtor? VOs devem ser imutáveis e válidos por construção.

## Eventos, transações e efeitos colaterais

- Eventos de domínio confundidos com eventos do Laravel? Veja se o doc separa "domain events" de eventos de framework.
- Chamadas a serviços externos (`Http::`, mail, filas) feitas de dentro do domínio em vez de na Application/Infrastructure?
- Persistência disparada de dentro da entidade (`$this->save()`) em vez de via repositório no fim do caso de uso?

## Nomenclatura e linguagem ubíqua

- Nomes de classes/métodos divergem dos termos definidos no `docs/ddd.md`? (ex.: doc fala "Assinatura", código usa "Subscription" ou "Plano" de forma inconsistente).
- Namespaces/pastas que não correspondem ao bounded context declarado.
