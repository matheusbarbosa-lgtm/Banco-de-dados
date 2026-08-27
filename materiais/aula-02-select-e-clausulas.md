# Aula 02. A instrução `SELECT` e suas cláusulas

**Disciplina:** Sistemas de Banco de Dados I. Sistemas de Informação. UNIPAM.
**Itens da ementa:** 4.3, consulta de recuperação básica em SQL. 1.1, características da abordagem de banco de dados.
**Referência:** ELMASRI, R. NAVATHE, S. *Sistemas de Banco de Dados*. 7. ed. São Paulo: Pearson. Capítulos 1 e 6.
**Ambiente:** PostgreSQL 17 em contêiner Docker, banco `bd_aula`, acessado pela extensão Database Client.
**Cenário:** tabela única `notas_alunos`, com 50 registros. Todo o código necessário está neste arquivo.

---

## Sumário

1. Objetivo
2. O minimundo
3. Sintaxe geral da instrução `SELECT`
4. Preparação do cenário
5. A cláusula `FROM`
6. A cláusula `SELECT`
7. Alias de coluna
8. A cláusula `ORDER BY`
9. A cláusula `LIMIT`
10. A cláusula `WHERE`
11. `GROUP BY` e funções de agregação
12. A ordem lógica de execução
13. Boas práticas consolidadas
14. Erros frequentes e leitura das mensagens
15. Script consolidado
16. Exercícios
17. Gabarito
18. Referências

---

## 1. Objetivo

O arquivo 01 percorreu o ciclo completo de um banco de dados sobre duas tabelas pequenas. Aquele percurso serviu para exibir o ciclo inteiro, não para fundamentar a linguagem de consulta. Este arquivo reconstrói a instrução `SELECT` sobre uma tabela única com volume suficiente para que o efeito de cada cláusula seja observável.

Ao final, os seguintes resultados devem estar assegurados.

| Resultado | Descrição |
|---|---|
| Minimundo | Reconhecer que a tabela representa um recorte da realidade, e saber descrever esse recorte |
| Projeção | A cláusula `SELECT` escolhe colunas e não altera a quantidade de linhas |
| Origem | A cláusula `FROM` determina quais linhas e quais nomes de coluna existem |
| Filtro | A cláusula `WHERE` escolhe linhas, uma a uma, por uma condição |
| Ordenação e recorte | As cláusulas `ORDER BY` e `LIMIT` organizam e recortam o resultado |
| Agrupamento | A cláusula `GROUP BY` reduz um conjunto de linhas a um valor por grupo |
| Ordem de execução | A ordem em que as cláusulas são escritas não é a ordem em que são avaliadas |
| Boas práticas | Justificar cada escolha de escrita, e não apenas reproduzi-la |

O penúltimo resultado é o mais importante do arquivo. Ele explica o comportamento de todas as cláusulas acrescentadas nos arquivos seguintes, e sua ausência é a causa mais frequente de erro na escrita de consultas.

### 1.1 Delimitação

Uma tabela única foi escolhida por decisão pedagógica: enquanto houver uma só origem de dados, nenhuma junção é possível e nenhuma é necessária, e a atenção permanece sobre a instrução em estudo.

Os assuntos abaixo aparecem citados neste arquivo, mas não são tratados aqui.

| Assunto | Onde é tratado |
|---|---|
| Operadores aritméticos e expressões na lista de colunas | Arquivo 03 |
| `IN`, `BETWEEN`, `LIKE`, `IS NULL`, `OR` e `NOT` | Arquivo 03 |
| `DISTINCT`, ordenação por várias colunas, `OFFSET` | Arquivo 03 |
| Demais funções de agregação e a cláusula `HAVING` | Arquivo 03 |
| Esquema e instância, tratamento formal | Arquivo 15 |
| Junção de tabelas | Arquivo 23 |
| Subconsultas | Arquivo 25 |

---

## 2. O minimundo

### 2.1 Dado, informação e banco de dados

Um **dado** é um fato conhecido que pode ser registrado e que possui significado implícito. O número `85` é um dado. Isolado, ele não informa nada: pode ser uma nota, uma idade ou um preço.

Um dado passa a produzir **informação** quando se sabe a que ele se refere. `85` como nota do Aluno 01 em Matematica, na avaliação de 1º de setembro, informa alguma coisa, porque está ligado a um contexto que lhe dá sentido.

Um **banco de dados** é uma coleção de dados relacionados. A definição do livro-texto acrescenta três propriedades implícitas, e nenhuma delas é dispensável.

| Propriedade | Significado |
|---|---|
| Representa um minimundo | O conteúdo do banco corresponde a um recorte da realidade, e mudanças naquele recorte precisam se refletir no banco |
| É logicamente coerente | Os dados guardam relação entre si e formam um conjunto com sentido próprio, não uma coleção aleatória |
| Tem propósito e público | O banco é projetado, construído e povoado para um grupo de usuários e um conjunto de aplicações previamente definido |

O **minimundo**, também chamado de **universo de discurso**, é a parte da realidade que o banco se propõe a representar. Ele é sempre menor do que a realidade, e essa redução é deliberada.

Descrever o minimundo é enunciar, em linguagem natural, o que existe naquele recorte, quais são as regras que o governam e o que ficou de fora. Essa descrição precede o modelo, que precede o esquema, que precede a primeira linha de SQL.

### 2.2 O minimundo desta aula

O recorte adotado é o **registro de avaliações de uma instituição de ensino**.

Regras do minimundo, enunciadas em linguagem natural:

1. A instituição oferece disciplinas.
2. Os alunos são reunidos em turmas. Cada aluno pertence a uma turma.
3. Cada aluno cursa disciplinas e, em cada uma delas, realiza avaliações.
4. Cada avaliação produz uma nota, na escala de 0 a 100, e ocorre em uma data.
5. As faltas do aluno na disciplina são registradas junto com a avaliação.

Toda coluna da tabela existe por causa de uma dessas regras. Nenhuma coluna foi criada porque parecia útil.

### 2.3 Entidade, atributo e relacionamento

Três termos aparecem toda vez que um minimundo é descrito. O tratamento formal deles ocorre nos arquivos de modelagem conceitual, do 17 ao 22, e convém fixá-los desde já.

| Termo | Definição | No minimundo desta aula |
|---|---|---|
| Entidade | Uma coisa do mundo real, com existência independente, sobre a qual se deseja guardar dados | Um aluno. Uma disciplina. Uma turma |
| Atributo | Uma propriedade que descreve uma entidade | O nome do aluno. A turma a que ele pertence |
| Relacionamento | Uma associação entre entidades | Um aluno **é avaliado em** uma disciplina |

A avaliação é o relacionamento entre aluno e disciplina. Ela não é uma coisa que exista sozinha no mundo: não há avaliação sem um aluno e sem uma disciplina. E, ainda assim, tem atributos próprios, a nota, as faltas e a data, que não pertencem nem ao aluno nem à disciplina isoladamente, e sim à associação entre os dois.

Uma linha da tabela `notas_alunos` é uma avaliação. As colunas `aluno_nome` e `turma` descrevem o aluno, a coluna `disciplina` nomeia a disciplina, e as colunas `nota`, `faltas` e `data_avaliacao` descrevem a avaliação em si.

### 2.4 O recorte: o que ficou de fora

Um minimundo se define tanto pelo que inclui quanto pelo que exclui. Nesta aula ficaram de fora, por decisão explícita:

- **O professor.** Não se sabe quem avaliou.
- **O identificador do aluno.** Existe apenas o nome.
- **As tabelas de aluno, de turma e de disciplina.** Existem os nomes escritos em cada linha, mas não existe um lugar onde esses nomes estejam definidos uma única vez.
- **Os critérios de aprovação.** A nota é registrada, e nada no banco diz o que significa ser aprovado.
- **O período letivo.** Existe a data de cada avaliação, e nada que agrupe as avaliações em um semestre.

### 2.5 O que a tabela não consegue distinguir

As exclusões da seção anterior têm três consequências concretas, e todas as três são verificáveis sobre os dados.

**Dois alunos de mesmo nome seriam a mesma pessoa.** Como não há identificador do aluno, nada distingue duas pessoas chamadas `Maria Silva`. A coluna `id` identifica a **linha**, isto é, a avaliação, e não o aluno.

**A mesma disciplina pode ser gravada de duas formas.** A coluna `disciplina` é texto livre. Nada impede que uma linha registre `'Matematica'` e outra `'matematica'`, e o SGBD as trataria como duas disciplinas distintas. Um agrupamento por disciplina passaria a devolver quatro linhas onde deveria devolver três.

**A turma do aluno está repetida em cada avaliação.** A turma é um atributo do aluno, e está gravada em toda linha em que aquele aluno aparece. Neste conjunto de dados cada aluno tem exatamente uma avaliação, o que esconde o problema. Bastaria que o Aluno 01 fosse avaliado em uma segunda disciplina para que a letra `A` aparecesse duas vezes, e nada garantiria que fosse a mesma letra nas duas linhas.

Esse último ponto se chama **redundância**, e o comportamento indesejado que ela provoca se chama **anomalia**. A tabela é intencionalmente mantida nessa forma, porque reproduz o que costuma sair de uma planilha, que é a origem real da maior parte dos dados que chegam a um banco. O tratamento formal do problema é a normalização, itens 8.1 a 8.4, arquivos 33 a 36.

### 2.6 Vocabulário

