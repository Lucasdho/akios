# ALVA — Agent-Legible Vertical Architecture

> **Versão:** 0.1 (Draft)
> **Data:** 2026-06-30
> **Status:** Doutrina em consolidação — resultado de uma sessão de co-design.
> **Escopo:** Define (I) um padrão de arquitetura portátil, adotável por qualquer
> pessoa/time/ferramenta, e (II) como o **akios** operacionaliza esse padrão num
> workflow otimizado para agentes.

---

## 0. Por que este documento existe

Arquiteturas maduras — MVVM, MVVM-C, Clean Architecture — foram desenhadas
otimizando uma **função de custo humana**:

- memória de trabalho limitada → *separation of concerns*;
- coordenação de time → contratos e fronteiras rígidas;
- onboarding → convenções;
- mudança ao longo de anos → desacoplamento.

Agentes de IA conseguem *seguir* essas arquiteturas, mas elas **não foram pensadas
com agentes em mente**. O agente tem uma função de custo diferente, e nenhuma
arquitetura de aplicação foi formalizada nativamente em torno dela. Este documento
é a tentativa de fazer essa ponte: um padrão que IAs sigam com facilidade,
garantindo qualidade de código, sem jogar fora o que MVVM/Clean acertaram.

O nome de trabalho é **ALVA — Agent-Legible Vertical Architecture**.

---

## 0.1 O que já existe na indústria (posicionamento)

ALVA não nasce do vácuo. Ela é uma **síntese** de movimentos que já convergiam
desde ~2024–2025:

- **Spec-driven development** — GitHub *Spec Kit*, AWS *Kiro*, o padrão
  `specs/ → tasks/ → execution`.
- **AGENTS.md** — convenção cross-tool de mapa/regras para o agente
  (`CLAUDE.md`, `.cursorrules` são a mesma família).
- **Vertical Slice Architecture** (Jimmy Bogard) e **package-by-feature**.
- **Locality of Behaviour** — ensaio de Carson Gross (htmx); a peça teórica
  central, mesmo sem falar de IA.
- **Context engineering** — escritos da Anthropic sobre design de agentes.

Em termos de indústria, ALVA é: **Modular Monolith + Vertical Slices +
Clean-within-slice + SDD/TDD**. O que é **original** (e publicável como padrão
próprio) são dois pedaços, detalhados na Parte I:

1. **Promoção DRY automatizada por evidência**, com lifecycle (promoção *e*
   demoção) — a *Rule of Three* de Fowler transformada em métrica mecânica.
2. **Design-token thinking estendido ao código**, com gate de graduação e
   *Protocol-Oriented Programming* como métrica semântica.

---

# PARTE I — ALVA: o padrão portátil

> Esta parte não menciona nenhuma ferramenta específica. É adotável com git +
> qualquer editor + o build system da sua stack. É o "padrão" que pode ser
> publicado e seguido por quem não usa akios.

## 1. A função de custo

Toda decisão arquitetural em ALVA é avaliada contra uma única régua:

> **Minimizar tokens-até-uma-mudança-correta-e-verificável** — a quantidade de
> contexto que um agente precisa reunir para alterar algo com segurança **e provar
> que está certo**.

Enquanto arquiteturas clássicas otimizam cognição humana e coordenação de time,
ALVA otimiza **o custo de contexto por mudança**. Sempre que houver um trade-off,
ele é resolvido a favor de reduzir esse custo.

Corolário prático: o agente nunca deveria precisar carregar o repositório inteiro
(nem uma feature inteira alheia) para fazer uma mudança correta. O raio de contexto
de qualquer alteração deve ser **local e limitado**.

## 2. Por que as arquiteturas clássicas brigam com o agente

Três atritos concretos:

1. **Espalhamento por camada.** Uma feature em Clean vive em
   entity / usecase / repository / datasource / presenter / viewmodel / view —
   6 a 8 arquivos em diretórios distintos. O humano navega isso com o mapa mental;
   o agente precisa *carregar todos no contexto*. Custo de tokens explode e a
   chance de alucinação sobe.

2. **Abstração como indireção.** DRY foi feito para reduzir custo de manutenção
   humana. Mas cada abstração é um *hop* que o agente precisa rastrear. Existe um
   argumento real (e contra-intuitivo): **localidade > DRY** para código mantido
   por agente. Repetição consistente é mais barata para o agente do que uma
   abstração "esperta" que ele tem de perseguir por vários arquivos.

