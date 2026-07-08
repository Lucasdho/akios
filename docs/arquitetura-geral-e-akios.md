# akios — Arquitetura Geral, Arquitetura + akios, Decisões e Motivos

> **Sobre este documento.** Ele consolida, num único lugar, a arquitetura do projeto em
> duas camadas (o padrão portátil **ALVA** e a implementação **akios**), mais o registro
> das decisões e seus porquês. É uma reconstrução fiel a partir das fontes duráveis do
> repositório — `akios/specs/*`, `akios/workflow.yml`, `akios/Vision.md`, `akios/Roadmap.md`,
> `CHANGELOG.md` e `docs/architecture/plugin-architecture.md` — e não substitui essas
> fontes: elas continuam sendo a verdade canônica. Este texto é o mapa que amarra tudo.
>
> **Estado no momento da escrita:** akios v0.8.2. Pipeline `brainstorm → plan → design →
> deliver`. Arquitetura padrão: ALVA. Repositório: plugin/docs (não é um app iOS).

---

## Índice

- [Parte 0 — O que é akios](#parte-0--o-que-é-akios)
- [Parte 1 — Arquitetura geral: ALVA (o padrão portátil)](#parte-1--arquitetura-geral-alva-o-padrão-portátil)
- [Parte 2 — Arquitetura + akios (a implementação)](#parte-2--arquitetura--akios-a-implementação)
- [Parte 3 — Decisões e motivos (log consolidado)](#parte-3--decisões-e-motivos-log-consolidado)
- [Parte 4 — Linha do tempo (evolução das versões)](#parte-4--linha-do-tempo-evolução-das-versões)
- [Parte 5 — O que fica em aberto por design](#parte-5--o-que-fica-em-aberto-por-design)
- [Apêndice — Glossário](#apêndice--glossário)

---

## Parte 0 — O que é akios

**akios (Agentic Kit for iOS)** é um plugin do Claude Code, um plugin Codex-ready e uma família
de skills para construir apps Swift/iOS. No Claude Code, ele transforma o agente num
**teammate disciplinado** com comandos `/akios:*`, setup e hooks. No Codex, esta primeira camada
expõe a família de skills compartilhada; paridade completa de setup/comandos ainda é trabalho
futuro.

### North star

> akios é o kit de desenvolvimento agentic para iOS/Swift que transforma o Claude Code num
> teammate disciplinado: de uma ideia crua a código shipado, revisado e production-grade —
> com o dev no controle de cada decisão que importa e fora do loop de tudo que não importa.

### O que é (e o que não é)

| É | Não é |
|---|---|
| Um plugin + skill family que instala um pipeline repetível em qualquer projeto iOS/Swift | Um gerador de código |
| Uma fonte de conhecimento de domínio (Swift/iOS) + disciplina de processo | Uma IDE |
| Capaz de rodar o ciclo de feature inteiro sem supervisão quando o dev quiser | Um pair-programmer que reescreve código que já funciona |

Ele **aumenta o julgamento**; não o substitui.

### Princípios do produto

- **Specs são a memória.** Uma decisão que não foi escrita numa spec é uma decisão re-tomada
  toda sessão.
- **Gates são guardrails, não muros.** Soft gates avisam; só o quality gate e o push/merge
  gate são hard stops.
- **Unattended precisa ser auditável.** Toda decisão feita sem humano presente é registrada
  com o raciocínio, para revisão/override posterior.
- **Ship less, ship right.** A menor mudança correta ganha da solução completa mais esperta.
- **Sem dependências externas por padrão.** O kit ship tudo para onde sua espinha roteia
  (axiom e superpowers foram substituídos pelo `swift-dev` e `task-execution` próprios).

### Fora de escopo (por ora)

Plataformas não-Apple (Android, Flutter, React Native); dashboard/UI web hospedado (o kit é
terminal-first); submissão automatizada à App Store (juízo humano demais para automatizar
com segurança).

---

## Parte 1 — Arquitetura geral: ALVA (o padrão portátil)

> **ALVA — Agent-Legible Vertical Architecture.** Esta parte não menciona nenhuma ferramenta
> específica. É adotável com git + qualquer editor + o build system da sua stack. É o
> "padrão" publicável, seguível por quem **não** usa akios. Origem: sessão de co-design de
> 2026-06-30 sobre "arquitetura para agentes".

### 1.1 Por que ALVA existe

Arquiteturas maduras — MVVM, MVVM-C, Clean Architecture — foram desenhadas otimizando uma
**função de custo humana**:

- memória de trabalho limitada → *separation of concerns*;
- coordenação de time → contratos e fronteiras rígidas;
- onboarding → convenções;
- mudança ao longo de anos → desacoplamento.

Agentes de IA conseguem *seguir* essas arquiteturas, mas elas **não foram pensadas com
agentes em mente**. O agente tem uma função de custo diferente, e nenhuma arquitetura de
aplicação foi formalizada nativamente em torno dela. ALVA é a ponte: um padrão que IAs sigam
com facilidade, garantindo qualidade de código, sem jogar fora o que MVVM/Clean acertaram.

### 1.2 Posicionamento na indústria

ALVA não nasce do vácuo. É uma **síntese** de movimentos que já convergiam desde ~2024–2025:

- **Spec-driven development** — GitHub *Spec Kit*, AWS *Kiro*, o padrão `specs/ → tasks/ →
  execution`.
- **AGENTS.md** — convenção cross-tool de mapa/regras para o agente (`CLAUDE.md`,
  `.cursorrules` são a mesma família).
- **Vertical Slice Architecture** (Jimmy Bogard) e **package-by-feature**.
- **Locality of Behaviour** — ensaio de Carson Gross (htmx); a peça teórica central, mesmo
  sem falar de IA.
- **Context engineering** — escritos da Anthropic sobre design de agentes.

Em termos de indústria, ALVA é **Modular Monolith + Vertical Slices + Clean-within-slice +
SDD/TDD**. O que é **original** (e publicável como padrão próprio) são dois pedaços:

1. **Promoção DRY automatizada por evidência**, com lifecycle (promoção *e* demoção) — a
   *Rule of Three* de Fowler transformada em métrica mecânica.
2. **Design-token thinking estendido ao código**, com gate de graduação e *Protocol-Oriented
   Programming* como métrica semântica.

### 1.3 A função de custo (a régua)

Toda decisão arquitetural em ALVA é avaliada contra uma única régua:

> **Minimizar tokens-até-uma-mudança-correta-e-verificável** — a quantidade de contexto que
> um agente precisa reunir para alterar algo com segurança **e provar que está certo**.

Enquanto as clássicas otimizam cognição humana e coordenação de time, ALVA otimiza **o custo
de contexto por mudança**. Todo trade-off é resolvido a favor de reduzir esse custo.

Corolário: o agente nunca deveria precisar carregar o repositório inteiro (nem uma feature
inteira alheia) para fazer uma mudança correta. O raio de contexto de qualquer alteração deve
ser **local e limitado**.

### 1.4 Por que as clássicas brigam com o agente

Três atritos concretos:

1. **Espalhamento por camada.** Uma feature em Clean vive em
   entity/usecase/repository/datasource/presenter/viewmodel/view — 6 a 8 arquivos em
   diretórios distintos. O humano navega isso com o mapa mental; o agente precisa *carregar
   todos no contexto*. O custo de tokens explode e a chance de alucinação sobe.
2. **Abstração como indireção.** DRY foi feito para reduzir custo de manutenção humana. Mas
   cada abstração é um *hop* que o agente precisa rastrear. **Localidade > DRY** para código
   mantido por agente: repetição consistente é mais barata que uma abstração "esperta" a
   perseguir por vários arquivos.
3. **Conhecimento que mora fora do código.** O humano pergunta pro time. O agente não. Se a
   decisão não está no código, no tipo ou num doc adjacente, ela **não existe** para o agente.

### 1.5 Os 7 princípios

Cada princípio é consequência direta da função de custo.

- **P1 — Localidade sobre camadas.** Uma mudança de feature ≈ um diretório aberto. A
  separação estilo Clean vive **dentro** do slice, não espalhada. Preserva testabilidade e
  inversão de dependência, mas colapsa o raio de contexto para dentro de uma pasta.
- **P2 — Convenção como compressão.** Toda feature tem **exatamente a mesma forma**. O agente
  aprende a forma uma vez e a reproduz sempre. Uniformidade > flexibilidade. A estrutura
  repetida é, na prática, um *prompt* implícito.
- **P3 — Fronteira por contrato, imposta pela toolchain.** Uma feature importa apenas o
  **contrato público** (`contract/`) e a `Foundation/` de outra — nunca os internos
  (`domain/`, `data/`) alheios. E a fronteira é **imposta pela ferramenta, não pela
  disciplina**: o build deve *recusar* compilar o acesso indevido. Convenção que depende de
  boa-vontade, o agente fura; parede física, não.
- **P4 — Composição no topo.** Só o topo do projeto conhece mais de uma feature. `Router/`
  resolve navegação cross-feature; `Container/` injeta contratos. Nenhuma feature "conhece"
  outra diretamente — elas se encontram no ponto de composição.
- **P5 — DRY por evidência, não por palpite.** Código nasce dentro da feature. Só **gradua**
  para `Foundation/` quando há prova mecânica de uso ≥ X (a *Rule of Three* automatizada).
  Abstração deixa de ser julgamento e vira métrica — trocando onde o agente é fraco (julgar)
  por onde ele é forte (executar uma decisão já tomada).
- **P6 — O ledger é ferramenta, não julgamento.** A contagem de uso que dispara a promoção é
  **determinística** (produzida por tooling), nunca estimada pelo agente. O agente apenas
  **lê** o resultado. Antes de escrever um helper novo, consulta só a `Foundation/` (pequena
  e indexada) — nunca o repo inteiro.
- **P7 — Loop de verificação curto.** Cada slice carrega, co-localizados, **a intenção e a
  prova**: uma spec (SDD) e testes (TDD) ao lado do código. É o que fecha a função de custo —
  torna *barato provar* que a mudança está certa.

### 1.6 Estrutura de pastas (referência)

```
Project/
  Router/                    → navegação (composição cross-feature)
  Container/                 → injeção de dependência
  Foundation/                → código graduado, compartilhado
    Design-tokens/           → FOLHA visual: componentes, modifiers, utils, enums de UI
    Code-tokens/             → PROTOCOLOS + helpers, casos de uso e serviços compartilhados
    usage-ledger.json        → contagem determinística de uso (o "arquivo B")
  Specs/
    Features.md              → índice das features

  Features/
    User/
      domain/                → regras e entidades da feature
      data/                  → fontes de dados, repositórios concretos
      presentation/          → UI + estado da feature
      tests/                 → TDD co-localizado
      contract/              → PÚBLICO: a interface + DTOs que outras features importam
      Feature-spec.md        → SDD: intenção + declaração do que a feature consome
    Purchase/                → mesma estrutura, exatamente
    Feature-N/               → mesma estrutura, exatamente
```

`domain / data / presentation / tests` = Clean Architecture **dentro** do slice. `contract/`
é o único ponto de acesso externo. `Feature-spec.md` declara, no cabeçalho, quais contratos e
símbolos da `Foundation/` a feature consome.

### 1.7 Fronteira por contrato & composição cross-feature

O maior risco de vertical slices é o momento em que features precisam conversar. Se mal
resolvido, os slices enfiam a mão nas tripas uns dos outros e o acoplamento fica **pior** que
camadas. ALVA resolve com três ideias de DDD:

- **Bounded Context.** O `User` visto por `Purchase` **não é** o mesmo `User` do Perfil.
  `Purchase` define sua própria visão — ex.: `Buyer { id, nome, meioDePagamentoPadrão }` —
  com só o que precisa. É o *anti-corruption layer*: mudar os internos de `User` não propaga,
  e o agente que mexe em `Purchase` nunca precisa do modelo completo de `User`.
- **Contrato / Facade.** Cada feature expõe uma interface pública estreita e tipada
  (`contract/`: protocolo + DTOs). Comunicação cruzada passa **só** pelo contrato. Ao
  trabalhar em `Purchase`, o agente carrega o slice de `Purchase` inteiro + o `contract/` de
  `User` (pequeno) — **não** a implementação de `User`. O contrato é a **unidade de contexto
  entre slices**.
- **Composição no topo.** `Container/` injeta o *contrato* de `User` dentro de `Purchase`;
  `Router/` resolve navegação cross-feature. As features se encontram apenas ali.

**Posse de tela multi-domínio.** Uma tela que envolve mais de um domínio pertence à feature
cuja **intenção** ela serve; consome as outras por contrato:

- "Minhas compras" → intenção é Compras → vive em `Purchase`, consome `User.contract`.
- "Perfil com compras recentes" → intenção é Perfil → vive em `User`, consome
  `Purchase.contract`.

Sinal de alarme: se um slice precisa importar o *interno* de outro para funcionar, o contrato
está errado (ou a fronteira está no lugar errado).

**Dois problemas distintos — não confundir:**

| Problema | Solução em ALVA |
|---|---|
| Código *leaf* repetido (modifier, formatter) | Foundation / promoção |
| Feature A precisa do *domínio* da Feature B | Contrato / bounded context |

A `Foundation/` resolve **compartilhamento de folhas**; ela **não** resolve composição de
domínios. Mecanismos diferentes, ambos necessários.

### 1.8 DRY por evidência — a mecânica da Foundation

Este é o coração original de ALVA. Em vez de abstrair por antecipação (indireção cara para o
agente), o código **prova que merece** ser compartilhado.

**O ciclo de graduação:**

1. Código nasce **dentro** de uma feature.
2. Uma ferramenta determinística conta em quantas features distintas ele é usado.
3. Ao cruzar um threshold X, vira **candidato a promoção** para `Foundation/`.
4. A promoção é **sugerida** (não automática) e executada como uma tarefa revisável.
5. Se o uso cair abaixo de X, vira **candidato a demoção** — volta pra única feature que
   ainda usa, ou é removido.

É a **Rule of Three** de Fowler ("não abstraia até ver 3 vezes"), só que mecânica e medida —
remove o julgamento humano/agente, que é a parte não confiável.

**Duas gavetas, regras diferentes** (porque o risco de compartilhar difere):

- **Design-tokens** — reutilização visual: componentes, view modifiers, utils e enums de UI.
  São **folha**: puros, sem dependências, blast radius ≈ zero. **Promova liberalmente**;
  threshold baixo (2 já serve).
- **Code-tokens** — **protocolos** (a espinha do POP), além de helpers, casos de uso e
  serviços compartilhados. Carregam **comportamento e dependências**. Promover um serviço é
  declará-lo **domínio central**: bar alto, e ele sobe **atrás de um contrato**, não só
  "movido de pasta". Senão recria-se o `utils/`-lixão.

> Regra derivada: **promover coisa pura é barato e bom; promover coisa com comportamento é
> raro e passa por contrato.**

**POP como métrica semântica.** Colocar protocolos em Code-tokens torna a contagem
**semântica**: para um protocolo, "uso" = número de **conformances**, não de ocorrências
textuais do nome (frágil). A escolha por Protocol-Oriented Programming transforma a métrica de
"quantas vezes esse nome aparece" (impreciso) em "quantos tipos conformam a este protocolo"
(exato e semântico).

**O usage-ledger** (requisito portátil + implementação de referência): deve existir uma
**contagem determinística de uso, produzida por ferramenta**; a promoção resultante é
**sugerida**. O agente **lê** o ledger; nunca conta na mão. O princípio-chave:

> O custo de investigação sai de *por-run-do-agente* (caro, repetido) para
> *por-commit-determinístico* (barato, cacheado). A investigação some do contexto do agente.

Estratégias de contagem (da mais barata à mais precisa; combináveis): **A** textual
(git-hook + ripgrep, impreciso mas trivial) → **B** índice do compilador (preciso, semântico,
zero token de agente) → **C** grafo de módulos (grátis, granularidade de módulo) → **D**
declaração explícita no `Feature-spec.md` (barato, legível, cruza com B). Recomendação:
começar em A, evoluir para B, cruzar com C/D. O mesmo hook que conta para cima conta para
baixo (lifecycle completo).

**Por que "sugerida" e não "automática":** promover é uma mudança de blast radius alto (vira
dependência de N features) e quase irreversível. Não deve acontecer silenciosamente num run.
A promoção sugerida mantém o agente no papel que ele faz bem (executar), transforma o ledger
num **ponto de revisão**, e faz cada promoção ser uma **tarefa** rastreável.

### 1.9 Verificação (TDD + SDD)

- **SDD:** cada feature tem uma `Feature-spec.md` co-localizada — a *intenção* ao lado do
  código, legível sem sair do slice.
- **TDD:** cada feature tem `tests/` co-localizados — a *prova*.

Juntos fecham a função de custo: intenção + prova locais tornam barato entender **e**
verificar a mudança dentro do próprio slice.

### 1.10 O que é original em ALVA (resumo publicável)

1. **Promoção DRY automatizada por evidência**, com lifecycle completo (promoção *e* demoção)
   — Rule of Three virada métrica mecânica.
2. **Design-token thinking estendido ao código**, com gate de graduação e POP como métrica
   semântica de uso.

O resto é montagem deliberada de coisas que já funcionam, reorganizadas sob uma função de
custo nova.

### 1.11 Realização da fronteira por ecossistema (P3)

| Ecossistema | Unidade de fronteira |
|---|---|
| Swift | módulo / local package (SPM) |
| Kotlin/Android | módulo Gradle |
| TypeScript | package de workspace + `exports`, ou dependency-cruiser/ESLint boundaries |
| Rust | crate |
| Java/.NET | módulo/assembly + `internal` (ou ArchUnit) |
| Python (sem enforce nativo) | import-linter / architectural lint |

Degradê honesto: linguagem que não impõe no compilador cai para **lint de arquitetura**. O
princípio sobrevive; muda o executor.

---

## Parte 2 — Arquitetura + akios (a implementação)

> Esta parte é a **implementação conforme** de ALVA no kit akios (Swift/iOS). Aqui moram as
> especificidades de ecossistema e o workflow de agentes.

### 2.1 Modelo mental: duas camadas

**ALVA é o padrão; akios é uma implementação otimizada do workflow do padrão.** Alguém em
outra stack implementa ALVA na mão ou com regras próprias; no akios ela vem chave-na-mão,
imposta e automatizada pelas skills e gates.

> **Camada 1 (ALVA):** tudo que é *verdade sobre o código* e pode ser adotado com git +
> editor + build system, sem akios.
> **Camada 2 (akios):** as skills/gates/pipeline que *automatizam produzir e impor* a Camada 1.

**Regra de ouro do particionamento:** sempre que uma regra tiver cheiro de ecossistema, o
*conceito* sobe para ALVA e a *realização* desce para o akios.

Especificidades Swift/iOS que descem para o akios: unidade de fronteira = um local SPM module
por feature (`public` só o `contract/`, `internal` o resto); Code-tokens = protocolos Swift
(contagem semântica via índice do compilador); Design-tokens = componentes SwiftUI,
`ViewModifier`s, estilos, enums de UI; e as APIs de SDK (`@State`, modifiers) ficam aqui,
nunca na Parte I.

### 2.2 O que o kit é (natureza do repositório)

**Este repositório É o plugin** — não é um app iOS. Ele ship skills, commands, templates e
scripts para Claude Code e um manifesto Codex que aponta para a mesma família de skills. Não há
código Swift, nem projeto Xcode, nem build system aqui. Artefatos: `.md`, `.yml`, `.sh`, `.json`.
"Testes" = auditorias de DoD (grep por refs órfãs, validação de YAML, smoke-test de instalação
de skill e validação dos manifestos de plugin).

> **Estado do suporte Codex.** `.codex-plugin/plugin.json` torna o Akios instalável/validável
> pelo Codex e reaproveita `skills/`. Os comandos `/akios:*`, `/akios:setup`, templates `CLAUDE.md`
> e hooks `.claude/` permanecem Claude-first até a migração explícita para caminhos `.codex/`,
> `~/.codex/akios` e comportamento de hooks compatível.

> **Nota de nomenclatura (importante).** O repo git chama-se `akios`; ele **também** contém
> uma subpasta literalmente chamada `akios/` — a mesma pasta de housekeeping que
> `/akios:setup` cria em todo repo consumidor. Este repo dogfooda a própria convenção: não
> confunda "o repo akios" com "a pasta `akios/` dentro dele".

### 2.3 O que instala num repo consumidor

| Arquivo | Papel |
|---|---|
| `CLAUDE.md` | O que o Claude Code auto-carrega; importa `@AGENTS.md` + `@akios/Context.md` |
| `AGENTS.md` | Manual de operação — o loop, a priority chain, a gate table (fonte única) |
| `akios/Context.md` | Stack, comandos, arquitetura, convenções |
| `akios/Roadmap.md` | Flags de modo + tabela de estado por spec |
| `akios/workflow.yml` | O contrato de fases (comandos + detecção de fase leem daqui) |
| `.claude/rules/swift.md` | Regra path-scoped — carrega o gate `swift-dev` ao ler um `.swift` |
| `.claude/hooks/agentic-kit-inject.sh` | Hook SessionStart — re-declara os gates toda sessão |
| pastas | `akios/specs/ akios/tasks/{todo,in-progress,review,done}/ archive/ akios/code-references/` |

Decisões duráveis de **projeto** vivem na auto-memory nativa (`MEMORY.md`); preferências de
**usuário** transferíveis vivem em `~/.claude/akios/preferences.md` (user-global, fora do repo).

Desde a v0.8.1, um `/akios:setup` fresco produz **9 entradas root** (antes eram 15): tudo do
housekeeping do akios foi consolidado numa única pasta `akios/`. O journal de runtime
gitignored virou `akios/.local/` (aninhado na pasta visível, não um irmão dot-prefixed).

### 2.4 O pipeline (a espinha)

O kit amarra suas skills num **fluxo único dirigido por spec**, definido em
**`akios/workflow.yml`** (o contrato machine-readable). Os comandos são wrappers finos que
leem esse arquivo — deliberadamente não re-documentam as fases.

```
brainstorm (idea-to-spec) → plan (spec-to-tasks) → design (ui-variations + align-ui) → deliver (task-execution)
```

- **Detecção de fase** = a fase mais alta cujos `outputs` já existem (por spec).
- **Phase gate** = todos os `prereqs` da fase existem (soft gate: avisa + oferece).
- `design` dispara só para tarefas **UI-scoped** (explore/remix/graduate de tela, resolver
  estados/interações/heurísticas). Tarefas não-UI (domain/data/contract) pulam de `plan`
  direto para `deliver`.

| Fase | Comando | Skill | Prereqs | Outputs | Status Roadmap |
|---|---|---|---|---|---|
| brainstorm | `/akios:brainstorm` | `idea-to-spec` | Context.md, Roadmap.md | `akios/specs/*.md` | designed |
| plan | `/akios:plan` | `spec-to-tasks` | `akios/specs/*.md` | `akios/tasks/todo/*.md` | planned |
| design | `/akios:design` | `ui-variations` (+`align-ui`) | `akios/tasks/todo/*.md` | `presentation/*.swift`, `ui-alignment/*.md` | in-progress |
| deliver | `/akios:deliver` | `task-execution` | `akios/tasks/todo/*.md` | `akios/tasks/done/*.md` | done |

`/akios:setup` é **bootstrap, não uma fase** (não tem prereq de spec/task). Todos os comandos
são typed-only (`disable-model-invocation`) — nunca auto-disparam.

### 2.5 Run-styles (sobre o pipeline)

Duas coisas rodam *sobre* as fases, sem serem fases:

- **`deep-brainstorm`** (`/akios:deep-brainstorm`) — pre-execution run-style. Discovery e
  cartografia do produto inteiro (Double Diamond), produzindo uma **família de specs**
  completa que alimenta o pipeline normal. Interativo por padrão; sob just-vibes vira modo
  deepthink não supervisionado. Integra `founderlens-behavior` para o primeiro diamante
  (Discover→Define) quando disponível.
- **`just-vibes`** (`/akios:just-vibes`) — run-style unattended sobre as fases. Escolhe o
  próximo "fuel" e entrega sem o gate humano por-spec (o **quality gate permanece**). Default:
  uma unidade, então para no boundary da spec; `--force`: loop até esgotar o fuel.

**Precedência de fuel** (mais pronto primeiro): ideia explícita (argumento) → `tasks/todo/*`
→ `tasks.md` legado (retirado) → `specs/*.md @ designed` → specs sem entrada no Roadmap →
item de `Vision.md`/`Roadmap.md`. Waives: o gate humano de push/merge (invocação =
autorização). Keeps: verify + code-review + fix loop bounded (park red, nunca entrega
quebrado).

### 2.6 Skills e roteamento

Top-level (registradas em `scripts/install-skills.sh`, o que de fato ship): `idea-to-spec`,
`spec-to-tasks`, `task-execution`, `swift-dev`, `ui-variations`, `align-ui`, `deep-brainstorm`,
`founderlens-behavior`, `just-vibes`, `handoff`, `knowledge-ingest`, `skill-author`,
`oss-first`, `ios-feature-pipeline`, `ios-agentic-kit`.

`swift-dev` é o **router de todo trabalho Swift/iOS** e empacota ~14 sub-skills aninhadas
(`skills/swift-dev/skills/<name>/GUIDE.md`) que ship como parte dele via `cp -R` — sem entrada
própria em `SKILLS=(...)`, sem versão independente. Cobrem SwiftUI, concorrência, testing,
SwiftData, acessibilidade, performance, `alva-architecture`, `figma-to-swiftui`,
`review-doctrine`, etc.

Para qualquer feature end-to-end, **começa-se pelo `ios-feature-pipeline`** (uma skill,
invocada por descrição ou nome — não um slash command): ele lê o `workflow.yml`, detecta a
fase atual por spec, e caminha os hand-offs. Sem speckit: o rigor de design vive no
`idea-to-spec`, a qualidade no `AGENTS.md` + `swift-dev` + `/code-review`.

> **Gotcha operacional recorrente:** `install-skills.sh` tem um array `SKILLS=(...)`
> hard-coded — esquecer de adicionar um skill novo ali é o erro mais comum. `skill-author` +
> `/akios:new-skill` existem justamente para eliminar esse gotcha, self-registrando via
> `scripts/register-skill.sh`.

### 2.7 A priority chain (resolução de decisão de código)

Para qualquer decisão de código, resolve-se top-down (o primeiro tier com resposta ganha):

```
1. Decisão de projeto      (MEMORY.md + código existente / akios/Context.md)
2. Knowledge packs curados  (akios/code-references/ = o code pack; outros packs ingeridos)
3. Preferências do usuário  (~/.claude/akios/preferences.md)
4. Baseline packs (floor)   (swift-dev = o pack `ios`; outros baseline packs)
```

Isso é a materialização da **arquitetura de conhecimento** (`knowledge-architecture.md`): o
split meta-prompt/conhecimento, o formato `pack.yml`/`INDEX.md`, `swift-dev` re-manifestado
como o baseline pack `ios`, e `code-references/` reframed como o code pack do projeto.
`/akios:learn` (`knowledge-ingest`) ingere código/PDF/imagem/livro/doc num pack — delegando a
extração pra skill certa de cada tipo de fonte (nunca hand-parse o que uma ferramenta madura
já resolve — a doutrina `oss-first`).

### 2.8 Os 4 flags de Roadmap (postura operacional)

Quatro flags ortogonais que `/akios:setup` escreve no `akios/Roadmap.md`; cada fase lê e
ajusta comportamento:

| Flag | Valores | O que controla |
|---|---|---|
| `mode` | new / one-shot / feature | O estilo da sessão de brainstorm |
| `collaboration` | solo / team | **Quem mais** trabalha no repo. solo → just-vibes merge+push na default; team → push feature/<spec> + PR, claim-before-work + assinaturas |
| `posture` | learning / delivery | **Só a superfície de ensino** (nunca o que é construído). learning → cita princípios inline + alternativas + captura eager + digest de fim de unidade; delivery → decisões gravadas no artefato, não narradas |
| `autonomy` | manual / auto | **Se just-vibes pode auto-push/merge**. Independente de `collaboration` — NÃO inferido dele. manual → nunca push/merge, mesmo sob --force (unidade verde fica local, reportada em "Built (unshipped)"); auto → auto-ship conforme `collaboration` |

O ponto crucial de `autonomy` × `collaboration`: `collaboration` responde "quem mais mexe
aqui" (solo/team); `autonomy` responde "just-vibes está autorizado a shipar sozinho".
Separá-los foi uma decisão explícita (spec `collaboration-autonomy.md`).

### 2.9 O status enum (resolução de conflito de merge)

O `## Specs` do Roadmap usa um enum **monotônico** para resolver conflitos multi-instância
(status mais alto sempre ganha; uma spec `done` nunca é rebaixada):

```
needs-revision < designed < planned < in-progress < blocked < done
```

`needs-revision` (a auditoria R-W-W do deep-brainstorm flagou a spec fraca) e `blocked` (o fix
loop do task-execution desistiu) são **side-states de demoção**, não fases abaixo — a spec
precisa voltar a `designed`/`in-progress` antes de avançar de novo.

### 2.10 O ledger no fluxo akios

- O git-hook/CI mantém `Foundation/usage-ledger.json` (Camada 1, tool-agnostic) — implementado
  em `scripts/alva-usage-ledger.sh` (estratégia grep + git-hook, a "estratégia A").
- `task-execution` **lê** o ledger; nunca conta.
- Cada entrada em `candidates_promote`/`candidates_demote` vira uma **tarefa** em
  `tasks/todo/` — o elo que só o akios fornece. A promoção continua **sugerida**: backlog
  revisável, não mutação silenciosa.

### 2.11 Subagentes e context chaining

Trabalho grande é despachado para subagentes cold-start com um handoff file (nunca fork), e
sessões grandes são partidas em 3+ sessões de código. A partir da v0.8.2
(`subagent-context-chaining.md`), um subagente **encadeia** um batch sequencial de tarefas,
auto-compactando entre elas em vez de ser morto e re-spawned por tarefa; ao cruzar um
**budget de lineage de 120k tokens**, escreve um handoff e termina, e o orquestrador spawna um
subagente fresco para continuar. Isso responde ao incidente documentado de um subagente de
~300k tokens com um **threshold repetível** em vez de um julgamento ad hoc.

> Há três thresholds de valor parecido no kit, historicamente confundidos e agora
> desambiguados numa tabela no `templates/AGENTS.md`: a linha de compact inter-spec
> (110k/135k), a linha de julgamento de dispatch do orquestrador (120k), e o novo budget de
> lineage do subagente (120k).

### 2.12 Scripts e hooks

| Script | Papel |
|---|---|
| `install.sh` | Pluga o kit num repo alvo (usado por `/akios:setup`) |
| `install-skills.sh` | Instala o array `SKILLS=(...)` em `~/.claude/skills/`. Fonte da verdade do que é registrado |
| `check-update.sh` | Checa se a instalação de um projeto está atrás do clone do kit |
| `akios-instance.sh` | Identidade estável por-instância para claim etiquette (team mode) |
| `alva-usage-ledger.sh` | O ledger de uso da Foundation — grep + git-hook |
| `register-skill.sh` | Adiciona idempotentemente um skill novo ao array |
| `test-kit.sh` | Sanity check: skills authored + templates de install presentes e bem-formados |

| Hook | Trigger | Papel |
|---|---|---|
| `agentic-kit-inject.sh` | SessionStart | Re-declara os gates default + descobre knowledge packs a cada sessão. Lembra, não força |
| `post-checkpoint-verify.sh` | Chamado por task-execution nos checkpoints `[major]` | Prova auto build/test; não wired a evento do Claude Code (lento demais por tool-call) |
| `skill-trace.sh` | PostToolUse | Appenda linha JSON de trace em `akios/.local/trace.jsonl` |

---

## Parte 3 — Decisões e motivos (log consolidado)

### 3.1 Decisões arquiteturais de ALVA (D1–D15)

| # | Decisão | Escolha | Motivo | Alternativa rejeitada |
|---|---|---|---|---|
| D1 | Régua de decisão | Função de custo = tokens-até-mudança-correta-e-verificável | Agentes têm restrição diferente da humana; precisa métrica própria | Otimizar cognição humana (status quo MVVM/Clean) |
| D2 | Organização macro | Vertical slices; Clean **dentro** do slice | Colapsa o raio de contexto por mudança | Package-by-layer (espalha feature por 6–8 dirs) |
| D3 | Uniformidade | Mesma estrutura em toda feature | Convenção = compressão; agente aprende a forma uma vez | Flexibilidade por feature |
| D4 | Fronteira entre features | Contrato + unidade imposta pela toolchain | Parede física > disciplina; agente não fura o que não compila | Convenção/documentação apenas |
| D4b | Nome da fronteira | Abstrair "SPM" → "unidade de fronteira imposta" | SPM é iOS-específico; ALVA precisa ser cross-stack | Fixar SPM na Camada 1 |
| D5 | Composição cross-feature | Router + Container no topo | Único lugar que conhece >1 feature; mantém slices ignorantes | Features se referenciando direto |
| D6 | Posse de tela multi-domínio | Dona = feature da intenção; consome contratos | Evita duplicação e coupling; raio de contexto limitado | Tela "neutra" importando internos |
| D7 | DRY | Promoção por evidência (Rule of Three automatizada) | Remove julgamento (fraqueza do agente); vira métrica | Abstrair por antecipação (indireção cara) |
| D8 | Split da Foundation | Design-tokens (folha) vs Code-tokens (protocolos/comportamento) | Risco de compartilhar difere; bar de promoção difere | Uma pasta única `shared/` |
| D9 | Code-tokens = protocolos | POP | Contagem vira semântica (conformances), não textual | Helpers soltos sem contrato |
| D10 | Promoção de comportamento | Bar alto + atrás de contrato | Serviço compartilhado = domínio central; blast radius alto | Mover serviço "de pasta" livremente |
| D11 | Gatilho de promoção | **Sugerida**, não automática | Alto blast radius e ~irreversível; agente executa, não decide | Hook move código e reescreve imports sozinho |
| D12 | Lifecycle | Promoção **e** demoção | Sem demoção, Foundation vira cemitério (`utils/`-lixão) | Só contar para cima |
| D13 | Contagem | Ferramenta determinística (ripgrep → índice), fora do loop do agente | Custo de investigação vira per-commit cacheado, não per-run | Agente conta grepando o repo (caro) |
| D14 | Nome da gaveta de código | "Foundation" | "token" está triplamente carregado (design/LLM/léxico) | Manter "Code-tokens" como guarda-chuva |
| D15 | Estrutura do doc | Duas camadas separadas (ALVA portátil / ALVA+akios) | Torna ALVA publicável sozinha; akios é implementação conforme | Doc único acoplado ao akios |

### 3.2 O fork resolvido: ALVA vs. layer-first

Havia uma bifurcação arquitetural aberta: **ALVA (vertical slices)** vs. as **camadas
compartilhadas** da família de UI. Resolvido em 2026-07-01 (`alva-adoption.md`, decisões
D1/D2) **a favor de ALVA**. Consequência: o folder shape de `ui-first-architecture.md` (§1/§2)
foi **superseded** por ALVA §4/§6, mas suas **leis comportamentais** (build-order,
dumb-component `init` rule, Router/Container DI) sobreviveram, re-homed em
`presentation/<View>/` e realizadas no guide `alva-architecture/GUIDE.md`. Uma única decisão
humana (o fork) destravou todo o backlog de "arquitetura para agentes" + "skill não organiza
pastas".

### 3.3 O pivot v2.0: prototype-first, Figma/Stitch/HTML parked

`prototype-first-workflow.md` sofreu um pivot v2.0 em 2026-07-01: o workflow visual passou a
ser **multi-variant SwiftUI `#Preview` direto no código** (explore → remix → graduate), sem
tradução HTML nem Figma/Stitch intermediários — esses foram **parked**. Isso originou a nova
fase `design` e a skill `ui-variations`. A família de UI (C→A→B: `prototype-first-workflow`,
`ui-first-architecture`, `swiftui-design-doctrine`) foi consolidada num backlog ordenado
(`ui-overhaul-implementation.md`) re-apontado para `presentation/` dentro de um slice ALVA.

### 3.4 Renomeações que resolveram colisões

- **`execute` → `deliver`** (pipeline agora `brainstorm → plan → design → deliver`).
- Como consequência, a ação de push/merge do próprio `just-vibes` foi renomeada
  **`DELIVER` → `SHIP`** para resolver a colisão de nome.
- **`/akios:init` → `/akios:setup`** no mesmo passe.

### 3.5 Footprint consolidation (v0.8.1)

`akios-footprint-consolidation.md` reabriu e estreitou a decisão de footprint do
`init-reliability-and-ux.md` (§5, D5): consolidou todo o housekeeping gerado pelo akios
(`Context.md`, `Roadmap.md`, `Vision.md`, `workflow.yml`, `specs/`, `tasks/`, `archive/`,
`code-references/`, journal de runtime) numa **única pasta root `akios/`**. Reduziu de 15 para
9 entradas root num setup fresco. Este próprio repo se auto-migrou via `git mv` (histórico
preservado), dogfoodando a convenção que ship. Deliberadamente excluídos da migração:
`tasks/done/**` e prosa de specs arquivadas (histórico, deixado como está).

### 3.6 A decisão "sem dependências externas"

axiom e superpowers (dependências externas antigas) foram **substituídos** pelo `swift-dev` e
`task-execution` próprios do kit. Motivo: o axioma "o kit ship tudo para onde sua espinha
roteia" — nenhuma dependência externa obrigatória. `ponytail` continua **opcional** (só mantém
o código enxuto), oferecido mas nunca bloqueante.

### 3.7 Auditoria de arquitetura do plugin — flags resolvidos

Uma auditoria (`docs/architecture/plugin-architecture.md`) levantou observações; cada uma foi
checada contra o conteúdo real:

- **Overlap de meta-documentação** — falso alarme. `Context.md`/`README.md`/`ios-agentic-kit`/
  `ios-feature-pipeline` servem audiências diferentes (self-context, visitante do GitHub,
  onboarding do kit, roteamento de fase in-flight). É layering, não duplicação.
- **Sprawl dos sub-skills `swiftui-*`** — falso alarme. O router table do `swift-dev/SKILL.md`
  já documenta boundaries explícitos. As 627 linhas de `swiftui-design-principles` vs. 95–108
  dos vizinhos é escopo, não redundância.
- **`CODE_OF_CONDUCT.md` com cara de vendored** — confirmado, removido.
- **`tasks.md` root** — confirmado, retirado (migrado inteiro para `akios/tasks/todo/`); a
  descrição em tempo presente no `Context.md` foi corrigida.

---

## Parte 4 — Linha do tempo (evolução das versões)

- **v0.7.0** — Refactor de plugin-architecture; `plugin-architecture.md` shipado. Backlog
  single-file `tasks.md` (T001–T021).
- **v0.7.3** — R-W-W post-burst audit phase + filtro de fuel do just-vibes
  (`deep-brainstorm-rww-audit.md`).
- **2026-06-30** — Sessão de co-design "arquitetura para agentes" → nasce **ALVA v1.0**.
- **2026-07-01** — Fork ALVA-vs-layer resolvido a favor de ALVA (`alva-adoption.md`); pivot
  v2.0 prototype-first (Figma/Stitch/HTML parked).
- **v0.8.0 (2026-07-02)** — O grande arco. ALVA adotada como doutrina default. Fase `design` +
  `ui-variations`. Knowledge packs + `knowledge-ingest` + `/akios:learn`. `kind: snippet` +
  skeleton library. `skill-author` + `/akios:new-skill`. Flag `posture`. Divergence audit +
  três provas + hurdles ledger + `post-checkpoint-verify.sh`. `review-doctrine`. Flag
  `autonomy`. Reliability do `/akios:setup`. Reconciliação de consistência de contrato (B36,
  ~17 pontos de drift).
- **v0.8.1 (2026-07-03)** — Consolidação da pasta `akios/` (footprint); auto-migração do
  próprio repo.
- **v0.8.2 (2026-07-03)** — Subagent context chaining (budget de lineage de 120k).
- **2026-07-03** — Fechamento de drift de specs (commits 7b1e209, 016ba9f).

---

## Parte 5 — O que fica em aberto por design

Nem tudo está construído — algumas coisas foram **deliberadamente** deixadas em aberto:

- **`parallel-execution-scheduling.md`** (B37) — `designed`, não construído. Generaliza o
  collision check `[P]` do `spec-to-tasks` para specs inteiras (quais pares são seguros para
  delegação concorrente). Self-surfaced durante a Session 2; **não está no critical path** —
  construir quando um batch multi-spec futuro se beneficiar. É o único spec que segue
  `designed` por design (ortogonal ao subagent-context-chaining: breadth vs. depth).
- **Threshold de within-tier pack precedence e auditoria de pack ingerido**
  (`knowledge-architecture.md` §9) — deixados abertos.
- **`hurdles.md` vazio + tuning do threshold de 2ª ocorrência**
  (`verification-and-learning-loop.md` §7,§8).
- **Linha block/warn para drift de shape de slice** (`code-review-doctrine.md` §8) — a tunar
  após uso em repo real.
- **Modo `--from <transcript>` de distillation do `skill-author`** (`skill-authoring.md` §7).
- **Path de ingestão de skeleton** (`skeleton-library.md` §11).
- **Ideia de manifest-file durável** (`init-reliability-and-ux.md` §11).
- **Polimento de team mode do just-vibes** (Vision wishlist #4) — ainda spec-less, wishlist
  genuíno: claim + assinatura endurecidos com runs concorrentes reais.

O princípio geral: essas linhas são pontos de tuning que só fazem sentido calibrar depois de
uso real, ou capacidades fora do critical path. Deixá-las abertas é uma decisão, não um
esquecimento.

---

## Apêndice — Glossário

- **ALVA** — Agent-Legible Vertical Architecture. O padrão desta doutrina.
- **Função de custo** — tokens-até-uma-mudança-correta-e-verificável; a régua de toda decisão.
- **Slice / feature** — unidade vertical autocontida com sua própria estrutura Clean interna,
  contrato e spec.
- **Contract** — a interface pública (protocolo + DTOs) que outras features importam; a única
  superfície externa de um slice.
- **Foundation** — o diretório de código graduado/compartilhado, dividido em Design-tokens e
  Code-tokens.
- **Design-tokens** — reutilização visual folha (componentes, modifiers, utils/enums de UI).
- **Code-tokens** — protocolos (POP) + helpers/casos de uso/serviços compartilhados.
- **Promoção / demoção** — mover código para/da Foundation com base em evidência de uso.
- **usage-ledger** — o artefato determinístico de contagem de uso ("arquivo B").
- **Gate** — checkpoint "antes de X, faça Y". Soft gate avisa; hard gate (quality, push/merge)
  para de verdade.
- **Spec** — descrição versionada de uma feature: o que faz e como se comporta. A memória.
- **Fuel** — o que o just-vibes escolhe para trabalhar em seguida (ideia, task, spec, item de
  Vision).
- **Priority chain** — a ordem de resolução de decisão de código (projeto > packs curados >
  preferências > baseline).
- **Knowledge pack** — unidade de conhecimento roteável (`pack.yml`/`INDEX.md`); `swift-dev` é
  o baseline pack `ios`, `code-references/` é o code pack do projeto.
- **Camada 1 / Camada 2** — ALVA (verdade sobre o código, portátil) / akios (skills que
  automatizam produzir e impor a Camada 1).