| Termo | Significado |
|---|---|
| Minimundo | O recorte da realidade que o banco representa |
| Esquema | A descrição da estrutura do banco, que muda raramente |
| Instância | O conteúdo do banco em um dado momento, que muda a cada operação |
| Entidade | Coisa do mundo real sobre a qual se guardam dados |
| Atributo | Propriedade que descreve uma entidade |
| Relacionamento | Associação entre entidades |
| Domínio | O conjunto de valores que uma coluna admite |
| Redundância | O mesmo dado armazenado em mais de um lugar |
| Anomalia | Comportamento indesejado que a redundância provoca ao inserir, alterar ou remover dados |

A distinção entre esquema e instância é o item 2.1 da ementa e recebe tratamento próprio no arquivo 15. Por ora basta reter que `CREATE TABLE` define esquema e `INSERT` altera instância.

---

## 3. Sintaxe geral da instrução `SELECT`

Toda consulta de recuperação em SQL tem a forma abaixo. Os colchetes indicam cláusulas opcionais e não fazem parte da sintaxe.

```
SELECT <lista de colunas>
FROM   <tabela>
[WHERE <condicao sobre cada linha>]
[GROUP BY <colunas de agrupamento>]
[HAVING <condicao sobre cada grupo>]
[ORDER BY <colunas de ordenacao> [ASC | DESC]]
[LIMIT <quantidade de linhas>];
```

Cada cláusula responde a uma pergunta distinta.

| Cláusula | Pergunta que responde | Obrigatória | Tratada em |
|---|---|---|---|
| `SELECT` | Quais colunas o resultado deve conter | Sim | Seções 6 e 7 |
| `FROM` | De onde vêm as linhas | Sim, na prática | Seção 5 |
| `WHERE` | Quais linhas interessam | Não | Seção 10 |
| `GROUP BY` | Como as linhas se reúnem em grupos | Não | Seção 11 |
| `HAVING` | Quais grupos interessam | Não | Arquivo 03 |
| `ORDER BY` | Em que ordem o resultado é apresentado | Não | Seção 8 |
| `LIMIT` | Quantas linhas do resultado são exibidas | Não | Seção 9 |

A ordem em que as cláusulas são escritas é fixa. Escrever `ORDER BY` antes de `WHERE` produz erro de sintaxe, ainda que o sentido pretendido seja claro para quem lê.

---

## 4. Preparação do cenário

### 4.1 A estrutura da tabela

Cada linha da tabela registra a nota obtida por um aluno em uma disciplina, em uma avaliação.

| Coluna | Tipo | Obrigatória | Representa |
|---|---|---|---|
| `id` | `INTEGER` | Sim | Identificador da linha, gerado pelo SGBD |
| `aluno_nome` | `TEXT` | Sim | Nome do aluno |
| `turma` | `TEXT` | Sim | Turma à qual o aluno pertence |
| `disciplina` | `TEXT` | Sim | Disciplina avaliada |
| `nota` | `INTEGER` | Sim | Nota obtida, na escala de 0 a 100 |
| `faltas` | `INTEGER` | Sim | Quantidade de faltas registradas |
| `data_avaliacao` | `DATE` | Sim | Data em que a avaliação ocorreu |

O tipo de uma coluna declara o seu **domínio**, isto é, o conjunto de valores que ela admite. Declarar `nota` como `INTEGER` garante que nenhum texto entre naquela coluna. O SGBD recusa a inserção antes de gravá-la.

O tipo `TEXT` é adotado nas colunas de texto porque nenhuma regra do domínio estabelece comprimento máximo para um nome de aluno. Um limite arbitrário como `VARCHAR(50)` seria uma restrição inventada, e restrições inventadas rejeitam dados legítimos: o primeiro aluno com nome de 51 caracteres teria a matrícula recusada por um limite que ninguém decidiu. O critério de escolha entre `TEXT` e `VARCHAR(n)` é tratado no arquivo 05.

O tipo `INTEGER` na coluna `nota` é uma decisão do minimundo, e não uma conveniência. Ele declara que as notas desta instituição não têm casa decimal. Se o regulamento admitisse `7.5`, o tipo teria de ser `NUMERIC`.

### 4.2 A conexão

A extensão Database Client identifica a conexão pela primeira linha do arquivo, no formato abaixo.

```sql
-- Active: 1787177433004@@127.0.0.1@5432@bd_aula@public
```

O número inicial é o identificador local da conexão e varia de máquina para máquina. Os campos seguintes são servidor, porta, banco e esquema. Quando a linha estiver ausente ou apontar para outro banco, a extensão executa o comando na conexão selecionada no painel lateral, e a tabela pode acabar criada no lugar errado. O comando não falha, e o engano só aparece depois.

Antes de executar qualquer comando, confirmar que a conexão ativa é `bd_aula` no esquema `public`.

### 4.3 Criação da tabela

```sql
DROP TABLE IF EXISTS notas_alunos;

CREATE TABLE notas_alunos(
    id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    aluno_nome TEXT NOT NULL,
    turma TEXT NOT NULL,
    disciplina TEXT NOT NULL,
    nota INTEGER NOT NULL,
    faltas INTEGER NOT NULL,
    data_avaliacao DATE NOT NULL
);
```

Cada elemento da instrução tem uma finalidade própria, e nenhum deles é decorativo.

| Elemento | Finalidade |
|---|---|
| `DROP TABLE IF EXISTS` | Remove a tabela caso ela já exista |
| `CREATE TABLE notas_alunos` | Declara o nome da tabela. É por esse nome que a cláusula `FROM` a encontrará |
| `id INTEGER` | Declara uma coluna chamada `id`, cujo domínio é o dos números inteiros |
| `GENERATED ALWAYS AS IDENTITY` | Transfere ao SGBD a responsabilidade de produzir o valor de `id` a cada inserção |
| `PRIMARY KEY` | Declara que essa coluna identifica a linha de modo único e que seu valor nunca é nulo |
| `TEXT` | Domínio de cadeias de caracteres de comprimento não limitado |
| `INTEGER` | Domínio de números inteiros, adequado a `nota` e a `faltas` |
| `DATE` | Domínio de datas de calendário, com dia, mês e ano |
| `NOT NULL` | Impede que a coluna receba a ausência de valor |

Quatro desses elementos merecem tratamento à parte.

**`DROP TABLE IF EXISTS` torna o script reexecutável.** A cláusula `IF EXISTS` evita a falha que ocorreria na primeira execução, quando não há o que remover. Sem ela, o script funcionaria uma vez e falharia em todas as seguintes. Com ela, executá-lo duas vezes produz o mesmo resultado que executá-lo uma vez, e a estrutura obtida é sempre a que está escrita no arquivo.

**`GENERATED ALWAYS AS IDENTITY` é a forma da norma.** Ela substitui o tipo `SERIAL`, que é uma extensão particular do PostgreSQL. As duas produzem o mesmo efeito prático, que é gerar o valor da chave a cada inserção, e diferem no que acontece quando alguém informa o valor manualmente: `SERIAL` aceita, a sequência interna continua no número antigo, e a próxima inserção automática falha por chave duplicada, longe da causa. `GENERATED ALWAYS` recusa no ato, com `cannot insert a non-DEFAULT value into column "id"`. O assunto retorna no arquivo 11.

**`PRIMARY KEY` identifica a linha, e não o aluno.** A chave primária garante que duas linhas nunca terão o mesmo `id`. Ela não diz nada sobre o aluno, conforme a seção 2.5.

**`NOT NULL` declara obrigatoriedade.** Uma avaliação sem nota, sem disciplina ou sem data não é um registro incompleto que o banco deva tolerar, é um registro que não representa nada. A restrição é a tradução, em SQL, de uma regra que já existia no minimundo. O tratamento formal das restrições ocorre nos arquivos 10 e 11.

O nome da tabela e o de todas as colunas estão em minúsculas, sem acento, com palavras separadas por sublinhado. Essa convenção não é estética: ela evita a necessidade de aspas duplas em toda referência futura, pelo motivo detalhado na seção 7.

### 4.4 A tabela vazia: esquema e instância

Convém consultar a tabela recém-criada antes de qualquer inserção.

```sql
SELECT * FROM notas_alunos;
```

O resultado é uma tabela vazia, com sete colunas e nenhuma linha. Esse resultado não é um erro, e demonstra a distinção que a seção 2.6 apresentou como vocabulário.

O **esquema** da tabela existe a partir do `CREATE TABLE`: os sete nomes de coluna, os sete domínios e as restrições estão definidos, e podem ser consultados. A **instância** só existe a partir do `INSERT`. Uma tabela sem linhas é uma tabela válida, com esquema completo e instância vazia.

### 4.5 Carga dos dados