3. **Conhecimento que mora fora do código.** O humano pergunta para o time. O
   agente não. Se a decisão não está no código, no tipo ou num doc adjacente, ela
   **não existe** para o agente.

## 3. Os 7 princípios

Cada princípio é uma consequência direta da função de custo (§1).

### P1 — Localidade sobre camadas
Uma mudança de feature ≈ um diretório aberto. A separação estilo Clean vive
**dentro** do slice, não espalhada pelo projeto. Isso preserva testabilidade e
inversão de dependência, mas colapsa o raio de contexto para dentro de uma pasta.

### P2 — Convenção como compressão
Toda feature tem **exatamente a mesma forma**. O agente aprende a forma uma vez e a
reproduz sempre. Uniformidade > flexibilidade. É o traço mais agent-friendly de
toda a arquitetura: a estrutura repetida é, na prática, um *prompt* implícito.

### P3 — Fronteira por contrato, imposta pela toolchain
Uma feature importa apenas o **contrato público** (`contract/`) e a `Foundation/`
de outra — nunca os internos (`domain/`, `data/`) alheios. E essa fronteira é
**imposta pela ferramenta, não pela disciplina**: o build deve *recusar* compilar
o acesso indevido, em vez de apenas desencorajá-lo. Convenção que depende de
boa-vontade, o agente fura; parede física, não. (Realização por ecossistema:
Apêndice B.)

### P4 — Composição no topo
Apenas o topo do projeto conhece mais de uma feature. `Router/` resolve navegação
cross-feature; `Container/` injeta contratos entre features. Nenhuma feature
"conhece" outra diretamente — elas se encontram no ponto de composição.

### P5 — DRY por evidência, não por palpite
Código nasce dentro da feature. Só **gradua** para `Foundation/` quando há prova
mecânica de uso ≥ X (a *Rule of Three* automatizada). Abstração deixa de ser
julgamento e vira métrica — justamente onde o agente é fraco (julgar) é substituído
por onde ele é forte (executar uma decisão já tomada). Detalhe em §7.

### P6 — O ledger é ferramenta, não julgamento
A contagem de uso que dispara a promoção (P5) é **determinística** (produzida por
tooling), nunca estimada pelo agente. O agente apenas **lê** o resultado. Antes de
escrever um helper novo, consulta só a `Foundation/` (pequena e indexada) — nunca
o repositório inteiro. Detalhe em §7.4.

### P7 — Loop de verificação curto
Cada slice carrega, co-localizados, **a intenção e a prova**: uma spec (SDD) e
testes (TDD) ao lado do código. É o que fecha a função de custo — torna *barato
provar* que a mudança está certa, dando ao agente um feedback loop apertado.

## 4. Estrutura de pastas (referência)

