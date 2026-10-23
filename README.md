# Prova pratica iDempiere

Implementacao de um fluxo de **Solicitacao de Compra** cobrindo todos os itens
obrigatorios e dois diferenciais da prova.

## O que esta implementado

| Item | Entrega |
|---|---|
| Tabela no Application Dictionary | `PROVA_Request`, criada pela migracao |
| Window / Tab / Field | Janela `Solicitacoes de Compra` |
| Callout | Calcula `GrandTotal = Qty * PriceEntered` |
| Model Validator | Valida valores e bloqueia edicao depois da aprovacao |
| Java Process | `ApproveRequest`, um `SvrProcess` |
| Relatorio nativo | Periodo e status, com Print Format proprio |
| Jasper | Mesmo filtro, layout paisagem e total geral |
| Event Handler | Delegate OSGi anotado registra a aprovacao no log |
| Plugin OSGi | Bundle, Declarative Services, feature e repositorio P2 |

O endpoint REST ficou fora do escopo por ser diferencial e depender da extensao
REST instalada na instancia. Os outros dois diferenciais ja estao presentes.

## Estrutura

```text
br.com.prova.idempiere/             plugin OSGi
br.com.prova.idempiere.feature/     feature instalavel
br.com.prova.idempiere.repository/  repositorio P2
migration/postgresql/               Application Dictionary e verificacao
docs/                               roteiro da apresentacao
scripts/                            utilitarios tecnicos de instalacao e diagnostico
```

## Pre-requisitos

- Docker Engine com Docker Compose;
- navegador web;
- Bash para os utilitarios de preparacao.

No fluxo Docker, Java, PostgreSQL e as bibliotecas do iDempiere ficam dentro
dos containers. Java 17, Maven 3.9 e um repositorio P2 local so sao necessarios
para a compilacao PDE/P2 alternativa, fora do fluxo Docker validado.

O bundle aceita `org.adempiere.base` da versao 12 ate antes da 15. Para outra
versao, ajuste o intervalo no `MANIFEST.MF` depois de validar as APIs.

## Ambiente local com Docker

O repositorio inclui um ambiente reproduzivel com iDempiere 13 e PostgreSQL 16.
Na primeira execucao, a imagem oficial cria e carrega o banco automaticamente:

```bash
docker compose up -d
docker compose ps
docker compose logs -f idempiere
```

Quando a inicializacao terminar, acesse:

```text
https://localhost:8443/webui/
```

O certificado e local, portanto o navegador pode exibir um aviso. Para a
administracao inicial use `System` / `System`; para os dados de demonstracao,
`GardenAdmin` / `GardenAdmin`. O PostgreSQL do container e publicado na porta
local `5433`, evitando conflito com uma instalacao local na porta `5432`.

Depois que a preparacao unica estiver concluida, estes sao os unicos comandos
necessarios para iniciar a apresentacao visual:

```bash
docker compose up -d
docker compose ps
```

Depois, todo o teste e feito em `https://localhost:8443/webui/`. Nao e
necessario executar scripts durante a apresentacao. O roteiro visual completo
esta em [docs/TUTORIAL_VISUAL.md](docs/TUTORIAL_VISUAL.md). A explicacao dos
conceitos Java, iDempiere e OSGi usados esta em
[docs/CONCEITOS_PARA_APRESENTACAO.md](docs/CONCEITOS_PARA_APRESENTACAO.md).

Os scripts restantes sao utilitarios para preparar uma maquina nova, recompilar
o plugin ou diagnosticar o ambiente; eles nao fazem parte da demonstracao.

Para reconstruir o bundle usando exatamente as bibliotecas do container:

```bash
bash scripts/build-plugin-in-container.sh
```

O JAR sera criado em `target/br.com.prova.idempiere_1.0.0.jar`. Para uma
instalacao manual, abra `https://localhost:8443/osgi/system/console/bundles`,
entre como `SuperUser` / `System`, escolha **Install/Update**, marque **Start
Bundle** e **Refresh Packages**, e use start level `2`. Esse nivel e necessario
porque a factory do Model Validator precisa estar registrada antes da carga dos
validadores ativos no banco.

Instale ou atualize o Application Dictionary e valide o ambiente com:

```bash
bash scripts/install-database.sh
bash scripts/verify-local.sh
```

Depois da primeira instalacao, entre como `System` e execute **Role Access
Update** com o campo Role vazio, sem marcar **Reset Existing Access**. No tenant
System a lista mostra apenas `System Administrator`; deixar o campo vazio
atualiza todas as roles nao manuais, incluindo `GardenWorld Admin`. Em seguida,
execute **Cache Reset** e faca um novo login.

## 1. Compilacao

Primeiro gere o repositorio P2 do checkout do iDempiere. Depois informe o
caminho absoluto ao Maven:

```bash
mvn -Didempiere.core.repository.url=file:///CAMINHO/idempiere/org.idempiere.p2/target/repository clean verify
```

O update site sera criado em:

```text
br.com.prova.idempiere.repository/target/repository
```

No ambiente Eclipse de desenvolvimento, tambem e possivel importar os tres
projetos e adicionar `br.com.prova.idempiere` a configuracao `server.product`.

## 2. Banco de dados

Faca backup do banco e execute como usuario da aplicacao:

```bash
psql -v ON_ERROR_STOP=1 -d idempiere \
  -f migration/postgresql/001_prova_request.sql
```

Valide a instalacao:

```bash
psql -d idempiere -f migration/postgresql/verify.sql
```

Resultado esperado: uma tabela, vinte colunas, uma janela, tres processos, um
Model Validator ativo, tres menus e o botao Aprovar configurado para aparecer
no formulario. A migracao pode ser executada novamente sem duplicar os
registros principais.

## 3. Deploy do plugin

Pare o servidor e instale a feature pelo mecanismo P2 usado na sua distribuicao
do iDempiere, apontando para
`br.com.prova.idempiere.repository/target/repository`. A unidade instalavel e:

```text
br.com.prova.idempiere.feature.feature.group
```

Em desenvolvimento, basta habilitar o bundle na configuracao de execucao. Em
ambos os casos, reinicie o servidor depois da instalacao para que o Model
Validator global seja carregado.

## 4. Teste funcional

1. Entre como `System`, execute **Cache Reset** e depois acesse o tenant de teste.
2. Abra **Solicitacoes de Compra**.
3. Crie um registro com documento, parceiro, quantidade e preco.
4. Confirme que o total muda ao editar quantidade ou preco.
5. Salve e clique em **Aprovar**.
6. Confirme que o status virou Aprovado e que a edicao foi bloqueada.
7. Rode os dois relatorios pelos menus criados.

Na imagem Docker usada aqui, os idiomas iniciais sao somente English e Español.
Selecione English; isso nao indica erro na instalacao.