```sql
INSERT INTO notas_alunos (aluno_nome, turma, disciplina, nota, faltas, data_avaliacao) VALUES
('Aluno 01','A','Matematica', 85, 2, '2025-09-01'),
('Aluno 02','A','Matematica', 72, 0, '2025-09-01'),
('Aluno 03','A','Matematica', 90, 1, '2025-09-01'),
('Aluno 04','A','Matematica', 60, 3, '2025-09-01'),
('Aluno 05','A','Matematica', 55, 0, '2025-09-01'),
('Aluno 06','B','Matematica', 78, 2, '2025-09-02'),
('Aluno 07','B','Matematica', 88, 1, '2025-09-02'),
('Aluno 08','B','Matematica', 95, 0, '2025-09-02'),
('Aluno 09','B','Matematica', 47, 4, '2025-09-02'),
('Aluno 10','B','Matematica', 68, 2, '2025-09-02'),
('Aluno 11','C','Portugues', 74, 1, '2025-09-03'),
('Aluno 12','C','Portugues', 81, 0, '2025-09-03'),
('Aluno 13','C','Portugues', 66, 2, '2025-09-03'),
('Aluno 14','C','Portugues', 59, 3, '2025-09-03'),
('Aluno 15','C','Portugues', 90, 0, '2025-09-03'),
('Aluno 16','A','Portugues', 85, 0, '2025-09-04'),
('Aluno 17','A','Portugues', 77, 1, '2025-09-04'),
('Aluno 18','A','Portugues', 92, 0, '2025-09-04'),
('Aluno 19','A','Portugues', 45, 5, '2025-09-04'),
('Aluno 20','A','Portugues', 69, 2, '2025-09-04'),
('Aluno 21','B','Sistemas', 88, 0, '2025-09-05'),
('Aluno 22','B','Sistemas', 78, 2, '2025-09-05'),
('Aluno 23','B','Sistemas', 83, 1, '2025-09-05'),
('Aluno 24','B','Sistemas', 91, 0, '2025-09-05'),
('Aluno 25','B','Sistemas', 55, 3, '2025-09-05'),
('Aluno 26','C','Sistemas', 66, 2, '2025-09-06'),
('Aluno 27','C','Sistemas', 72, 1, '2025-09-06'),
('Aluno 28','C','Sistemas', 79, 0, '2025-09-06'),
('Aluno 29','C','Sistemas', 84, 0, '2025-09-06'),
('Aluno 30','C','Sistemas', 90, 0, '2025-09-06'),
('Aluno 31','A','Matematica', 82, 1, '2025-09-07'),
('Aluno 32','A','Matematica', 74, 2, '2025-09-07'),
('Aluno 33','B','Portugues', 69, 1, '2025-09-07'),
('Aluno 34','B','Portugues', 71, 0, '2025-09-07'),
('Aluno 35','C','Matematica', 95, 0, '2025-09-08'),
('Aluno 36','C','Matematica', 58, 4, '2025-09-08'),
('Aluno 37','A','Sistemas', 63, 2, '2025-09-08'),
('Aluno 38','A','Sistemas', 77, 1, '2025-09-08'),
('Aluno 39','B','Sistemas', 85, 0, '2025-09-09'),
('Aluno 40','B','Sistemas', 49, 5, '2025-09-09'),
('Aluno 41','C','Portugues', 88, 0, '2025-09-09'),
('Aluno 42','C','Portugues', 82, 1, '2025-09-09'),
('Aluno 43','A','Matematica', 70, 2, '2025-09-10'),
('Aluno 44','A','Matematica', 68, 3, '2025-09-10'),
('Aluno 45','B','Portugues', 95, 0, '2025-09-10'),
('Aluno 46','B','Portugues', 52, 4, '2025-09-10'),
('Aluno 47','C','Sistemas', 76, 1, '2025-09-11'),
('Aluno 48','C','Sistemas', 89, 0, '2025-09-11'),
('Aluno 49','A','Sistemas', 94, 0, '2025-09-11'),
('Aluno 50','B','Matematica', 61, 2, '2025-09-11');
```

Três pontos merecem comentário nesta instrução.

**A lista de colunas está escrita.** Seria possível omiti-la e informar apenas os valores, na ordem em que as colunas foram definidas. Escrevê-la custa uma linha e protege contra a alteração futura da tabela: acrescentar uma coluna não quebra um `INSERT` que nomeia as suas colunas, e quebra silenciosamente um que dependa da posição.

**A coluna `id` não aparece na lista.** Seu valor é gerado pelo SGBD, conforme a seção 4.3. Tentar informá-la produz `cannot insert a non-DEFAULT value into column "id"`.

**Textos e datas vão entre aspas simples, números não.** `'Aluno 01'` e `'2025-09-01'` são valores de texto e de data. `85` e `2` são números, e aspas em torno deles fariam o PostgreSQL converter texto para número a cada linha, sem necessidade. A data segue o formato `AAAA-MM-DD`, que é o da norma ISO 8601 e não depende da configuração regional do servidor.

A ferramenta deve informar `INSERT 0 50`. Qualquer outro número indica que o comando não foi copiado por inteiro, e nesse caso o script deve ser executado novamente desde o `DROP TABLE`.

### 4.6 Conferência

```sql
SELECT * FROM notas_alunos;
```

O resultado agora tem **50 linhas** e sete colunas. Primeiras linhas:

| id | aluno_nome | turma | disciplina | nota | faltas | data_avaliacao |
|---|---|---|---|---|---|---|
| 1 | Aluno 01 | A | Matematica | 85 | 2 | 2025-09-01 |
| 2 | Aluno 02 | A | Matematica | 72 | 0 | 2025-09-01 |
| 3 | Aluno 03 | A | Matematica | 90 | 1 | 2025-09-01 |
| 4 | Aluno 04 | A | Matematica | 60 | 3 | 2025-09-01 |
| 5 | Aluno 05 | A | Matematica | 55 | 0 | 2025-09-01 |

Composição do conjunto, útil para conferir os exercícios:

| Grandeza | Valor |
|---|---|
| Linhas | 50 |
| Alunos distintos | 50, um por linha |
| Disciplinas distintas | 3 |
| Turmas distintas | 3 |
| Avaliações de `Matematica` | 17 |
| Avaliações de `Sistemas` | 17 |
| Avaliações de `Portugues` | 16 |
| Avaliações da turma `A` | 17 |
| Avaliações da turma `B` | 17 |
| Avaliações da turma `C` | 16 |
| Alunos com zero faltas | 19 |
| Maior nota, `95` | 3 alunos |
| Menor nota, `45` | 1 aluno |

A segunda linha da tabela é a que revela a limitação descrita na seção 2.5: cada aluno aparece uma única vez, e portanto este conjunto de dados não exibe a redundância que o esquema permite.

---

## 5. A cláusula `FROM`

A cláusula `FROM` indica a origem das linhas. Ela é avaliada antes de qualquer outra cláusula, e é ela que determina quais nomes de coluna existem para o restante da consulta. Um nome que não pertença à tabela indicada em `FROM` não pode ser usado em nenhuma outra cláusula.

### 5.1 O asterisco

```sql
SELECT * FROM notas_alunos;
```

O asterisco significa "todas as colunas da origem, na ordem em que foram definidas". É conveniente durante a exploração de uma tabela desconhecida, e inadequado em código permanente por dois motivos.

1. O conjunto de colunas retornado muda sozinho quando a tabela é alterada, e uma aplicação que dependia da posição das colunas passa a receber outro resultado sem que nenhuma linha de código tenha mudado.
2. O comando deixa de documentar o que a consulta pretende obter. Quem lê `SELECT *` não sabe se todas as colunas são necessárias ou se ninguém se deu ao trabalho de escolher.

**Regra de boa prática:** usar o asterisco para inspecionar, e listar as colunas explicitamente para tudo o mais.

### 5.2 A origem determina os nomes disponíveis

```sql
SELECT sobrenome FROM notas_alunos;
```

```
ERROR:  column "sobrenome" does not exist
```

A mensagem nomeia exatamente o que faltou. Não existe coluna `sobrenome` na tabela indicada em `FROM`, e portanto o nome não pode ser usado. A conferência mais rápida é executar `SELECT * FROM notas_alunos` e ler o cabeçalho.

---

## 6. A cláusula `SELECT`

A cláusula `SELECT` recebe a lista das colunas que o resultado deve conter. Essa operação chama-se **projeção**.

### 6.1 Projeção

```sql
SELECT
    aluno_nome,
    turma,
    disciplina,
    nota
FROM
    notas_alunos;
```

Primeiras linhas do resultado:

| aluno_nome | turma | disciplina | nota |
|---|---|---|---|
| Aluno 01 | A | Matematica | 85 |
| Aluno 02 | A | Matematica | 72 |
| Aluno 03 | A | Matematica | 90 |
| Aluno 04 | A | Matematica | 60 |
| Aluno 05 | A | Matematica | 55 |

**A projeção não altera a quantidade de linhas.** O resultado continua com 50 linhas. A cláusula `SELECT` opera sobre a largura da tabela, não sobre a sua altura. Reduzir o número de linhas é tarefa da cláusula `WHERE`, tratada na seção 10.

### 6.2 A ordem das colunas

**A ordem das colunas no resultado é a ordem da lista.** A coluna `id` desapareceu porque não foi listada, e não porque tenha deixado de existir na tabela. A consulta abaixo produz as mesmas informações em outra disposição.

```sql
SELECT
    nota,
    disciplina,
    aluno_nome
FROM
    notas_alunos;
```

A escolha da ordem é uma decisão de apresentação. Colocar primeiro a coluna sobre a qual o leitor vai procurar, e por último a que ele vai ler, costuma tornar o resultado mais utilizável.

### 6.3 A projeção não elimina repetições

```sql
SELECT
    turma,
    disciplina
FROM
    notas_alunos;
```

O resultado tem **50 linhas**, e a maior parte delas é idêntica a outra. A combinação `A` com `Matematica`, por exemplo, aparece nove vezes.

Isso não é um defeito da consulta. Uma tabela em SQL é um **multiconjunto**, isto é, uma coleção que admite elementos repetidos, e o resultado de uma consulta também. A relação da teoria do modelo relacional é um conjunto, e não admite repetição. A diferença entre os dois é um dos pontos em que a SQL se afasta da teoria que a fundamenta, e é tratada no arquivo 09.

Eliminar as repetições do resultado é tarefa da cláusula `DISTINCT`, tratada no arquivo 03.

---

## 7. Alias de coluna

Um **alias** é um nome temporário atribuído a uma coluna ou expressão no resultado da consulta. Ele existe apenas no resultado e não altera a tabela. A palavra reservada `AS` introduz o alias.

```sql
SELECT
    aluno_nome AS aluno,
    nota AS nota_final
FROM
    notas_alunos;
```

O cabeçalho do resultado passa a exibir `aluno` e `nota_final`. A tabela continua com as colunas `aluno_nome` e `nota`, e a consulta seguinte terá de usar os nomes originais.