```
Project/
  Router/                    → navegação (composição cross-feature)
  Container/                 → injeção de dependência
  Foundation/                → código graduado, compartilhado (ver §7)
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

Observações:

- `domain / data / presentation / tests` = Clean Architecture **dentro** do slice.
- `contract/` é o único ponto de acesso externo à feature (§5).
- `Feature-spec.md` é a spec da feature: contém a intenção **e** um cabeçalho
  declarando quais contratos e símbolos da `Foundation/` ela consome (útil para
  contagem barata e para checagem cruzada — §7.4, alternativa D).

## 5. Fronteira por contrato & composição cross-feature

O maior risco de vertical slices é o momento em que features precisam conversar. Se
mal resolvido, os slices enfiam a mão nas tripas uns dos outros e o acoplamento
fica **pior** que camadas. ALVA resolve com três ideias de DDD:

### 5.1 Bounded Context
O `User` visto por `Purchase` **não é** o mesmo `User` do Perfil. `Purchase` define
sua própria visão — ex.: `Buyer { id, nome, meioDePagamentoPadrão }` — com apenas
o que precisa. Isso é o *anti-corruption layer*: mudar os internos de `User` não
propaga, e o agente que mexe em `Purchase` nunca precisa do modelo completo de
`User`. Para agentes isso é especialmente valioso porque **limita o raio de
contexto**.

### 5.2 Contrato / Facade
Cada feature expõe uma interface pública estreita e tipada (`contract/`:
protocolo + DTOs). Todo o resto é interno. Comunicação cruzada passa **só** pelo
contrato. Quando o agente trabalha em `Purchase`, ele carrega: o slice de
`Purchase` inteiro + o `contract/` de `User` (pequeno). **Não** carrega a
implementação de `User`. O contrato é a **unidade de contexto entre slices**.

### 5.3 Composição no topo
`Container/` injeta o *contrato* de `User` dentro de `Purchase`; `Router/` resolve
navegação cross-feature. As features se encontram apenas ali.

### 5.4 Posse de tela (o exemplo "tela de compras do usuário")
Uma tela que envolve mais de um domínio pertence à feature cuja **intenção** ela
serve; consome as outras por contrato:

> A tela pertence à feature dona da **intenção**; ela consome as demais via
> `contract/`.

- "Minhas compras" → intenção é Compras → vive em `Purchase`, consome
  `User.contract`.
- "Perfil com compras recentes" → intenção é Perfil → vive em `User`, consome
  `Purchase.contract`.

Sinal de alarme: se um slice precisa importar o *interno* de outro para funcionar,
o contrato está errado (ou a fronteira está no lugar errado). O contrato deveria
bastar — e é a toolchain (P3) que obriga a manter isso honesto.

### 5.5 Dois problemas distintos
É importante não confundir:

| Problema | Solução em ALVA |
|---|---|
| Código *leaf* repetido (modifier, formatter) | Foundation / promoção (§7) |
| Feature A precisa do *domínio* da Feature B | Contrato / bounded context (§5) |

A `Foundation/` resolve **compartilhamento de folhas**; ela **não** resolve
composição de domínios. São mecanismos diferentes e ambos são necessários.

## 6. DRY por evidência — a mecânica da Foundation

Este é o coração original de ALVA. Em vez de abstrair por antecipação (o que gera
indireção cara para o agente), o código **prova que merece** ser compartilhado.

### 6.1 O ciclo de graduação
1. Código nasce **dentro** de uma feature.
2. Uma ferramenta determinística conta em quantas features distintas ele é usado.
3. Ao cruzar um threshold X, ele vira **candidato a promoção** para `Foundation/`.
4. A promoção é **sugerida** (não automática) e executada como uma tarefa revisável.
5. Se o uso cair abaixo de X (features removidas), ele é **candidato a demoção** —
   volta para a única feature que ainda usa, ou é removido.

Isso é a **Rule of Three** de Fowler ("não abstraia até ver 3 vezes"), só que
mecânica e medida — remove o julgamento humano/agente, que é a parte não confiável.

### 6.2 Duas gavetas: Design-tokens e Code-tokens
A `Foundation/` tem duas naturezas com **regras diferentes**, porque o risco de
compartilhá-las é diferente:

- **Design-tokens** — reutilização de itens **visuais**: componentes, view
  modifiers, utils e enums de UI. São **folha**: puros, sem dependências, blast
  radius ≈ zero. **Promova liberalmente**; threshold baixo (2 já serve).

- **Code-tokens** — **protocolos** (a espinha do design orientado a protocolo),
  além de helpers, casos de uso e serviços compartilhados. Carregam
  **comportamento e dependências**. Promover um serviço para compartilhado é
  declará-lo **domínio central**: bar alto, e ele sobe **atrás de um contrato**,
  não apenas "movido de pasta". Caso contrário, recria-se o `utils/`-lixão.

Regra derivada: **promover coisa pura é barato e bom; promover coisa com
comportamento é raro e passa por contrato.**

### 6.3 POP como métrica semântica
Colocar **protocolos** em Code-tokens não é só estético — torna a contagem
**semântica**. Para um protocolo, "uso" = número de **conformances**, não de
ocorrências textuais do nome (frágil). Ou seja: a escolha por *Protocol-Oriented
Programming* transforma a métrica de promoção de "quantas vezes esse nome aparece"
(impreciso) em "quantos tipos conformam a este protocolo" (exato e semântico).

### 6.4 O usage-ledger (requisito + implementação de referência)

**Requisito de arquitetura (portátil):** deve existir uma **contagem determinística
de uso, produzida por ferramenta**, e a promoção resultante é **sugerida**. O
agente **lê** o ledger; nunca conta na mão. Antes de criar um helper/protocolo
novo, o agente consulta **apenas** a `Foundation/` (busca *bounded*, barata), nunca
o repositório inteiro.

O princípio-chave: **o custo de investigação sai de *por-run-do-agente* (caro,
repetido) para *por-commit-determinístico* (barato, cacheado).** A investigação
some do contexto do agente.

**Como contar sem gastar tokens de investigação — alternativas** (da mais barata à
mais precisa; a implementação de referência pode combiná-las):

- **A — Contagem textual (git-hook + ripgrep).** Um pre-commit hook conta
  ocorrências dos símbolos da `Foundation/` pelos diretórios de feature e reescreve
  o ledger. Impreciso (colisão de nomes), mas trivial e determinístico. Bom para
  **provar o conceito** e *flaggar* candidatos.
- **B — Índice do compilador.** O build já produz um índice preciso de cada
  referência de símbolo (o mesmo que alimenta "Find Callers"). Um script consulta
  esse índice e responde exatamente "quantas features referenciam X" — e, para
  protocolos, "quantos conformam a X". Precisão semântica, zero token de agente.
  (Ferramentas OSS de *dead-code* já rodam sobre esse índice; reusa-se a engine
  para contar em vez de deletar.)
- **C — Grafo de módulos.** Se cada feature é uma unidade de fronteira (P3),
  "quem depende de `Foundation/X`" já está declarado nos manifests. Grátis, mas em
  granularidade de módulo (não de símbolo). Combina com B.
- **D — Declaração explícita.** Cada `Feature-spec.md` declara no cabeçalho o que
  consome. Contar = ler declarações (pequenas, estruturadas). Barato e legível;
  serve de checagem cruzada contra B (divergência = lint/bug).

**Recomendação:** começar em A, evoluir para B, cruzar com C/D. O mesmo hook que
conta para cima conta **para baixo** (lifecycle: promoção *e* demoção).

Formato do ledger (o artefato mínimo que entra no contexto do agente):

```json
{
  "generated": "2026-06-30T12:00:00Z",
  "candidates_promote": [
    {
      "symbol": "FormatCurrency",
      "kind": "helper",
      "features": ["Purchase", "Wallet", "Invoice"],
      "count": 3,
      "threshold": 3,
      "target": "Foundation/Code-tokens"
    }
  ],
  "candidates_demote": [
    {
      "symbol": "LegacyBadgeStyle",
      "kind": "designToken",
      "features": ["Profile"],
      "count": 1,
      "threshold": 2,
      "action": "return-to-feature"
    }
  ]
}
```

### 6.5 Por que "sugerida" e não "automática"
Promover para `Foundation/` é uma mudança de **blast radius alto** (vira dependência
de N features) e quase irreversível. Decisão dessas não deve acontecer
silenciosamente dentro de um run. A promoção sugerida:

- mantém o agente no papel que ele faz bem (executar uma promoção já decidida) e
  fora do que ele faz mal (julgar se "já é hora");
- transforma o ledger num **ponto de revisão** (humano ou gate);
- faz cada promoção ser uma **tarefa** rastreável como qualquer outra.

## 7. Verificação (TDD + SDD)

- **SDD:** cada feature tem uma `Feature-spec.md` co-localizada — a *intenção* ao
  lado do código, legível pelo agente sem sair do slice.
- **TDD:** cada feature tem `tests/` co-localizados — a *prova*.

Juntos fecham a função de custo: intenção + prova locais tornam barato para o
agente entender **e** verificar a mudança dentro do próprio slice.

## 8. O que é original em ALVA (resumo publicável)

1. **Promoção DRY automatizada por evidência**, com lifecycle completo (promoção
   *e* demoção) — Rule of Three virada métrica mecânica.
2. **Design-token thinking estendido ao código**, com gate de graduação e POP como
   métrica semântica de uso.

O restante é montagem deliberada de coisas que já funcionam (§0.1), reorganizadas
sob uma função de custo nova.

---

# PARTE II — ALVA + akios: o workflow otimizado

> Esta parte é a **implementação conforme** de ALVA no kit **akios** (Swift/iOS).
> Aqui moram as especificidades de ecossistema e o workflow de agentes.

## 9. Modelo mental

**ALVA é o padrão; akios é uma implementação otimizada do workflow do padrão.**
Alguém em outra stack implementa ALVA na mão ou com regras próprias; no akios ela
vem chave-na-mão, imposta e automatizada pelas skills e gates.

Critério da linha entre as camadas:

> **Camada 1 (ALVA):** tudo que é *verdade sobre o código* e pode ser adotado com
> git + editor + build system, sem akios.
> **Camada 2 (akios):** as skills/gates/pipeline que *automatizam produzir e impor*
> a Camada 1.

Regra de ouro do particionamento: **sempre que uma regra tiver cheiro de
ecossistema, o *conceito* sobe para ALVA e a *realização* desce para o akios.**

## 10. Especificidades Swift/iOS (descem para esta camada)

- **Unidade de fronteira (P3) = um local SPM module por feature.** Visibilidade
  imposta pelo compilador: `public` só o `contract/`, `internal` por padrão para o
  resto. É a realização Swift do princípio abstrato "fronteira imposta pela
  toolchain".
- **Code-tokens = protocolos Swift** (POP), com `internal`/`public` regulando a
  superfície. Contagem semântica = conformances via índice do compilador.
- **Design-tokens** = componentes SwiftUI, `ViewModifier`s, estilos, enums de UI.
- Demais especificidades (`@State`, modifiers, APIs de SDK) seguem a mesma regra:
  ficam aqui, nunca na Parte I.

## 11. Mapeamento skill → regra

| Regra ALVA | Skill / mecanismo akios |
|---|---|
| Doutrina como ground-truth versionada | Este doc em `specs/`, importado por `AGENTS.md` / `Context.md` |
| Carregar a doutrina antes de codar | `swift-dev` (guide com folder shape, contrato, Foundation) |
| Spec de feature declara contrato + símbolos Foundation consumidos | `idea-to-spec` (cabeçalho da Feature-spec) |
| Task impõe o shape do slice (`domain/data/presentation/tests/contract`) + passo "consultar Foundation antes de criar helper" | `spec-to-tasks` |
| Rodar o ledger no pre-commit; ler `usage-ledger.json`; regra "só Foundation, nunca repo inteiro"; sugestão de promoção → tarefa | `task-execution` |
| Disciplina de Design-tokens (folha visual) na fase de UI | `align-ui` |
| Ao mapear o app: features como slices, fronteiras de contrato, semear Foundation | `deep-brainstorm` |
| Construir o ledger tool (ripgrep → índice do compilador) | candidato `oss-first`; git-hook + `Foundation/usage-ledger.json` |
| Fronteira imposta pelo compilador | scaffold: um SPM module por feature |

## 12. O ledger no fluxo akios

- O git-hook/CI mantém `Foundation/usage-ledger.json` (Camada 1, tool-agnostic).
- `task-execution` **lê** o ledger; nunca conta.
- Cada entrada em `candidates_promote` / `candidates_demote` é transformada numa
  **tarefa** em `tasks/todo/` — o elo que só o akios fornece. A promoção continua
  sendo **sugerida**: vira backlog revisável, não mutação silenciosa.

## 13. Ordem de implementação (roadmap)

| # | Ação | Onde |
|---|---|---|
| 1 | Escrever a doutrina versionada (este doc) e importá-la | `specs/`, `AGENTS.md`/`Context.md` |
| 2 | Carregar a doutrina como guia de arquitetura | `swift-dev` |
| 3 | Construir o ledger tool (ripgrep → índice) — prova de conceito | `oss-first` + git-hook |
| 4 | Task shape impõe o slice + "consultar Foundation antes de criar helper" | `spec-to-tasks` |
| 5 | Execução roda o ledger, lê o resultado, gera tarefas de promoção | `task-execution` |
| 6 | Spec de feature declara contrato/Foundation | `idea-to-spec` |
| 7 | Disciplina de design-tokens na UI | `align-ui` |
| 8 | Mapear app como slices + semear Foundation | `deep-brainstorm` |

**Sequência recomendada:** 1 → 2 (a base precisa existir e ser carregável) → 3 (o
ledger, por ser o pedaço mais novo, precisa de PoC) → 4/5 (execução passa a seguir)
→ 6/7/8 (fases de design se alinham).

---

# Apêndices

## Apêndice A — Glossário

- **ALVA** — Agent-Legible Vertical Architecture. O padrão desta doutrina.
- **Função de custo** — tokens-até-uma-mudança-correta-e-verificável; a régua de
  toda decisão.
- **Slice / feature** — unidade vertical autocontida com sua própria estrutura
  Clean interna, contrato e spec.
- **Contract** — a interface pública (protocolo + DTOs) que outras features
  importam; a única superfície externa de um slice.
- **Foundation** — o diretório de código graduado/compartilhado, dividido em
  Design-tokens e Code-tokens.
- **Design-tokens** — reutilização visual folha (componentes, modifiers, utils/enums
  de UI).
- **Code-tokens** — protocolos (POP) + helpers/casos de uso/serviços compartilhados.
- **Promoção / demoção** — mover código para/da Foundation com base em evidência de
  uso.
- **usage-ledger** — o artefato determinístico de contagem de uso ("arquivo B").

## Apêndice B — Realização da fronteira por ecossistema (P3)

| Ecossistema | Unidade de fronteira |
|---|---|
| Swift | módulo / local package (SPM) |
| Kotlin/Android | módulo Gradle |
| TypeScript | package de workspace + `exports`, ou dependency-cruiser/ESLint boundaries |
| Rust | crate |
| Java/.NET | módulo/assembly + `internal` (ou ArchUnit) |
| Python (sem enforce nativo) | import-linter / architectural lint |

Degradê honesto: linguagem que não impõe no compilador cai para **lint de
arquitetura**. O princípio sobrevive; muda o executor.

## Apêndice C — Log de decisões

| # | Decisão | Escolha | Motivo | Alternativa rejeitada |
|---|---|---|---|---|
| D1 | Régua de decisão | Função de custo = tokens-até-mudança-correta-e-verificável | Agentes têm restrição diferente da humana; precisa de métrica própria | Otimizar cognição humana (status quo MVVM/Clean) |
| D2 | Organização macro | Vertical slices; Clean **dentro** do slice | Colapsa o raio de contexto por mudança | Package-by-layer (espalha feature por 6–8 dirs) |
| D3 | Uniformidade | Mesma estrutura em toda feature | Convenção = compressão; agente aprende a forma uma vez | Flexibilidade por feature |
| D4 | Fronteira entre features | Contrato + unidade imposta pela toolchain | Parede física > disciplina; agente não fura o que não compila | Convenção/documentação apenas |
| D4b | Nome da fronteira | Abstrair "SPM" → "unidade de fronteira imposta" | SPM é iOS-específico; ALVA precisa ser cross-stack | Fixar SPM na Camada 1 |
| D5 | Composição cross-feature | Router + Container no topo | Único lugar que conhece >1 feature; mantém slices ignorantes entre si | Features se referenciando direto |
| D6 | Posse de tela multi-domínio | Dona = feature da intenção; consome contratos | Evita duplicação e coupling; raio de contexto limitado | Tela "neutra" importando internos de várias features |
| D7 | DRY | Promoção por evidência (Rule of Three automatizada) | Remove julgamento (fraqueza do agente); vira métrica | Abstrair por antecipação (indireção cara) |
| D8 | Split da Foundation | Design-tokens (folha) vs Code-tokens (protocolos/comportamento) | Risco de compartilhar difere; bar de promoção difere | Uma pasta única `shared/` |
| D9 | Code-tokens = protocolos | POP | Contagem vira semântica (conformances), não textual | Helpers soltos sem contrato |
| D10 | Promoção de comportamento | Bar alto + atrás de contrato | Serviço compartilhado = domínio central; blast radius alto | Mover serviço "de pasta" livremente |
| D11 | Gatilho de promoção | **Sugerida**, não automática | Alto blast radius e ~irreversível; agente executa, não decide | Hook move código e reescreve imports sozinho |
| D12 | Lifecycle | Promoção **e** demoção | Sem demoção, Foundation vira cemitério (`utils/`-lixão) | Só contar para cima |
| D13 | Contagem | Ferramenta determinística (ripgrep → índice do compilador), fora do loop do agente | Custo de investigação vira per-commit cacheado, não per-run | Agente conta grepando o repo (caro, repetido) |
| D14 | Nome da gaveta de código | "Foundation" | "token" está triplamente carregado (design/LLM/léxico) | Manter "Code-tokens" como nome guarda-chuva |
| D15 | Estrutura do doc | Duas camadas separadas (ALVA portátil / ALVA+akios) | Torna ALVA publicável sozinha; akios é implementação conforme | Doc único acoplado ao akios |

## Apêndice D — Origem

Documento derivado de uma sessão de co-design (2026-06-30) sobre "arquitetura para
agentes": a ponte entre arquiteturas MVVM/Clean maduras e a realidade de código
mantido por IA. Versão inicial 0.1 — a consolidar contra `AGENTS.md` e specs
existentes do projeto antes de virar ground-truth executável.