O PostgreSQL aceita omitir a palavra `AS` e escrever `aluno_nome aluno`. **Regra de boa prática:** escrever `AS` sempre. Sem ela, uma vírgula esquecida entre duas colunas transforma a segunda em alias da primeira, o comando não falha, e o resultado tem uma coluna a menos do que o esperado.

### 7.1 Alias com acento, espaço ou maiúscula

O PostgreSQL converte todo identificador não delimitado para minúsculas e não aceita acentos ou espaços nele. Para que o cabeçalho do resultado apresente um rótulo com acentuação ou com maiúsculas preservadas, o alias precisa ser delimitado por aspas duplas.

```sql
SELECT
    disciplina AS "Português",
    aluno_nome,
    nota
FROM
    notas_alunos;
```

### 7.2 Aspas simples e aspas duplas

A distinção entre os dois tipos de aspas é uma das principais fontes de erro no início do estudo de SQL, e vale fixá-la antes de prosseguir.

| Delimitador | Significado | Exemplo |
|---|---|---|
| Aspas simples | Um **valor** do tipo texto ou data | `WHERE disciplina = 'Matematica'` |
| Aspas duplas | Um **identificador**, isto é, o nome de uma tabela, de uma coluna ou de um alias | `AS "Português"` |

Trocar um pelo outro produz erro. Escrever `WHERE disciplina = "Matematica"` faz o PostgreSQL procurar uma coluna chamada `Matematica` e responder `column "Matematica" does not exist`. Escrever `AS 'Português'` produz erro de sintaxe, porque um valor de texto não pode nomear uma coluna do resultado.

A regra tem uma formulação curta que vale memorizar: **aspas simples cercam dados, aspas duplas cercam nomes**.

### 7.3 Aspas duplas no alias e aspas duplas no esquema

O uso de aspas duplas em um alias é legítimo, porque o alias é um rótulo de apresentação e desaparece com o resultado. O uso de aspas duplas ao nomear tabelas e colunas na definição do esquema é outra coisa, e deve ser evitado: um nome delimitado por aspas passa a exigir aspas em toda referência futura, e a omissão delas produz o erro observado no arquivo 01, quando `c.id_Curso` foi convertido para `c.id_curso` pelo próprio PostgreSQL. O tratamento completo do assunto está em `referencia/04-boas-praticas-sql.md`.

**Regra de boa prática:** identificadores em minúsculas, sem acento, com palavras separadas por sublinhado, nunca delimitados por aspas. Aspas duplas ficam reservadas a aliases de apresentação.

---

## 8. A cláusula `ORDER BY`

Sem `ORDER BY`, o SGBD não garante ordem alguma no resultado. A ordem observada é consequência do modo como as linhas foram lidas do disco, e pode mudar de uma execução para outra sem que nada tenha sido alterado na tabela. Quando a ordem importa, ela precisa ser pedida.

### 8.1 `ASC` e `DESC`

```sql
SELECT
    nota,
    disciplina,
    aluno_nome
FROM
    notas_alunos
ORDER BY
    nota DESC;
```

O modificador `DESC` ordena do maior para o menor. O modificador `ASC` ordena do menor para o maior e é o padrão: escrever `ORDER BY nota` equivale a escrever `ORDER BY nota ASC`.

Primeiras linhas do resultado:

| nota | disciplina | aluno_nome |
|---|---|---|
| 95 | Matematica | Aluno 08 |
| 95 | Matematica | Aluno 35 |
| 95 | Portugues | Aluno 45 |
| 94 | Sistemas | Aluno 49 |
| 92 | Portugues | Aluno 18 |
| 91 | Sistemas | Aluno 24 |

O critério de ordenação depende do tipo da coluna. Números são comparados por valor, datas por ordem cronológica, e textos pela ordem de agrupamento do banco, que em geral corresponde à ordem alfabética. Ordenar por `nota` como se fosse texto colocaria `100` antes de `9`, o que é mais um motivo para que o tipo da coluna corresponda ao domínio real.

### 8.2 Empates

Três alunos obtiveram nota 95. A cláusula `ORDER BY nota DESC` determina que os três apareçam antes de qualquer nota menor, e nada determina sobre a ordem **entre** eles. Um empate deixa a ordem indefinida, exatamente como a ausência de `ORDER BY` deixa indefinida a ordem do resultado inteiro.

**Regra de boa prática:** quando o desempate importa, declará-lo como segundo critério de ordenação. A ordenação por várias colunas é tratada no arquivo 03.

---

## 9. A cláusula `LIMIT`

A cláusula `LIMIT` restringe a quantidade de linhas exibidas. Ela é avaliada por último, depois da ordenação, e por isso a combinação `ORDER BY` seguido de `LIMIT` é a forma usual de obter os primeiros colocados de um critério.

```sql
SELECT
    nota,
    disciplina,
    aluno_nome
FROM
    notas_alunos
ORDER BY
    nota DESC
LIMIT
    10;
```

Resultado completo, dez linhas:

| nota | disciplina | aluno_nome |
|---|---|---|
| 95 | Matematica | Aluno 08 |
| 95 | Matematica | Aluno 35 |
| 95 | Portugues | Aluno 45 |
| 94 | Sistemas | Aluno 49 |
| 92 | Portugues | Aluno 18 |
| 91 | Sistemas | Aluno 24 |
| 90 | Matematica | Aluno 03 |
| 90 | Portugues | Aluno 15 |
| 90 | Sistemas | Aluno 30 |
| 89 | Sistemas | Aluno 48 |

### 9.1 O corte de `LIMIT` e os empates

O corte de `LIMIT` é feito por contagem de linhas, e ignora o valor da coluna de ordenação. No resultado acima o corte foi limpo, porque a décima linha, com nota 89, é a única com esse valor.

Trocar `LIMIT 10` por `LIMIT 11` produz um corte diferente. Três alunos obtiveram nota 88, e o comando exibe apenas um deles, escolhido de modo não determinado. O resultado é legítimo em SQL e enganoso como informação, porque sugere que aquele aluno se distingue dos outros dois.

### 9.2 `LIMIT` sem `ORDER BY`

Sem ordem declarada, "as dez primeiras linhas" não significa nada, e o resultado pode variar entre execuções. O comando não falha e devolve dez linhas quaisquer.

**Regra de boa prática:** `LIMIT` deve ser usado sempre acompanhado de `ORDER BY`, e o `ORDER BY` deve ter critérios suficientes para não deixar empate na linha do corte.

---

## 10. A cláusula `WHERE`

A cláusula `WHERE` recebe uma condição e a avalia **para cada linha**, isoladamente. A linha permanece no resultado quando a condição é verdadeira e é descartada quando é falsa.

### 10.1 Operadores de comparação

| Operador | Significado |
|---|---|
| `=` | Igual a |
| `<>` | Diferente de |
| `!=` | Diferente de, sinônimo aceito pelo PostgreSQL |
| `<` | Menor que |
| `<=` | Menor ou igual a |
| `>` | Maior que |
| `>=` | Maior ou igual a |

O operador de igualdade em SQL é o sinal `=` isolado. O sinal duplo `==`, comum em linguagens de programação, não existe em SQL e produz erro de sintaxe.

**Regra de boa prática:** preferir `<>` a `!=`. O primeiro é a forma da norma e funciona em qualquer SGBD. O segundo é uma cortesia do PostgreSQL.

Os dois lados da comparação precisam ter tipos compatíveis. Escrever `nota >= '50'` compara um inteiro com um texto, e o PostgreSQL resolve o caso convertendo o texto. Escrever `aluno_nome >= 50` não tem conversão possível e produz `operator does not exist: text >= integer`.

### 10.2 Filtro por uma condição

```sql
-- Avaliacoes com nota maior ou igual a 90
SELECT
    disciplina, aluno_nome, turma, nota
FROM
    notas_alunos
WHERE
    nota >= 90;
```

Resultado completo, nove linhas:

| disciplina | aluno_nome | turma | nota |
|---|---|---|---|
| Matematica | Aluno 03 | A | 90 |
| Matematica | Aluno 08 | B | 95 |
| Portugues | Aluno 15 | C | 90 |
| Portugues | Aluno 18 | A | 92 |
| Sistemas | Aluno 24 | B | 91 |
| Sistemas | Aluno 30 | C | 90 |
| Matematica | Aluno 35 | C | 95 |
| Portugues | Aluno 45 | B | 95 |
| Sistemas | Aluno 49 | A | 94 |

Nove linhas restaram de cinquenta. Comparado com a seção 6, o contraste fica evidente: `SELECT` reduziu a largura da tabela e `WHERE` reduziu a sua altura.

O resultado acima não tem `ORDER BY`, e a ordem em que as linhas aparecem não foi pedida. Ela coincide com a ordem de inserção porque a tabela é pequena e foi lida do começo ao fim, e não porque a linguagem o garanta.

O operador `>=` inclui o valor 90. Trocá-lo por `>` devolveria seis linhas, e responderia a "acima de 90" em vez de "90 ou mais". A distinção entre os dois enunciados existe em português e precisa sobreviver à tradução para SQL.

### 10.3 Filtro combinado com ordenação

```sql
-- Avaliacoes com nota abaixo de 60, da maior para a menor
SELECT
    disciplina, aluno_nome, turma, nota
FROM
    notas_alunos
WHERE
    nota < 60
ORDER BY
    nota DESC;
```

Resultado completo, oito linhas:

| disciplina | aluno_nome | turma | nota |
|---|---|---|---|
| Portugues | Aluno 14 | C | 59 |
| Matematica | Aluno 36 | C | 58 |
| Matematica | Aluno 05 | A | 55 |
| Sistemas | Aluno 25 | B | 55 |
| Portugues | Aluno 46 | B | 52 |
| Sistemas | Aluno 40 | B | 49 |
| Matematica | Aluno 09 | B | 47 |
| Portugues | Aluno 19 | A | 45 |

O filtro escolheu as linhas e a ordenação as dispôs. As duas cláusulas são independentes: `WHERE` não ordena e `ORDER BY` não filtra.

Os alunos 05 e 25 empataram em 55, e a ordem entre os dois não está determinada.

### 10.4 O operador lógico `AND`

O conectivo `AND` combina duas condições e resulta verdadeiro apenas quando ambas o forem.

```sql
-- Avaliacoes de Matematica com nota maior ou igual a 60
SELECT
    disciplina, aluno_nome, nota
FROM
    notas_alunos
WHERE
    disciplina = 'Matematica' AND nota >= 60;
```

O resultado tem **14 linhas**. Das 17 avaliações de Matematica, três foram descartadas por terem nota inferior a 60.

Os operadores `OR` e `NOT` completam o conjunto dos conectivos lógicos e são tratados no arquivo 03, junto com a regra de precedência entre eles. Enquanto houver apenas `AND` na condição, a precedência não produz surpresa.

### 10.5 A grafia do valor

O valor `'Matematica'` está entre aspas simples porque é um valor de texto, e está escrito sem acento porque é assim que consta na tabela.

A comparação de texto no PostgreSQL diferencia maiúsculas de minúsculas e considera o acento parte do caractere. Nenhuma das três consultas abaixo encontra alguma linha:

```sql
WHERE disciplina = 'matematica'
WHERE disciplina = 'Matemática'
WHERE disciplina = 'MATEMATICA'
```

Nenhuma delas produz erro. Todas devolvem o conjunto vazio, que é a resposta correta à pergunta feita e não à pergunta pretendida.

**Regra de boa prática:** uma consulta que devolve zero linhas sem apresentar erro deve ser investigada primeiro pela grafia do valor, e só depois pela lógica da condição.

### 10.6 Filtro com alias de apresentação

```sql
-- Avaliacoes de Portugues com nota maior ou igual a 60
SELECT
    disciplina AS "Português",
    aluno_nome,
    nota
FROM
    notas_alunos
WHERE
    disciplina = 'Portugues' AND nota >= 60;
```

O resultado tem **13 linhas**. Das 16 avaliações de Portugues, três foram descartadas.

Nesta consulta os dois usos de aspas convivem na mesma instrução: `"Português"` nomeia a coluna do resultado, e `'Portugues'` é o valor procurado na tabela. A comparação continua a ser feita sobre o conteúdo da coluna `disciplina`, e o alias não interfere nela. A seção 12 explica por quê.

---

## 11. `GROUP BY` e funções de agregação

Todas as consultas anteriores devolvem uma linha de resultado para cada linha da tabela que satisfaz o filtro. Há perguntas que não têm essa forma. "Qual é a média de notas de cada disciplina" não pede linhas: pede um valor por disciplina.

A cláusula `GROUP BY` reúne em um mesmo grupo todas as linhas que compartilham o valor das colunas indicadas. Uma **função de agregação** reduz cada grupo a um único valor.

### 11.1 O agrupamento

```sql
SELECT
    disciplina,
    AVG(nota) AS "Média_Notas"
FROM
    notas_alunos
GROUP BY
    disciplina;
```

Resultado completo, três linhas:

| disciplina | Média_Notas |
|---|---|
| Matematica | 73.2941176470588… |
| Portugues | 74.6875000000000… |
| Sistemas | 77.5882352941176… |

As reticências indicam que o valor exibido continua. A quantidade exata de casas decimais é decidida pelo SGBD, conforme a seção 11.3, e não faz parte do que se pede na consulta.

Cinquenta linhas produziram três, uma por valor distinto de `disciplina`. O agrupamento é definido pelos dados, não pelo comando: se uma quarta disciplina fosse inserida na tabela, a mesma consulta passaria a devolver quatro linhas. E se alguém gravasse `'matematica'` em minúsculas, conforme a seção 2.5, passaria a devolver quatro linhas sem que a instituição tivesse criado disciplina nova.

### 11.2 Duas funções de agregação

Este arquivo utiliza apenas duas. O conjunto completo é tratado no arquivo 03.

| Função | Resultado |
|---|---|
| `AVG(coluna)` | Média aritmética dos valores do grupo |
| `COUNT(*)` | Quantidade de linhas do grupo |

```sql
SELECT
    disciplina,
    COUNT(*) AS avaliacoes,
    AVG(nota) AS media
FROM
    notas_alunos
GROUP BY
    disciplina;
```

| disciplina | avaliacoes | media |
|---|---|---|
| Matematica | 17 | 73.2941176470588… |
| Portugues | 16 | 74.6875000000000… |
| Sistemas | 17 | 77.5882352941176… |

A soma da coluna `avaliacoes` é 50, que é o total de linhas da tabela. Toda linha pertence a exatamente um grupo, e nenhuma fica de fora.

### 11.3 A quantidade de casas decimais

A função `AVG` aplicada a uma coluna do tipo `INTEGER` devolve um valor do tipo `numeric`, e não um inteiro. A média de valores inteiros raramente é um número inteiro, e devolver um inteiro exigiria descartar informação sem que ninguém tivesse pedido.

O tipo `numeric` não tem uma quantidade fixa de casas decimais. Ao dividir a soma pela contagem, o PostgreSQL escolhe quantas casas manter, de modo a preservar um número suficiente de dígitos significativos. Por isso a média de Português, que é exata em quatro casas, aparece seguida de zeros: o resultado tem a mesma quantidade de casas nas três linhas, porque é uma coluna só.

Esse comportamento não deve ser decorado. O que precisa ficar claro é a consequência prática: **o resultado de `AVG` não vem arredondado, e não serve para apresentação sem tratamento**.

A função `ROUND` recebe o valor e a quantidade de casas desejada e devolve o valor arredondado.

```sql
SELECT
    disciplina,
    ROUND(AVG(nota), 2) AS media
FROM
    notas_alunos
GROUP BY
    disciplina;
```

| disciplina | media |
|---|---|
| Matematica | 73.29 |
| Portugues | 74.69 |
| Sistemas | 77.59 |

O arredondamento é uma decisão de apresentação e ocorre depois do cálculo. Arredondar antes de agregar produz outro número, porque a média dos valores arredondados não é o arredondamento da média.

**Regra de boa prática:** toda média destinada a ser lida por uma pessoa passa por `ROUND`. Toda média destinada a alimentar outro cálculo não passa, porque o arredondamento intermediário propaga erro.

### 11.4 A regra do `GROUP BY`

Toda coluna que aparece na lista do `SELECT` e não é argumento de uma função de agregação precisa constar do `GROUP BY`. A consulta abaixo viola a regra.

```sql
SELECT
    disciplina,
    turma,
    AVG(nota) AS media
FROM
    notas_alunos
GROUP BY
    disciplina;
```

```
ERROR:  column "notas_alunos.turma" must appear in the GROUP BY clause or be used in an aggregate function
```

A mensagem descreve o problema com exatidão. O grupo `Matematica` reúne 17 linhas, e essas linhas têm turmas diferentes. Não existe "a turma do grupo", e o SGBD recusa-se a inventar uma.

Há duas correções possíveis, e cada uma responde a uma pergunta distinta.

```sql
-- media por disciplina e por turma: cada combinacao forma um grupo
SELECT
    disciplina,
    turma,
    ROUND(AVG(nota), 2) AS media
FROM
    notas_alunos
GROUP BY
    disciplina, turma;
```

```sql
-- media por disciplina, sem discriminar turmas
SELECT
    disciplina,
    ROUND(AVG(nota), 2) AS media
FROM
    notas_alunos
GROUP BY
    disciplina;
```

A primeira consulta devolve nove linhas, uma para cada combinação de disciplina e turma presente nos dados. A segunda devolve três.

O erro não é um capricho do PostgreSQL. Ele impede que a consulta apresente como característica de um grupo um valor que pertence a uma linha só. Uma linguagem que aceitasse a primeira versão teria de escolher uma turma qualquer entre as dezessete, e o relatório resultante estaria errado sem avisar.

---

## 12. A ordem lógica de execução

A ordem em que as cláusulas são **escritas** é fixa e foi apresentada na seção 3. A ordem em que elas são **avaliadas** é outra.

```
FROM  ->  WHERE  ->  GROUP BY  ->  HAVING  ->  SELECT  ->  ORDER BY  ->  LIMIT
```

Lida nessa ordem, a consulta descreve um percurso: obter as linhas da origem, descartar as que não interessam, reunir as restantes em grupos, descartar os grupos que não interessam, calcular as colunas do resultado, ordená-lo e recortá-lo.

Três consequências práticas decorrem dessa ordem, e todas as três aparecem como erro no início do estudo.

### 12.1 A cláusula `WHERE` não enxerga um alias

O alias é criado na etapa `SELECT`, que ocorre depois de `WHERE`. Quando `WHERE` é avaliada, o alias ainda não existe.

```sql
SELECT
    nota AS pontuacao
FROM
    notas_alunos
WHERE
    pontuacao >= 90;
```

```
ERROR:  column "pontuacao" does not exist
```

A correção consiste em repetir a expressão original na condição, e não em renomeá-la novamente.

```sql
SELECT
    nota AS pontuacao
FROM
    notas_alunos
WHERE
    nota >= 90;
```

### 12.2 A cláusula `ORDER BY` enxerga um alias

A ordenação ocorre depois de `SELECT`, quando o alias já existe. A consulta abaixo é válida.

```sql
SELECT
    aluno_nome AS aluno,
    nota AS pontuacao
FROM
    notas_alunos
ORDER BY
    pontuacao DESC
LIMIT
    5;
```

A diferença entre esta consulta e a da seção anterior não está na escrita, que é quase idêntica, e sim na etapa em que cada cláusula é avaliada.

### 12.3 A cláusula `WHERE` não filtra resultados de agregação

A cláusula `WHERE` é avaliada antes do `GROUP BY`, e portanto antes que qualquer média exista. Uma condição sobre a média não pode ser escrita nela.

```sql
SELECT
    disciplina,
    AVG(nota) AS media
FROM
    notas_alunos
WHERE
    AVG(nota) >= 75
GROUP BY
    disciplina;
```

```
ERROR:  aggregate functions are not allowed in WHERE
```

Filtrar grupos é tarefa da cláusula `HAVING`, avaliada depois do agrupamento. A necessidade de duas cláusulas distintas para filtrar não é uma redundância da linguagem: `WHERE` filtra linhas e `HAVING` filtra grupos, e as duas operam em momentos diferentes do percurso. O assunto é tratado no arquivo 03.

---

## 13. Boas práticas consolidadas

Cada regra abaixo apareceu junto ao comando que a motivou. Reunidas, formam a lista de verificação a aplicar antes de considerar uma consulta pronta.

### 13.1 Definição de dados

| Regra | Razão |
|---|---|
| Tipo que corresponda ao domínio real da coluna | Um tipo errado aceita dados inválidos ou ordena de forma inesperada |
| `TEXT` em vez de `VARCHAR(n)` com limite inventado | Restrições inventadas rejeitam dados legítimos |
| `GENERATED ALWAYS AS IDENTITY` em vez de `SERIAL` | Forma da norma, e recusa a inserção manual que dessincroniza a sequência |
| `DROP TABLE IF EXISTS` antes de `CREATE TABLE` em script de cenário | Torna o script reexecutável e garante a estrutura escrita no arquivo |
| `NOT NULL` em toda coluna cujo valor é obrigatório | A omissão autoriza dados incompletos que ninguém pediu |
| Nomes em minúscula, sem acento, com sublinhado | Dispensa aspas duplas em toda referência futura |

### 13.2 Escrita de consultas

| Regra | Razão |
|---|---|
| Listar as colunas em vez de `SELECT *` | O resultado não muda sozinho quando a tabela muda, e o comando documenta a intenção |
| Listar as colunas no `INSERT` | Protege contra a alteração da estrutura da tabela |
| Escrever `AS` sempre, e não apenas quando for obrigatório | Uma vírgula esquecida transforma a coluna seguinte em alias, sem erro |
| Aspas simples para valores, aspas duplas apenas para alias de apresentação | Trocar um pelo outro produz erro ou resultado errado |
| `<>` em vez de `!=` | Forma da norma |
| `ORDER BY` sempre que houver `LIMIT` | Sem ordem declarada, "as primeiras linhas" não significa nada |
| Segundo critério de ordenação quando o empate importa | O primeiro critério não decide entre linhas de mesmo valor |
| `ROUND` em toda média destinada à leitura | `AVG` não arredonda |
| Repetir a expressão na cláusula `WHERE`, e não tentar usar o alias | O alias ainda não existe quando `WHERE` é avaliada |
| Conferir a grafia do valor antes da lógica, quando o resultado vem vazio | A comparação de texto diferencia caixa e acento |

### 13.3 Legibilidade

| Regra | Razão |
|---|---|
| Palavras reservadas em maiúscula, identificadores em minúscula | Separa visualmente a linguagem dos nomes do minimundo |
| Uma cláusula por linha, colunas indentadas | Permite ler a consulta pela borda esquerda |
| Comentário que explica o que o comando não diz | Um comentário que repete o comando envelhece e passa a mentir |

O tratamento estendido está em `referencia/04-boas-praticas-sql.md`.

---

## 14. Erros frequentes e leitura das mensagens

As mensagens do PostgreSQL nomeiam o objeto que causou a falha. Ler o nome citado antes de alterar o comando resolve a maior parte dos casos.

| Mensagem ou sintoma | Causa | Correção |
|---|---|---|
| `relation "notas_aluno" does not exist` | A tabela indicada em `FROM` não existe com esse nome | Conferir a grafia e a conexão ativa |
| `column "sobrenome" does not exist` | A coluna não pertence à tabela indicada em `FROM` | Conferir os nomes com `SELECT * FROM notas_alunos` |
| `column "Matematica" does not exist` | Um valor de texto foi escrito entre aspas duplas | Trocar as aspas duplas por aspas simples |
| `column "pontuacao" does not exist` | Um alias foi usado na cláusula `WHERE` | Repetir a expressão original na condição |
| `aggregate functions are not allowed in WHERE` | Uma função de agregação foi usada na cláusula `WHERE` | Reservar a condição para a cláusula `HAVING` |
| `column "notas_alunos.turma" must appear in the GROUP BY clause` | Coluna não agregada ausente do `GROUP BY` | Acrescentá-la ao `GROUP BY` ou removê-la do `SELECT` |
| `cannot insert a non-DEFAULT value into column "id"` | A coluna `id` foi informada no `INSERT` | Omitir `id` da lista de colunas |
| `null value in column "nota" violates not-null constraint` | Uma linha do `INSERT` deixou de informar uma coluna obrigatória | Conferir a quantidade de valores de cada linha |
| `invalid input syntax for type integer: "oitenta"` | Texto informado em coluna numérica | Conferir a ordem dos valores no `INSERT` |
| `operator does not exist: text >= integer` | Comparação entre tipos incompatíveis | Conferir aspas: `'50'` é texto, `50` é número |
| `syntax error at or near "="` | Uso de `==` no lugar de `=` | O operador de igualdade é o sinal simples |
| `syntax error at or near "FROM"` | Vírgula sobrando ou faltando na lista de colunas | Conferir a lista do `SELECT` |
| `date/time field value out of range` | Data escrita fora do formato `AAAA-MM-DD` | Usar o formato da norma ISO |
| Resultado com zero linhas e sem erro | O valor procurado não existe com aquela grafia | Conferir acentuação e caixa do valor |
| Uma coluna a menos do que o esperado | Vírgula esquecida entre duas colunas, e a segunda virou alias da primeira | Conferir as vírgulas da lista do `SELECT` |

As duas últimas linhas não descrevem erro algum, e sim resultado inesperado sem erro. São as mais perigosas: o SGBD compreendeu o comando e respondeu à pergunta que foi feita, que não era a pretendida.

---

## 15. Script consolidado

Todo o código do arquivo, na ordem de execução.

```sql
-- Active: 1787177433004@@127.0.0.1@5432@bd_aula@public

-- ---------------------------------------------------------------
-- 1. Criacao da tabela
-- ---------------------------------------------------------------
DROP TABLE IF EXISTS notas_alunos;

CREATE TABLE notas_alunos(
    id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    aluno_nome TEXT NOT NULL,
    turma TEXT NOT NULL,
    disciplina TEXT NOT NULL,
    nota INTEGER NOT NULL,
    faltas INTEGER NOT NULL,
    data_avaliacao DATE NOT NULL
);

-- Esquema criado, instancia vazia: sete colunas, nenhuma linha
SELECT * FROM notas_alunos;

-- ---------------------------------------------------------------
-- 2. Carga dos dados
-- ---------------------------------------------------------------
INSERT INTO notas_alunos (aluno_nome, turma, disciplina, nota, faltas, data_avaliacao) VALUES
('Aluno 01','A','Matematica', 85, 2, '2025-09-01'),
('Aluno 02','A','Matematica', 72, 0, '2025-09-01'),
('Aluno 03','A','Matematica', 90, 1, '2025-09-01'),
('Aluno 04','A','Matematica', 60, 3, '2025-09-01'),
('Aluno 05','A','Matematica', 55, 0, '2025-09-01'),
('Aluno 06','B','Matematica', 78, 2, '2025-09-02'),
('Aluno 07','B','Matematica', 88, 1, '2025-09-02'),
('Aluno 08','B','Matematica', 95, 0, '2025-09-02'),
('Aluno 09','B','Matematica', 47, 4, '2025-09-02'),
('Aluno 10','B','Matematica', 68, 2, '2025-09-02'),
('Aluno 11','C','Portugues', 74, 1, '2025-09-03'),
('Aluno 12','C','Portugues', 81, 0, '2025-09-03'),
('Aluno 13','C','Portugues', 66, 2, '2025-09-03'),
('Aluno 14','C','Portugues', 59, 3, '2025-09-03'),
('Aluno 15','C','Portugues', 90, 0, '2025-09-03'),
('Aluno 16','A','Portugues', 85, 0, '2025-09-04'),
('Aluno 17','A','Portugues', 77, 1, '2025-09-04'),
('Aluno 18','A','Portugues', 92, 0, '2025-09-04'),
('Aluno 19','A','Portugues', 45, 5, '2025-09-04'),
('Aluno 20','A','Portugues', 69, 2, '2025-09-04'),
('Aluno 21','B','Sistemas', 88, 0, '2025-09-05'),
('Aluno 22','B','Sistemas', 78, 2, '2025-09-05'),
('Aluno 23','B','Sistemas', 83, 1, '2025-09-05'),
('Aluno 24','B','Sistemas', 91, 0, '2025-09-05'),
('Aluno 25','B','Sistemas', 55, 3, '2025-09-05'),
('Aluno 26','C','Sistemas', 66, 2, '2025-09-06'),
('Aluno 27','C','Sistemas', 72, 1, '2025-09-06'),
('Aluno 28','C','Sistemas', 79, 0, '2025-09-06'),
('Aluno 29','C','Sistemas', 84, 0, '2025-09-06'),
('Aluno 30','C','Sistemas', 90, 0, '2025-09-06'),
('Aluno 31','A','Matematica', 82, 1, '2025-09-07'),
('Aluno 32','A','Matematica', 74, 2, '2025-09-07'),
('Aluno 33','B','Portugues', 69, 1, '2025-09-07'),
('Aluno 34','B','Portugues', 71, 0, '2025-09-07'),
('Aluno 35','C','Matematica', 95, 0, '2025-09-08'),
('Aluno 36','C','Matematica', 58, 4, '2025-09-08'),
('Aluno 37','A','Sistemas', 63, 2, '2025-09-08'),
('Aluno 38','A','Sistemas', 77, 1, '2025-09-08'),
('Aluno 39','B','Sistemas', 85, 0, '2025-09-09'),
('Aluno 40','B','Sistemas', 49, 5, '2025-09-09'),
('Aluno 41','C','Portugues', 88, 0, '2025-09-09'),
('Aluno 42','C','Portugues', 82, 1, '2025-09-09'),
('Aluno 43','A','Matematica', 70, 2, '2025-09-10'),
('Aluno 44','A','Matematica', 68, 3, '2025-09-10'),
('Aluno 45','B','Portugues', 95, 0, '2025-09-10'),
('Aluno 46','B','Portugues', 52, 4, '2025-09-10'),
('Aluno 47','C','Sistemas', 76, 1, '2025-09-11'),
('Aluno 48','C','Sistemas', 89, 0, '2025-09-11'),
('Aluno 49','A','Sistemas', 94, 0, '2025-09-11'),
('Aluno 50','B','Matematica', 61, 2, '2025-09-11');

-- Conferencia: 50 linhas
SELECT * FROM notas_alunos;

-- ---------------------------------------------------------------
-- 3. SELECT e FROM: projecao
-- ---------------------------------------------------------------
SELECT
    aluno_nome,
    turma,
    disciplina,
    nota
FROM
    notas_alunos;

-- A ordem das colunas no resultado e a ordem da lista
SELECT
    nota,
    disciplina,
    aluno_nome
FROM
    notas_alunos;

-- A projecao nao elimina repeticoes: 50 linhas, muitas iguais
SELECT
    turma,
    disciplina
FROM
    notas_alunos;

-- ---------------------------------------------------------------
-- 4. Alias de coluna
-- ---------------------------------------------------------------
SELECT
    aluno_nome AS aluno,
    nota AS nota_final
FROM
    notas_alunos;

-- Alias com acento exige aspas duplas
SELECT
    disciplina AS "Português",
    aluno_nome,
    nota
FROM
    notas_alunos;

-- ---------------------------------------------------------------
-- 5. ORDER BY e LIMIT
-- ---------------------------------------------------------------
SELECT
    nota,
    disciplina,
    aluno_nome
FROM
    notas_alunos
ORDER BY
    nota DESC;

-- As dez maiores notas
SELECT
    nota,
    disciplina,
    aluno_nome
FROM
    notas_alunos
ORDER BY
    nota DESC
LIMIT
    10;

-- ---------------------------------------------------------------
-- 6. WHERE
-- ---------------------------------------------------------------
-- Avaliacoes com nota maior ou igual a 90: 9 linhas
SELECT
    disciplina, aluno_nome, turma, nota
FROM
    notas_alunos
WHERE
    nota >= 90;

-- Avaliacoes com nota abaixo de 60, da maior para a menor: 8 linhas
SELECT
    disciplina, aluno_nome, turma, nota
FROM
    notas_alunos
WHERE
    nota < 60
ORDER BY
    nota DESC;

-- Avaliacoes de Matematica com nota maior ou igual a 60: 14 linhas
SELECT
    disciplina, aluno_nome, nota
FROM
    notas_alunos
WHERE
    disciplina = 'Matematica' AND nota >= 60;

-- Avaliacoes de Portugues com nota maior ou igual a 60: 13 linhas
SELECT
    disciplina AS "Português",
    aluno_nome,
    nota
FROM
    notas_alunos
WHERE
    disciplina = 'Portugues' AND nota >= 60;

-- Grafia do valor: as tres consultas devolvem zero linhas, sem erro
SELECT aluno_nome FROM notas_alunos WHERE disciplina = 'matematica';
SELECT aluno_nome FROM notas_alunos WHERE disciplina = 'Matemática';
SELECT aluno_nome FROM notas_alunos WHERE disciplina = 'MATEMATICA';

-- ---------------------------------------------------------------
-- 7. GROUP BY e funcoes de agregacao
-- ---------------------------------------------------------------
SELECT
    disciplina,
    AVG(nota) AS "Média_Notas"
FROM
    notas_alunos
GROUP BY
    disciplina;

-- Quantidade e media por disciplina
SELECT
    disciplina,
    COUNT(*) AS avaliacoes,
    AVG(nota) AS media
FROM
    notas_alunos
GROUP BY
    disciplina;

-- Media arredondada a duas casas decimais
SELECT
    disciplina,
    ROUND(AVG(nota), 2) AS media
FROM
    notas_alunos
GROUP BY
    disciplina;

-- Cada combinacao de disciplina e turma forma um grupo: 9 linhas
SELECT
    disciplina,
    turma,
    ROUND(AVG(nota), 2) AS media
FROM
    notas_alunos
GROUP BY
    disciplina, turma;

-- ---------------------------------------------------------------
-- 8. Ordem logica de execucao: comandos que produzem erro
--    Executar um a um para ler a mensagem
-- ---------------------------------------------------------------
-- ERROR: column "sobrenome" does not exist
SELECT sobrenome FROM notas_alunos;

-- ERROR: column "pontuacao" does not exist
SELECT nota AS pontuacao FROM notas_alunos WHERE pontuacao >= 90;

-- ERROR: aggregate functions are not allowed in WHERE
SELECT disciplina, AVG(nota) AS media
FROM notas_alunos
WHERE AVG(nota) >= 75
GROUP BY disciplina;

-- ERROR: column "notas_alunos.turma" must appear in the GROUP BY clause
SELECT disciplina, turma, AVG(nota) AS media
FROM notas_alunos
GROUP BY disciplina;

-- ERROR: cannot insert a non-DEFAULT value into column "id"
INSERT INTO notas_alunos (id, aluno_nome, turma, disciplina, nota, faltas, data_avaliacao)
VALUES (999, 'Aluno 51', 'A', 'Matematica', 80, 0, '2025-09-20');

-- Valido: ORDER BY enxerga o alias criado em SELECT
SELECT
    aluno_nome AS aluno,
    nota AS pontuacao
FROM
    notas_alunos
ORDER BY
    pontuacao DESC
LIMIT
    5;
```

---

## 16. Exercícios

Os enunciados devem ser resolvidos sem consultar a seção 17. Cada resposta deve ser escrita por inteiro, e não copiada de um exemplo anterior com valores trocados.

**Minimundo**

1. Enunciar, em uma frase, uma regra do minimundo desta aula que a tabela `notas_alunos` **não** consegue impedir que seja violada. Explicar por quê.
2. Descrever qual coluna seria acrescentada à tabela para que dois alunos de mesmo nome deixassem de ser indistinguíveis, e qual restrição essa coluna deveria receber.

**Consulta e apresentação**

3. Retornar todas as colunas e todas as linhas da tabela.
4. Listar `aluno_nome`, `disciplina` e `nota`, ordenado pela nota em ordem decrescente, exibindo apenas as dez primeiras linhas.
5. Listar `aluno_nome` e `faltas` dos cinco alunos com menos faltas. Em caso de empate no número de faltas, apresentar primeiro a maior nota.
6. Listar `disciplina` e `nota` com os cabeçalhos escritos como `Disciplina avaliada` e `Nota obtida`.

**Filtro**

7. Listar todas as colunas das avaliações da turma `C`.
8. Listar `disciplina`, `aluno_nome` e `nota` das avaliações com nota de 70 a 79, ordenado pela nota em ordem crescente.
9. Listar `aluno_nome` e `nota` das avaliações de Sistemas com nota maior ou igual a 80, ordenado pela nota em ordem decrescente.
10. Listar `aluno_nome`, `turma`, `nota` e `faltas` das avaliações com três faltas ou mais, ordenado pelas faltas em ordem decrescente.

**Agregação**

11. Contar quantas avaliações existem em cada disciplina.
12. Apresentar a média das notas de cada turma, arredondada a duas casas decimais, com o cabeçalho da coluna calculada escrito como `Média da turma`.
13. Apresentar, para cada disciplina, a quantidade de avaliações e a média arredondada a duas casas, ordenado pela média em ordem decrescente.
14. Apresentar apenas a disciplina de maior média.
15. Apresentar as cinco notas mais frequentes na tabela, com a quantidade de vezes em que cada uma ocorre.

**Diagnóstico**

16. Explicar por que a consulta abaixo produz erro e escrever a versão correta.

```sql
SELECT nota AS resultado
FROM notas_alunos
WHERE resultado >= 80;
```

17. Explicar por que a consulta abaixo devolve zero linhas sem apresentar erro.

```sql
SELECT aluno_nome, nota
FROM notas_alunos
WHERE disciplina = 'matemática';
```

18. Explicar por que a consulta abaixo produz erro, e escrever duas versões corretas que respondam a perguntas diferentes.

```sql
SELECT turma, aluno_nome, AVG(nota) AS media
FROM notas_alunos
GROUP BY turma;
```

---

## 17. Gabarito

**1.** A regra 2 do minimundo diz que cada aluno pertence a uma turma, e a tabela não consegue garantir que o mesmo aluno tenha sempre a mesma turma.

O motivo está na seção 2.5: a turma está gravada em cada linha de avaliação, e não em um lugar único onde o aluno esteja definido. Se o Aluno 01 tivesse duas avaliações, nada impediria que uma registrasse a turma `A` e a outra a turma `B`. A regra 1, que diz que a instituição oferece disciplinas, também não é verificável: nada impede que uma linha registre uma disciplina que não existe.

**2.** Uma coluna `aluno_id INTEGER NOT NULL`, que passaria a identificar o aluno, ficando o nome como atributo descritivo.

A solução completa exige uma tabela `aluno` com esse identificador como chave primária, e uma restrição de **chave estrangeira** ligando `notas_alunos` a ela. Sem a tabela referenciada, a coluna seria apenas um número que ninguém garante existir. O tratamento das chaves estrangeiras ocorre nos arquivos 10 e 11.

Com essa mudança, a coluna `turma` deixaria de pertencer a `notas_alunos` e passaria para a tabela `aluno`, eliminando a redundância descrita na seção 2.5.

**3.** Todas as colunas e todas as linhas.

```sql
SELECT * FROM notas_alunos;
```

Resultado: 50 linhas, sete colunas.

**4.** As dez maiores notas.

```sql
SELECT
    aluno_nome,
    disciplina,
    nota
FROM
    notas_alunos
ORDER BY
    nota DESC
LIMIT
    10;
```

Resultado: 10 linhas, da nota 95 à nota 89.

**5.** Cinco alunos com menos faltas.

```sql
SELECT
    aluno_nome,
    faltas,
    nota
FROM
    notas_alunos
ORDER BY
    faltas ASC, nota DESC
LIMIT
    5;
```

| aluno_nome | faltas | nota |
|---|---|---|
| Aluno 08 | 0 | 95 |
| Aluno 35 | 0 | 95 |
| Aluno 45 | 0 | 95 |
| Aluno 49 | 0 | 94 |
| Aluno 18 | 0 | 92 |

Dezenove alunos têm zero faltas. O critério de desempate pela nota é o que torna o resultado determinado a partir da quarta linha. As três primeiras continuam empatadas em faltas e em nota, e sua ordem relativa permanece indefinida.

**6.** Cabeçalhos com espaço.

```sql
SELECT
    disciplina AS "Disciplina avaliada",
    nota       AS "Nota obtida"
FROM
    notas_alunos;
```

Os dois aliases exigem aspas duplas por conterem espaço. Sem elas, o comando produziria erro de sintaxe ao encontrar a segunda palavra.

**7.** Avaliações da turma `C`.

```sql
SELECT *
FROM notas_alunos
WHERE turma = 'C';
```

Resultado: 16 linhas.

**8.** Notas de 70 a 79.

```sql
SELECT
    disciplina,
    aluno_nome,
    nota
FROM
    notas_alunos
WHERE
    nota >= 70 AND nota <= 79
ORDER BY
    nota ASC;
```

Resultado: 12 linhas, da nota 70 à nota 79. O operador `BETWEEN` abrevia esta condição e é tratado no arquivo 03.

**9.** Sistemas com nota maior ou igual a 80.

```sql
SELECT
    aluno_nome,
    nota
FROM
    notas_alunos
WHERE
    disciplina = 'Sistemas' AND nota >= 80
ORDER BY
    nota DESC;
```

| aluno_nome | nota |
|---|---|
| Aluno 49 | 94 |
| Aluno 24 | 91 |
| Aluno 30 | 90 |
| Aluno 48 | 89 |
| Aluno 21 | 88 |
| Aluno 39 | 85 |
| Aluno 29 | 84 |
| Aluno 23 | 83 |

Oito linhas. Das 17 avaliações de Sistemas, nove ficaram abaixo de 80.

**10.** Três faltas ou mais.

```sql
SELECT
    aluno_nome,
    turma,
    nota,
    faltas
FROM
    notas_alunos
WHERE
    faltas >= 3
ORDER BY
    faltas DESC;
```

Resultado: 9 linhas, com faltas de 5 a 3. A ordem entre linhas de mesmo número de faltas não está determinada, porque nenhum segundo critério foi declarado. Acrescentar `, nota ASC` resolveria o caso.

**11.** Avaliações por disciplina.

```sql
SELECT
    disciplina,
    COUNT(*) AS avaliacoes
FROM
    notas_alunos
GROUP BY
    disciplina;
```

| disciplina | avaliacoes |
|---|---|
| Matematica | 17 |
| Portugues | 16 |
| Sistemas | 17 |

**12.** Média por turma, com rótulo acentuado.

```sql
SELECT
    turma,
    ROUND(AVG(nota), 2) AS "Média da turma"
FROM
    notas_alunos
GROUP BY
    turma;
```

| turma | Média da turma |
|---|---|
| A | 74.00 |
| B | 73.71 |
| C | 78.06 |

O alias exige aspas duplas por conter espaços e acento.

**13.** Quantidade e média por disciplina, ordenado pela média.

```sql
SELECT
    disciplina,
    COUNT(*) AS avaliacoes,
    ROUND(AVG(nota), 2) AS media
FROM
    notas_alunos
GROUP BY
    disciplina
ORDER BY
    media DESC;
```

| disciplina | avaliacoes | media |
|---|---|---|
| Sistemas | 17 | 77.59 |
| Portugues | 16 | 74.69 |
| Matematica | 17 | 73.29 |

A cláusula `ORDER BY` utiliza o alias `media`, criado na cláusula `SELECT`. A ordenação é a última etapa antes do recorte, conforme a seção 12.

**14.** Disciplina de maior média.

```sql
SELECT
    disciplina,
    ROUND(AVG(nota), 2) AS media
FROM
    notas_alunos
GROUP BY
    disciplina
ORDER BY
    media DESC
LIMIT
    1;
```

| disciplina | media |
|---|---|
| Sistemas | 77.59 |

A combinação de agrupamento, ordenação e recorte responde a uma pergunta de superlativo sem nenhum recurso adicional da linguagem.

**15.** Notas mais frequentes.

```sql
SELECT
    nota,
    COUNT(*) AS ocorrencias
FROM
    notas_alunos
GROUP BY
    nota
ORDER BY
    ocorrencias DESC
LIMIT
    5;
```

Quatro notas ocorrem três vezes cada, e são elas que ocupam as quatro primeiras posições: 85, 88, 90 e 95. A ordem entre as quatro não está determinada, porque a contagem é a mesma. A quinta linha é uma das notas que ocorrem duas vezes, e qual delas aparece também não está determinado.

Este resultado ilustra o problema descrito na seção 9.1: `LIMIT` corta por contagem de linhas e não distingue empates. Uma consulta que devolvesse todas as notas de frequência máxima exige subconsulta, tratada no arquivo 25.

**16.** A consulta produz o erro `column "resultado" does not exist`.

O alias `resultado` é criado na etapa `SELECT`, que a ordem lógica de execução coloca depois de `WHERE`. Quando a condição é avaliada, o nome `resultado` ainda não existe, e o único nome disponível é o da coluna original. A correção repete a expressão na condição.

```sql
SELECT nota AS resultado
FROM notas_alunos
WHERE nota >= 80;
```

**17.** A consulta é sintaticamente correta e devolve zero linhas.

A comparação de texto no PostgreSQL diferencia maiúsculas de minúsculas e trata o caractere acentuado como distinto do não acentuado. O valor armazenado na tabela é `Matematica`, com inicial maiúscula e sem acento, e nenhuma linha corresponde a `'matemática'`. O conjunto vazio é a resposta correta à pergunta feita, e não à pergunta pretendida.

```sql
SELECT aluno_nome, nota
FROM notas_alunos
WHERE disciplina = 'Matematica';
```

**18.** A consulta produz:

```
ERROR:  column "notas_alunos.aluno_nome" must appear in the GROUP BY clause or be used in an aggregate function
```

A coluna `aluno_nome` está na lista do `SELECT`, não é argumento de função de agregação e não consta do `GROUP BY`. O grupo da turma `A` reúne 17 linhas com 17 alunos distintos, e não existe "o aluno do grupo".

Primeira versão correta, que responde por turma:

```sql
SELECT
    turma,
    ROUND(AVG(nota), 2) AS media
FROM
    notas_alunos
GROUP BY
    turma;
```

Três linhas, uma por turma.

Segunda versão correta, que responde por turma e aluno:

```sql
SELECT
    turma,
    aluno_nome,
    ROUND(AVG(nota), 2) AS media
FROM
    notas_alunos
GROUP BY
    turma, aluno_nome;
```

Cinquenta linhas. Como cada aluno tem uma única avaliação neste conjunto de dados, cada grupo tem uma linha só, e a média de um valor é o próprio valor. O resultado é correto e inútil, o que é uma boa demonstração de que agrupar por colunas em excesso desfaz o agrupamento.

---

## 18. Referências

ELMASRI, Ramez. NAVATHE, Shamkant B. *Sistemas de Banco de Dados*. 7. ed. São Paulo: Pearson, 2018. Capítulo 1, seção 1.1, sobre minimundo e as propriedades de um banco de dados. Capítulo 6, seções 6.3 e 6.4, sobre a consulta de recuperação.

POSTGRESQL GLOBAL DEVELOPMENT GROUP. *PostgreSQL 17 Documentation*. Capítulo 7, *Queries*. Disponível em `https://www.postgresql.org/docs/17/queries.html`.

Material de apoio: `referencia/01-tipos-de-dados.md`, sobre domínios e critérios de escolha de tipo. `referencia/04-boas-praticas-sql.md`, sobre caixa, delimitadores e formatação.
