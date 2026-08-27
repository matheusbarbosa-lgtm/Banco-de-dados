# Aula 03. Minimundo, operadores e consulta ampliada

**Disciplina:** Sistemas de Banco de Dados I. Sistemas de Informação. UNIPAM.
**Itens da ementa:** 1.1, características da abordagem de banco de dados. 4.3, consulta de recuperação básica. 7.1, funções de agregação e `HAVING`.
**Referência:** ELMASRI, R. NAVATHE, S. *Sistemas de Banco de Dados*. 7. ed. São Paulo: Pearson. Capítulos 1, 6 e 7.
**Ambiente:** PostgreSQL 17 em contêiner Docker, acessado pela extensão Database Client.
**Cenário:** banco de dados `bd_vendas`, tabela `vendas_itens`, com 50 registros. Todo o código necessário está neste arquivo.

---

## Sumário

1. Objetivo
2. O minimundo
3. Um banco de dados para cada minimundo
4. A tabela `vendas_itens`
5. Recuperação básica: retomada do arquivo 02
6. Operadores e expressões
7. A cláusula `WHERE` ampliada
8. `DISTINCT`, `ORDER BY`, `LIMIT` e `OFFSET`
9. Funções de agregação, `GROUP BY` e `HAVING`
10. Boas práticas consolidadas
11. Erros frequentes e leitura das mensagens
12. Script consolidado
13. Exercícios
14. Gabarito
15. Referências

---

## 1. Objetivo

O arquivo 02 estabeleceu a instrução `SELECT` e suas cláusulas sobre a tabela `notas_alunos`. Aquele percurso deixou de fora a maior parte dos operadores da linguagem e tratou o agrupamento apenas em primeiro contato.

Este arquivo completa a consulta de recuperação. E faz isso a partir de uma pergunta que ainda não havia sido formulada no material: **antes de escrever qualquer comando, o que exatamente está sendo representado dentro do banco de dados?** A resposta a essa pergunta chama-se minimundo, e é o assunto da seção 2.

Ao final, os seguintes resultados devem estar assegurados.

| Resultado | Descrição |
|---|---|
| Minimundo | Reconhecer que um banco de dados representa um recorte da realidade, e saber descrever esse recorte antes de programar |
| Separação | Compreender por que minimundos distintos ocupam bancos de dados distintos |
| Operadores | Utilizar os operadores aritméticos, de comparação e lógicos, e conhecer a precedência entre eles |
| Filtro completo | Utilizar `BETWEEN`, `IN`, `LIKE`, `IS NULL` e `NOT`, e reconhecer o comportamento de `NULL` nas comparações |
| Apresentação | Utilizar `DISTINCT`, `ORDER BY` com vários critérios, `LIMIT` e `OFFSET` |
| Agregação | Utilizar as funções de agregação, agrupar por várias colunas e filtrar grupos com `HAVING` |
| Boas práticas | Justificar cada escolha de escrita, e não apenas reproduzi-la |

### 1.1 Delimitação

Continua fora do escopo a junção de tabelas, tratada no arquivo 23, e a subconsulta, tratada no arquivo 25. Isso é uma consequência do cenário e não uma restrição arbitrária: enquanto houver uma tabela só, não há o que juntar.

---

## 2. O minimundo

### 2.1 Dado, informação e banco de dados

Um **dado** é um fato conhecido que pode ser registrado e que possui significado implícito. O número `220.00` é um dado. Isolado, ele não informa nada: pode ser um preço, uma distância ou um código.

Um dado passa a produzir **informação** quando se sabe a que ele se refere. `220.00` como valor unitário do produto 4 na venda 2002 informa alguma coisa, porque está ligado a um contexto que lhe dá sentido.

Um **banco de dados** é uma coleção de dados relacionados. A definição do livro-texto acrescenta três propriedades implícitas, e nenhuma delas é dispensável.

| Propriedade | Significado |
|---|---|
| Representa um minimundo | O conteúdo do banco corresponde a um recorte da realidade, e mudanças naquele recorte precisam se refletir no banco |
| É logicamente coerente | Os dados guardam relação entre si e formam um conjunto com sentido próprio, não uma coleção aleatória |
| Tem propósito e público | O banco é projetado, construído e povoado para um grupo de usuários e um conjunto de aplicações previamente definido |

A terceira propriedade explica por que não existe modelagem correta em abstrato. A mesma realidade admite recortes diferentes conforme o que se pretende fazer com os dados.

### 2.2 O que é o minimundo

O **minimundo**, também chamado de **universo de discurso**, é a parte da realidade que o banco de dados se propõe a representar. Ele é sempre menor do que a realidade, e essa redução é deliberada.

Descrever o minimundo é enunciar, em linguagem natural, o que existe naquele recorte, quais são as regras que o governam e o que ficou de fora. Essa descrição precede o modelo, que precede o esquema, que precede a primeira linha de SQL. Quando essa ordem é invertida, o resultado é uma tabela cuja finalidade ninguém sabe explicar.

### 2.3 O minimundo desta aula

O recorte adotado é a **operação de venda de uma loja**, observada do ponto de vista dos itens vendidos.

Regras do minimundo, enunciadas em linguagem natural:

1. A loja realiza vendas. Cada venda é identificada por um número e ocorre em uma data.
2. Uma venda contém um ou mais itens. Não existe venda sem item.
3. Cada item de venda refere-se a um produto, identificado por um número.
4. Cada item registra o valor unitário praticado naquele produto, naquela venda.
5. Um item pode receber uma observação em texto livre. A maior parte dos itens não recebe nenhuma.

A quinta regra merece destaque, porque introduz o conceito de **ausência de valor**. Ela não diz que a observação é vazia, diz que ela pode não existir. A distinção entre "não existe" e "existe e está vazio" é tratada na seção 7.5.

### 2.4 Entidade, atributo e relacionamento

Três termos aparecem toda vez que um minimundo é descrito, e convém fixá-los desde já, ainda que o tratamento formal ocorra nos arquivos de modelagem conceitual.

| Termo | Definição | No minimundo desta aula |
|---|---|---|
| Entidade | Uma coisa do mundo real, com existência independente, sobre a qual se deseja guardar dados | Uma venda. Um produto |
| Atributo | Uma propriedade que descreve uma entidade | A data da venda. O valor unitário do produto |
| Relacionamento | Uma associação entre entidades | Um produto **figura em** uma venda |

O item de venda é o relacionamento entre venda e produto. Ele não é uma coisa que exista sozinha no mundo: não há item de venda sem uma venda e sem um produto. E, ainda assim, ele tem um atributo próprio, o valor unitário, que não pertence nem à venda nem ao produto isoladamente, e sim à associação entre os dois.

Essa observação é o germe de toda a modelagem conceitual, tratada dos arquivos 17 ao 22.

### 2.5 O recorte: o que ficou de fora

Um minimundo se define tanto pelo que inclui quanto pelo que exclui. Nesta aula ficaram de fora, por decisão explícita:

- **O cliente.** Não se sabe quem comprou.
- **A quantidade.** Cada linha registra um valor unitário e não quantas unidades foram levadas.
- **O nome do produto.** Existe apenas o número que o identifica.
- **A tabela de vendas e a tabela de produtos.** Existem os números `venda_id` e `produto_id`, mas não existe uma tabela onde esses números estejam definidos.

A última exclusão tem uma consequência técnica imediata, tratada na seção 4.4.

### 2.6 Vocabulário

| Termo | Significado |
|---|---|
| Minimundo | O recorte da realidade que o banco representa |
| Esquema | A descrição da estrutura do banco, que muda raramente |
| Instância | O conteúdo do banco em um dado momento, que muda a cada operação |
| Entidade | Coisa do mundo real sobre a qual se guardam dados |
| Atributo | Propriedade que descreve uma entidade |
| Relacionamento | Associação entre entidades |
| Redundância | O mesmo dado armazenado em mais de um lugar |
| Anomalia | Comportamento indesejado que a redundância provoca ao inserir, alterar ou remover dados |

A distinção entre esquema e instância é o item 2.1 da ementa e recebe tratamento próprio no arquivo 15. Por ora basta reter que `CREATE TABLE` define esquema e `INSERT` altera instância.

---

## 3. Um banco de dados para cada minimundo

### 3.1 Por que não reaproveitar `bd_aula`

A tabela `notas_alunos`, do arquivo 02, representa um minimundo acadêmico. A tabela `vendas_itens` representa um minimundo comercial. Entre as duas não existe nenhuma relação: nenhuma consulta faz sentido cruzando notas de alunos com itens de venda.

Manter as duas no mesmo banco de dados sugeriria uma coerência lógica que não existe, e contrariaria a segunda propriedade enunciada na seção 2.1. Um banco de dados é a fronteira de um minimundo. Minimundos distintos ocupam bancos distintos.

Há ainda uma razão prática: bancos separados podem ser copiados, restaurados e descartados de modo independente. Descartar o cenário de vendas ao final do estudo não deve colocar em risco o cenário de notas.

### 3.2 A instrução `CREATE DATABASE`

Com a conexão apontando para `bd_aula`, executar:

```sql
CREATE DATABASE bd_vendas;
```

Três observações sobre essa instrução, todas com consequência prática.

**Ela não pode ser executada a partir do banco que se pretende criar.** O comando precisa ser emitido de dentro de uma conexão já estabelecida com algum outro banco. Daí a instrução partir de `bd_aula`.

**Ela não aceita a cláusula `IF NOT EXISTS` no PostgreSQL.** Executá-la duas vezes produz `ERROR: database "bd_vendas" already exists`. Esse erro é inofensivo e indica que o banco já está criado.

**Ela não pode ser executada dentro de um bloco de transação.** Ao selecionar várias instruções de uma vez, algumas ferramentas as enviam agrupadas, e o comando falha com `CREATE DATABASE cannot run inside a transaction block`. A instrução deve ser executada isoladamente.

Para remover o banco, quando o estudo do cenário estiver encerrado:

```sql
DROP DATABASE IF EXISTS bd_vendas;
```

Essa remoção falha enquanto houver qualquer conexão aberta com `bd_vendas`, inclusive a da própria ferramenta. É preciso apontar a conexão para outro banco antes de executá-la.

### 3.3 A conexão no Database Client

Depois de criar o banco, a lista de bancos da conexão precisa ser atualizada para que `bd_vendas` apareça. Todo o restante deste arquivo é executado com a conexão apontando para `bd_vendas`, esquema `public`.

A extensão reconhece a conexão pela primeira linha do arquivo:

```sql
-- Active: 1787177433004@@127.0.0.1@5432@bd_vendas@public
```

O número inicial é o identificador local da conexão e varia de máquina para máquina. Os campos seguintes são servidor, porta, banco e esquema. Comparado ao arquivo 02, o que mudou foi apenas o penúltimo campo.

Executar o `CREATE TABLE` da seção 4 com a conexão errada cria a tabela em `bd_aula`. O comando não falha, e o engano só aparece depois. Conferir a conexão antes de executar é mais barato do que descobrir o problema mais tarde.

---

## 4. A tabela `vendas_itens`

### 4.1 Estrutura

| Coluna | Tipo | Obrigatória | Representa |
|---|---|---|---|
| `id` | `INTEGER` | Sim | Identificador da linha, gerado pelo SGBD |
| `venda_id` | `INTEGER` | Sim | Número da venda a que o item pertence |
| `produto_id` | `INTEGER` | Sim | Número do produto vendido |
| `valor_unitario` | `NUMERIC(10,2)` | Sim | Valor unitário praticado, em reais |
| `data_venda` | `DATE` | Sim | Data em que a venda ocorreu |
| `observacao` | `TEXT` | Não | Anotação livre sobre o item |

A coluna `observacao` é a única que admite ausência de valor, conforme a regra 5 do minimundo. Ela existe neste cenário para que os operadores `LIKE` e `IS NULL` tenham sobre o que operar, e a decisão está registrada aqui de modo explícito porque o cenário original não previa coluna de texto.

### 4.2 `NUMERIC` e a representação de dinheiro

`NUMERIC(10,2)` declara um número com **precisão** 10 e **escala** 2: até dez dígitos no total, dos quais dois à direita da vírgula. O maior valor representável é `99999999.99`.

A escolha desse tipo para valores monetários não é preferência de estilo. Os tipos `REAL` e `DOUBLE PRECISION` armazenam números em ponto flutuante binário, e há valores decimais simples que não têm representação exata em binário. Em ponto flutuante, `0.1 + 0.2` não resulta exatamente em `0.3`. Somar milhares de valores assim acumula diferenças de centavos, e um relatório financeiro que não fecha é um relatório inútil.

O tipo `NUMERIC` armazena os dígitos decimais e opera sobre eles, sem conversão para binário. É mais lento e é exato. Para dinheiro, exatidão não é negociável.

**Regra de boa prática:** valores monetários em `NUMERIC` com escala explícita. Ponto flutuante fica reservado a grandezas medidas, como temperatura ou distância, onde a última casa já é aproximada por natureza.

### 4.3 `IDENTITY` em vez de `SERIAL`

O código de origem deste cenário declarava `id SERIAL PRIMARY KEY`. O material adota outra forma:

```sql
id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY
```

As duas produzem o mesmo efeito prático, que é gerar o valor da chave a cada inserção. As diferenças são as seguintes.

| Aspecto | `SERIAL` | `GENERATED ALWAYS AS IDENTITY` |
|---|---|---|
| Origem | Extensão do PostgreSQL | Norma SQL, desde a revisão de 2003 |
| O que é | Um atalho que cria uma sequência e liga a coluna a ela | Uma propriedade da própria coluna |
| Inserção manual do valor | Permitida, e dessincroniza a sequência | Recusada, com erro claro |
| Portabilidade | Nenhuma | Reconhecida por outros SGBDs |

O item que mais importa é o terceiro. Com `SERIAL`, informar o `id` manualmente é aceito, a sequência continua no número antigo, e a próxima inserção automática falha por chave duplicada. O erro aparece longe da causa. Com `GENERATED ALWAYS`, a tentativa é recusada no ato:

```
ERROR:  cannot insert a non-DEFAULT value into column "id"
```

**Regra de boa prática:** preferir sempre a forma padronizada quando ela existe e resolve o problema. Extensões de um produto se pagam com dependência daquele produto.

### 4.4 A ausência de chave estrangeira

As colunas `venda_id` e `produto_id` guardam números que se referem a coisas de fora da tabela. Em um banco completo, elas seriam **chaves estrangeiras**, apontando para uma tabela `venda` e para uma tabela `produto`, e o SGBD recusaria qualquer valor que não existisse do outro lado.

Aqui não é possível declarar essa restrição, porque as tabelas referenciadas não existem. A consequência é concreta: nada impede a inserção de um item com `produto_id = 999`, um produto que a loja não vende. O banco aceitaria o dado sem reclamar.

Essa é a diferença entre uma restrição **enunciada** e uma restrição **declarada**. A regra existe no minimundo. Enquanto não estiver escrita no esquema, a responsabilidade de cumpri-la recai sobre quem escreve os comandos, e recair sobre uma pessoa significa que mais cedo ou mais tarde ela será violada.

O tratamento das chaves estrangeiras ocorre nos arquivos 10 e 11.

### 4.5 A redundância do valor unitário

O produto 4 aparece em cinco linhas, e nas cinco o valor unitário é `220.00`. O mesmo dado está armazenado cinco vezes.

Se o preço do produto 4 mudasse, seria necessário alterar cinco linhas. Alterar quatro e esquecer uma deixaria o banco em um estado onde o mesmo produto tem dois preços, sem que nada no esquema apontasse o problema. Isso se chama **anomalia de atualização**, e é a manifestação mais visível da redundância.

A tabela é intencionalmente mantida nessa forma. Ela reproduz o que costuma sair de uma planilha, que é a origem real da maior parte dos dados que chegam a um banco. O tratamento formal do problema é a normalização, itens 8.1 a 8.4, arquivos 33 a 36.

### 4.6 `DROP TABLE IF EXISTS` em vez de `CREATE TABLE IF NOT EXISTS`

O código de origem usava `CREATE TABLE IF NOT EXISTS`. O material usa a forma abaixo:

```sql
DROP TABLE IF EXISTS vendas_itens;

CREATE TABLE vendas_itens (
    ...
);
```

A diferença aparece na segunda execução do script.

`CREATE TABLE IF NOT EXISTS` não faz nada quando a tabela já existe. Nada inclui não conferir se a estrutura existente é a esperada. Ao corrigir uma coluna no script e executá-lo de novo, a tabela antiga permanece intacta, o `INSERT` seguinte falha ou insere no formato errado, e a mensagem de erro aponta para o `INSERT`, não para a causa.

`DROP TABLE IF EXISTS` seguido de `CREATE TABLE` garante que a estrutura obtida é sempre a que está escrita no arquivo. O script torna-se **reexecutável**, e o resultado de executá-lo duas vezes é igual ao de executá-lo uma vez.

**Regra de boa prática:** scripts de aula e de carga de cenário devem ser reexecutáveis. O preço é apagar os dados a cada execução, o que em um cenário de estudo é exatamente o comportamento desejado. Em produção o raciocínio se inverte, e `DROP TABLE` deixa de ser uma opção.

### 4.7 A instrução completa

```sql
DROP TABLE IF EXISTS vendas_itens;

CREATE TABLE vendas_itens (
    id             INTEGER       GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    venda_id       INTEGER       NOT NULL,
    produto_id     INTEGER       NOT NULL,
    valor_unitario NUMERIC(10,2) NOT NULL,
    data_venda     DATE          NOT NULL,
    observacao     TEXT
);
```

A coluna `observacao` é a única sem `NOT NULL`. A ausência da restrição é o que autoriza a ausência do valor, e essa autorização é uma decisão de modelagem tomada na regra 5 do minimundo, não um esquecimento.

Conferência da tabela recém-criada, antes de qualquer inserção:

```sql
SELECT * FROM vendas_itens;
```

Seis colunas, nenhuma linha. O esquema existe, a instância está vazia.

### 4.8 Carga dos dados

```sql
INSERT INTO vendas_itens (venda_id, produto_id, valor_unitario, data_venda, observacao) VALUES
-- Cinco vendas com cinco itens cada (venda_id 2001 a 2005)
(2001,  1, 150.55, '2025-09-01', 'Entrega expressa'),
(2001,  3,  45.00, '2025-09-01', NULL),
(2001,  5,  12.75, '2025-09-01', NULL),
(2001,  9,  88.78, '2025-09-01', 'Item em promocao'),
(2001, 10,  10.00, '2025-09-01', NULL),

(2002,  2,  99.90, '2025-09-02', NULL),
(2002,  4, 220.00, '2025-09-02', 'Entrega agendada'),
(2002,  6,  60.00, '2025-09-02', NULL),
(2002,  8,  34.50, '2025-09-02', NULL),
(2002,  1, 150.55, '2025-09-02', 'Retirada na loja'),

(2003,  7, 199.99, '2025-09-03', NULL),
(2003,  9,  88.78, '2025-09-03', 'Troca autorizada'),
(2003,  3,  45.00, '2025-09-03', NULL),
(2003,  2,  99.90, '2025-09-03', NULL),
(2003,  5,  12.75, '2025-09-03', NULL),

(2004,  4, 220.00, '2025-09-04', 'Entrega expressa'),
(2004,  6,  60.00, '2025-09-04', NULL),
(2004,  1, 150.55, '2025-09-04', NULL),
(2004,  7, 199.99, '2025-09-04', 'Cliente preferencial'),
(2004, 10,  10.00, '2025-09-04', NULL),

(2005,  8,  34.50, '2025-09-05', NULL),
(2005,  9,  88.78, '2025-09-05', 'Retirada na loja'),
(2005,  2,  99.90, '2025-09-05', NULL),
(2005,  3,  45.00, '2025-09-05', NULL),
(2005,  4, 220.00, '2025-09-05', 'Entrega agendada'),

-- Quatro vendas com quatro itens cada (venda_id 2006 a 2009)
(2006,  1, 150.55, '2025-09-06', NULL),
(2006,  5,  12.75, '2025-09-06', NULL),
(2006,  9,  88.78, '2025-09-06', NULL),
(2006, 10,  10.00, '2025-09-06', NULL),

(2007,  7, 199.99, '2025-09-07', 'Item em promocao'),
(2007,  6,  60.00, '2025-09-07', NULL),
(2007,  8,  34.50, '2025-09-07', NULL),
(2007,  2,  99.90, '2025-09-07', NULL),

(2008,  3,  45.00, '2025-09-08', NULL),
(2008,  4, 220.00, '2025-09-08', 'Entrega expressa'),
(2008,  1, 150.55, '2025-09-08', NULL),
(2008,  9,  88.78, '2025-09-08', NULL),

(2009,  5,  12.75, '2025-09-09', NULL),
(2009, 10,  10.00, '2025-09-09', NULL),
(2009,  6,  60.00, '2025-09-09', NULL),
(2009,  7, 199.99, '2025-09-09', 'Retirada na loja'),

-- Duas vendas com dois itens cada (venda_id 2010 e 2011)
(2010,  2,  99.90, '2025-09-10', NULL),
(2010,  3,  45.00, '2025-09-10', NULL),

(2011,  8,  34.50, '2025-09-11', NULL),
(2011,  9,  88.78, '2025-09-11', NULL),

-- Cinco vendas com um item cada (venda_id 2012 a 2016)
(2012,  4, 220.00, '2025-09-12', 'Cliente preferencial'),
(2013,  1, 150.55, '2025-09-13', NULL),
(2014, 10,  10.00, '2025-09-14', NULL),
(2015,  5,  12.75, '2025-09-15', NULL),
(2016,  7, 199.99, '2025-09-16', 'Entrega agendada');
```

Três pontos merecem comentário nesta instrução.

**A lista de colunas está escrita.** Seria possível omiti-la e informar apenas os valores. Escrevê-la custa uma linha e protege contra a alteração futura da tabela: acrescentar uma coluna não quebra um `INSERT` que nomeia as suas colunas, e quebra silenciosamente um que dependa da posição.

**A palavra `NULL` aparece explicitamente.** Ela não é o texto `'NULL'` nem a cadeia vazia `''`. É a marca de ausência de valor, e por isso não vai entre aspas. Escrever `'NULL'` armazenaria quatro caracteres, e a coluna deixaria de estar vazia.

**Os comentários descrevem a estrutura dos dados, não o comando.** Um comentário que dissesse "insere linhas na tabela" repetiria o que o comando já diz. Os comentários úteis explicam o que não está escrito, neste caso a composição do conjunto de teste.

### 4.9 Conferência

```sql
SELECT * FROM vendas_itens;
```

A ferramenta deve informar **50 linhas**. Primeiras linhas do resultado:

| id | venda_id | produto_id | valor_unitario | data_venda | observacao |
|---|---|---|---|---|---|
| 1 | 2001 | 1 | 150.55 | 2025-09-01 | Entrega expressa |
| 2 | 2001 | 3 | 45.00 | 2025-09-01 | *nulo* |
| 3 | 2001 | 5 | 12.75 | 2025-09-01 | *nulo* |
| 4 | 2001 | 9 | 88.78 | 2025-09-01 | Item em promocao |
| 5 | 2001 | 10 | 10.00 | 2025-09-01 | *nulo* |

A ferramenta representa o valor nulo de alguma forma própria, em geral com a palavra `NULL` em destaque ou com uma célula vazia de estilo diferente. Essa marca de tela não é o conteúdo da célula.

Composição do conjunto, útil para conferir os exercícios:

| Grandeza | Valor |
|---|---|
| Linhas | 50 |
| Vendas distintas | 16, de 2001 a 2016 |
| Produtos distintos | 10, de 1 a 10 |
| Datas distintas | 16, de 2025-09-01 a 2025-09-16 |
| Itens com observação | 14 |
| Itens sem observação | 36 |
| Menor valor unitário | 10.00 |
| Maior valor unitário | 220.00 |

Cada produto tem sempre o mesmo valor unitário em todas as suas linhas, conforme a tabela abaixo. Essa uniformidade é justamente a redundância descrita na seção 4.5.

| produto_id | valor_unitario | Linhas |
|---|---|---|
| 1 | 150.55 | 6 |
| 2 | 99.90 | 5 |
| 3 | 45.00 | 5 |
| 4 | 220.00 | 5 |
| 5 | 12.75 | 5 |
| 6 | 60.00 | 4 |
| 7 | 199.99 | 5 |
| 8 | 34.50 | 4 |
| 9 | 88.78 | 6 |
| 10 | 10.00 | 5 |

---

## 5. Recuperação básica: retomada do arquivo 02

Três consultas retomam o que foi estabelecido no arquivo anterior, agora sobre o novo cenário.

### 5.1 Projeção

```sql
SELECT
    venda_id,
    produto_id,
    valor_unitario,
    data_venda
FROM
    vendas_itens;
```

Cinquenta linhas, quatro colunas. As colunas `id` e `observacao` não desapareceram da tabela, apenas não foram pedidas.

### 5.2 Filtro por igualdade

```sql
SELECT
    venda_id,
    produto_id,
    valor_unitario,
    data_venda
FROM
    vendas_itens
WHERE
    produto_id = 10;
```

Resultado completo, cinco linhas:

| venda_id | produto_id | valor_unitario | data_venda |
|---|---|---|---|
| 2001 | 10 | 10.00 | 2025-09-01 |
| 2004 | 10 | 10.00 | 2025-09-04 |
| 2006 | 10 | 10.00 | 2025-09-06 |
| 2009 | 10 | 10.00 | 2025-09-09 |
| 2014 | 10 | 10.00 | 2025-09-14 |

O número `10` não vai entre aspas, porque `produto_id` é do tipo `INTEGER`. Aspas simples delimitam texto e data, não número.

### 5.3 Todos os itens de uma venda

```sql
SELECT
    venda_id,
    data_venda,
    produto_id,
    valor_unitario
FROM
    vendas_itens
WHERE
    venda_id = 2001;
```

Resultado completo, cinco linhas:

| venda_id | data_venda | produto_id | valor_unitario |
|---|---|---|---|
| 2001 | 2025-09-01 | 1 | 150.55 |
| 2001 | 2025-09-01 | 3 | 45.00 |
| 2001 | 2025-09-01 | 5 | 12.75 |
| 2001 | 2025-09-01 | 9 | 88.78 |
| 2001 | 2025-09-01 | 10 | 10.00 |

A coluna `data_venda` repete o mesmo valor nas cinco linhas. Isso é outra face da redundância da seção 4.5: a data pertence à venda, não ao item, e está armazenada uma vez por item.

---

## 6. Operadores e expressões

Até aqui a lista do `SELECT` continha apenas nomes de coluna. Ela aceita **expressões**, isto é, cálculos feitos sobre os valores de cada linha.

### 6.1 Operadores aritméticos

| Operador | Operação | Exemplo | Resultado |
|---|---|---|---|
| `+` | Adição | `10 + 3` | `13` |
| `-` | Subtração | `10 - 3` | `7` |
| `*` | Multiplicação | `10 * 3` | `30` |
| `/` | Divisão | `10 / 3` | `3` |
| `%` | Resto da divisão | `10 % 3` | `1` |
| `^` | Potenciação | `10 ^ 3` | `1000` |

A linha da divisão contém uma armadilha e não um erro de digitação. Quando os dois operandos são inteiros, o PostgreSQL realiza **divisão inteira** e descarta a parte fracionária. `10 / 3` resulta `3`, e não `3.33`.

```sql
SELECT
    produto_id,
    produto_id / 3   AS divisao_inteira,
    produto_id % 3   AS resto,
    produto_id / 3.0 AS divisao_decimal
FROM
    vendas_itens
WHERE
    produto_id = 10;
```

| produto_id | divisao_inteira | resto | divisao_decimal |
|---|---|---|---|
| 10 | 3 | 1 | 3.3333333333333333… |

A quarta coluna difere da segunda apenas por dividir por `3.0` em lugar de `3`. Basta que um dos operandos seja decimal para que a divisão passe a ser decimal. As reticências indicam que o valor continua: a quantidade de casas decimais é escolhida pelo SGBD, como no caso de `AVG` tratado no arquivo 02.

A segunda coluna é a que interessa. `10 / 3` resultou `3` porque `produto_id` é inteiro e `3` também é. O SGBD não avisou que estava descartando a parte fracionária, porque, do ponto de vista dele, divisão de inteiros é uma operação bem definida que produz um inteiro.

**Regra de boa prática:** ao dividir, verificar o tipo dos dois operandos. Divisão inteira aplicada a um cálculo financeiro produz um resultado plausível e errado, que é a pior combinação possível.

### 6.2 Expressão na lista de colunas

O cenário permite calcular o valor de venda com um acréscimo de dez por cento sobre o valor unitário.

```sql
SELECT
    venda_id,
    produto_id,
    valor_unitario,
    valor_unitario * 1.1 AS valor_venda
FROM
    vendas_itens;
```

Primeiras linhas do resultado:

| venda_id | produto_id | valor_unitario | valor_venda |
|---|---|---|---|
| 2001 | 1 | 150.55 | 165.605 |
| 2001 | 3 | 45.00 | 49.500 |
| 2001 | 5 | 12.75 | 14.025 |
| 2001 | 9 | 88.78 | 97.658 |
| 2001 | 10 | 10.00 | 11.000 |
| 2002 | 2 | 99.90 | 109.890 |

Duas observações.

**A expressão é calculada por linha.** O resultado continua com 50 linhas. Uma expressão na lista do `SELECT` não agrupa nem resume nada, apenas acrescenta uma coluna calculada.

**O tipo do resultado tem três casas decimais.** Multiplicar um número de escala 2 por um de escala 1 produz um número de escala 3. O SGBD não arredonda por conta própria, porque arredondar é descartar informação, e ele não tem como saber se aquela informação era dispensável.

**A coluna calculada precisa de alias.** Sem `AS valor_venda`, o cabeçalho seria `?column?`, que é o modo do PostgreSQL de dizer que a expressão não tem nome. Uma coluna sem nome não pode ser referenciada em `ORDER BY` e torna o resultado ilegível.

### 6.3 Arredondamento da expressão

```sql
SELECT
    venda_id,
    produto_id,
    valor_unitario,
    ROUND(valor_unitario * 1.1, 2)                  AS valor_venda,
    ROUND(valor_unitario * 1.1, 2) - valor_unitario AS acrescimo
FROM
    vendas_itens;
```

Primeiras linhas do resultado:

| venda_id | produto_id | valor_unitario | valor_venda | acrescimo |
|---|---|---|---|---|
| 2001 | 1 | 150.55 | 165.61 | 15.06 |
| 2001 | 3 | 45.00 | 49.50 | 4.50 |
| 2001 | 5 | 12.75 | 14.03 | 1.28 |
| 2001 | 9 | 88.78 | 97.66 | 8.88 |
| 2001 | 10 | 10.00 | 11.00 | 1.00 |
| 2002 | 2 | 99.90 | 109.89 | 9.99 |

A expressão `ROUND(valor_unitario * 1.1, 2)` aparece duas vezes, uma em cada coluna calculada. Repetir a expressão é necessário porque o alias `valor_venda` só existe depois que a cláusula `SELECT` termina, e não pode ser usado dentro dela. A ordem lógica de execução, tratada no arquivo 02, explica a restrição.

### 6.4 Concatenação de texto

O operador `||` une valores de texto.

```sql
SELECT
    'Venda ' || venda_id || ', produto ' || produto_id AS descricao,
    valor_unitario
FROM
    vendas_itens
WHERE
    venda_id = 2010;
```

| descricao | valor_unitario |
|---|---|
| Venda 2010, produto 2 | 99.90 |
| Venda 2010, produto 3 | 45.00 |

Os números são convertidos para texto automaticamente. O espaço depois de `Venda` está dentro das aspas: o operador une exatamente o que recebe, sem acrescentar separador.

O operador `||` tem uma propriedade que costuma surpreender: **qualquer valor nulo em uma concatenação torna nulo o resultado inteiro**. Se `observacao` fosse concatenada e estivesse vazia, a descrição inteira desapareceria. O tratamento desse caso está na seção 7.6.

### 6.5 Operadores de comparação

| Operador | Significado |
|---|---|
| `=` | Igual a |
| `<>` | Diferente de |
| `!=` | Diferente de, sinônimo aceito pelo PostgreSQL |
| `<` | Menor que |
| `<=` | Menor ou igual a |
| `>` | Maior que |
| `>=` | Maior ou igual a |

O operador de igualdade é o sinal `=` isolado. O sinal duplo `==` não existe em SQL.

**Regra de boa prática:** preferir `<>` a `!=`. O primeiro é a forma da norma e funciona em qualquer SGBD. O segundo é uma cortesia do PostgreSQL.

### 6.6 Operadores lógicos

| Operador | Resultado verdadeiro quando |
|---|---|
| `AND` | As duas condições são verdadeiras |
| `OR` | Ao menos uma das condições é verdadeira |
| `NOT` | A condição é falsa |

SQL não trabalha com dois valores lógicos, e sim com três: verdadeiro, falso e **desconhecido**. O terceiro surge sempre que `NULL` participa de uma comparação, e o assunto é tratado na seção 7.6.

### 6.7 Precedência entre `AND` e `OR`

`NOT` é avaliado antes de `AND`, que é avaliado antes de `OR`. Essa ordem produz resultados corretos e inesperados quando os dois conectivos aparecem juntos.

```sql
-- Sem parenteses
SELECT
    venda_id, produto_id, valor_unitario, data_venda
FROM
    vendas_itens
WHERE
    data_venda = '2025-09-01' OR data_venda = '2025-09-02' AND valor_unitario > 100;
```

Resultado: **7 linhas**. O SGBD leu a condição como `data_venda = '2025-09-01' OR (data_venda = '2025-09-02' AND valor_unitario > 100)`, ou seja, todos os cinco itens do dia 1, mais os dois itens do dia 2 que passam de 100.

```sql
-- Com parenteses
SELECT
    venda_id, produto_id, valor_unitario, data_venda
FROM
    vendas_itens
WHERE
    (data_venda = '2025-09-01' OR data_venda = '2025-09-02') AND valor_unitario > 100;
```

Resultado: **3 linhas**.

| venda_id | produto_id | valor_unitario | data_venda |
|---|---|---|---|
| 2001 | 1 | 150.55 | 2025-09-01 |
| 2002 | 4 | 220.00 | 2025-09-02 |
| 2002 | 1 | 150.55 | 2025-09-02 |

Os dois comandos diferem por um par de parênteses e respondem a perguntas diferentes. Nenhum dos dois produz erro, e é por isso que o caso é perigoso: quem escreveu o primeiro pretendendo o segundo recebe um resultado maior e o aceita.

**Regra de boa prática:** sempre que `AND` e `OR` aparecerem na mesma condição, escrever os parênteses. Mesmo quando a precedência já produziria o resultado desejado, os parênteses documentam a intenção e dispensam quem lê de reconstruir a regra de mente.

---

## 7. A cláusula `WHERE` ampliada

Os operadores desta seção não acrescentam poder à linguagem: tudo o que eles fazem poderia ser escrito com comparações e conectivos lógicos. Eles acrescentam **legibilidade**, e legibilidade é o que separa uma consulta que pode ser mantida de uma que precisa ser reescrita.

### 7.1 `BETWEEN`

`BETWEEN` testa se um valor está dentro de um intervalo, com **ambos os extremos incluídos**.

```sql
SELECT
    venda_id, produto_id, valor_unitario, data_venda
FROM
    vendas_itens
WHERE
    valor_unitario BETWEEN 50 AND 100
ORDER BY
    valor_unitario DESC;
```

Resultado: **15 linhas**, distribuídas assim:

| valor_unitario | Linhas |
|---|---|
| 99.90 | 5 |
| 88.78 | 6 |
| 60.00 | 4 |

A forma equivalente com comparações é a que constava do código original:

```sql
WHERE valor_unitario >= 50 AND valor_unitario <= 100
```

As duas produzem o mesmo resultado. `BETWEEN` menciona a coluna uma vez em lugar de duas, o que elimina uma classe inteira de erro: escrever `valor_unitario >= 50 AND valor_unitário <= 100` com um deslize no segundo nome.

Dois cuidados.

**Os extremos entram.** `BETWEEN 50 AND 100` inclui `50` e `100`. Para excluí-los é preciso voltar às comparações com `>` e `<`.

**A ordem dos extremos importa.** `BETWEEN 100 AND 50` não devolve erro, devolve zero linhas, porque nenhum número é ao mesmo tempo maior que 100 e menor que 50. O menor valor vem primeiro.

`BETWEEN` também se aplica a datas:

```sql
SELECT
    venda_id, produto_id, valor_unitario, data_venda
FROM
    vendas_itens
WHERE
    data_venda BETWEEN '2025-09-01' AND '2025-09-03'
ORDER BY
    data_venda;
```

Resultado: **15 linhas**, os itens das vendas 2001, 2002 e 2003.

### 7.2 `NOT BETWEEN`

```sql
SELECT
    venda_id, produto_id, valor_unitario
FROM
    vendas_itens
WHERE
    valor_unitario NOT BETWEEN 50 AND 100
ORDER BY
    valor_unitario ASC;
```

Resultado: **35 linhas**, que é o complemento das 15 anteriores dentro das 50. O complemento fecha porque a coluna `valor_unitario` é `NOT NULL`. Com uma coluna que admitisse nulo, a soma não fecharia, pelo motivo da seção 7.6.

A condição do código original, escrita com `OR`, é outro modo de dizer quase o mesmo:

```sql
SELECT
    venda_id, produto_id, valor_unitario, data_venda
FROM
    vendas_itens
WHERE
    valor_unitario < 15
    OR valor_unitario > 180
ORDER BY
    valor_unitario ASC;
```

Resultado: **20 linhas**.

| valor_unitario | Linhas |
|---|---|
| 10.00 | 5 |
| 12.75 | 5 |
| 199.99 | 5 |
| 220.00 | 5 |

Essa consulta seleciona os extremos do catálogo: os itens muito baratos e os muito caros.

### 7.3 `IN`

`IN` testa se um valor pertence a uma lista.

```sql
SELECT
    venda_id, produto_id, valor_unitario, data_venda
FROM
    vendas_itens
WHERE
    produto_id IN (1, 3, 6)
ORDER BY
    produto_id ASC;
```

Resultado: **15 linhas**.

| produto_id | Linhas |
|---|---|
| 1 | 6 |
| 3 | 5 |
| 6 | 4 |

A forma equivalente com `OR` é `produto_id = 1 OR produto_id = 3 OR produto_id = 6`. Com três valores a diferença é de conforto. Com quinze, `IN` é a única forma legível, e evita o erro de precedência da seção 6.7, porque não mistura `AND` com `OR`.

### 7.4 `IN` combinado com outras condições

```sql
SELECT
    venda_id, produto_id, valor_unitario, data_venda
FROM
    vendas_itens
WHERE
    produto_id IN (1, 3, 6)
    AND (data_venda = '2025-09-01' OR data_venda = '2025-09-10');
```

Resultado completo, três linhas:

| venda_id | produto_id | valor_unitario | data_venda |
|---|---|---|---|
| 2001 | 1 | 150.55 | 2025-09-01 |
| 2001 | 3 | 45.00 | 2025-09-01 |
| 2010 | 3 | 45.00 | 2025-09-10 |

Os parênteses em torno do `OR` são obrigatórios aqui, e não decorativos. Sem eles a condição seria lida como `(produto_id IN (1,3,6) AND data_venda = '2025-09-01') OR data_venda = '2025-09-10'`, o que traria também o item do produto 2 no dia 10, que a pergunta não pedia.

A segunda condição também pode ser escrita com `IN`, o que dispensa os parênteses e deixa a intenção explícita:

```sql
WHERE
    produto_id IN (1, 3, 6)
    AND data_venda IN ('2025-09-01', '2025-09-10')
```

### 7.5 `NOT IN`

```sql
SELECT
    venda_id, produto_id, valor_unitario
FROM
    vendas_itens
WHERE
    produto_id NOT IN (1, 3, 6)
ORDER BY
    produto_id;
```

Resultado: **35 linhas**, os itens dos produtos 2, 4, 5, 7, 8, 9 e 10.

`NOT IN` guarda uma armadilha grave envolvendo `NULL`, tratada na seção 7.6.

### 7.6 `LIKE` e a comparação de padrões

`LIKE` compara texto contra um **padrão**, e não contra um valor exato. Dois caracteres têm significado especial dentro do padrão.

| Caractere | Significado |
|---|---|
| `%` | Qualquer sequência de caracteres, inclusive nenhuma |
| `_` | Exatamente um caractere, qualquer que seja |

```sql
SELECT
    venda_id, produto_id, observacao
FROM
    vendas_itens
WHERE
    observacao LIKE 'Entrega%';
```

Resultado completo, seis linhas:

| venda_id | produto_id | observacao |
|---|---|---|
| 2001 | 1 | Entrega expressa |
| 2002 | 4 | Entrega agendada |
| 2004 | 4 | Entrega expressa |
| 2005 | 4 | Entrega agendada |
| 2008 | 4 | Entrega expressa |
| 2016 | 7 | Entrega agendada |

Outros padrões sobre os mesmos dados:

| Padrão | Significa | Linhas |
|---|---|---|
| `'Entrega%'` | Começa com `Entrega` | 6 |
| `'%loja%'` | Contém `loja` em qualquer posição | 3 |
| `'%a'` | Termina com a letra `a` | 10 |
| `'_ntrega%'` | Um caractere qualquer, depois `ntrega`, depois qualquer coisa | 6 |
| `'Entrega'` | É exatamente `Entrega`, sem nada depois | 0 |

A última linha é a mais instrutiva. Sem nenhum caractere especial, `LIKE` comporta-se como `=`. O poder do operador está nos curingas, e um `LIKE` sem curinga é um `=` escrito de forma mais lenta.

### 7.7 `ILIKE` e a sensibilidade a maiúsculas

`LIKE` diferencia maiúsculas de minúsculas. `observacao LIKE 'entrega%'` devolve zero linhas, porque os dados registram `Entrega` com inicial maiúscula.

O PostgreSQL oferece `ILIKE`, que ignora a diferença:

```sql
SELECT
    venda_id, observacao
FROM
    vendas_itens
WHERE
    observacao ILIKE 'entrega%';
```

Resultado: as mesmas **seis linhas** do exemplo anterior.

**Regra de boa prática, com duas partes.** `ILIKE` é uma extensão do PostgreSQL e não existe na norma. Quando a portabilidade importa, a forma padronizada é `UPPER(observacao) LIKE 'ENTREGA%'`. E, em qualquer dos casos, um padrão que comece por `%` obriga o SGBD a examinar todas as linhas, porque nenhum índice comum consegue ajudar quando o começo do texto é desconhecido. Em uma tabela de 50 linhas isso é irrelevante. Em uma de dez milhões, é a diferença entre uma resposta imediata e uma consulta que não termina.

### 7.8 `NOT LIKE`

```sql
SELECT
    venda_id, observacao
FROM
    vendas_itens
WHERE
    observacao NOT LIKE 'Entrega%';
```

Resultado: **8 linhas**, e não 44.

As 50 linhas da tabela menos as 6 que começam com `Entrega` dariam 44. O resultado tem 8 porque as 36 linhas com `observacao` nula não entram. Esse é o assunto da próxima seção, e o exemplo mostra que ele não é uma curiosidade teórica.

### 7.9 `IS NULL`, `IS NOT NULL` e a lógica de três valores

`NULL` não é zero, não é a cadeia vazia e não é o texto `'NULL'`. É a **marca de ausência de valor**, e significa que o dado não existe ou é desconhecido.

A consequência é que `NULL` não pode ser comparado. A expressão `observacao = NULL` não é falsa: é **desconhecida**. Perguntar se um valor desconhecido é igual a outro valor desconhecido não tem resposta.

```sql
-- Devolve zero linhas, e nao as 36 esperadas
SELECT venda_id, observacao FROM vendas_itens WHERE observacao = NULL;
```

O comando não produz erro. Produz zero linhas, porque a cláusula `WHERE` só mantém a linha quando a condição é **verdadeira**, e desconhecido não é verdadeiro.

A forma correta usa os operadores próprios:

```sql
-- Itens sem observacao
SELECT
    venda_id, produto_id, valor_unitario
FROM
    vendas_itens
WHERE
    observacao IS NULL;
```

Resultado: **36 linhas**.

```sql
-- Itens com observacao
SELECT
    venda_id, produto_id, observacao
FROM
    vendas_itens
WHERE
    observacao IS NOT NULL
ORDER BY
    observacao;
```

Resultado: **14 linhas**.

| observacao | Linhas |
|---|---|
| Cliente preferencial | 2 |
| Entrega agendada | 3 |
| Entrega expressa | 3 |
| Item em promocao | 2 |
| Retirada na loja | 3 |
| Troca autorizada | 1 |

### 7.10 A armadilha de `NOT IN` com nulos

```sql
SELECT
    venda_id, observacao
FROM
    vendas_itens
WHERE
    observacao NOT IN ('Entrega expressa');
```

Resultado: **11 linhas**, e não 47.

Das 14 linhas com observação, 3 são `Entrega expressa`, restando 11. As 36 linhas nulas ficam de fora, porque para cada uma delas a pergunta "este valor desconhecido é diferente de `'Entrega expressa'`" não tem resposta.

O caso extremo é pior. Quando a própria lista contém um nulo, `NOT IN` devolve zero linhas sempre:

```sql
-- Devolve zero linhas, quaisquer que sejam os dados
SELECT venda_id FROM vendas_itens WHERE produto_id NOT IN (1, 3, NULL);
```

A explicação é a mesma. Para que a linha entre no resultado, `produto_id` precisa ser diferente de todos os elementos da lista, inclusive do nulo, e essa última comparação nunca é verdadeira.

**Regra de boa prática:** antes de escrever `NOT IN` ou `NOT LIKE`, verificar se a coluna admite nulo. Quando admitir, decidir de modo explícito o que fazer com as linhas nulas, e escrever essa decisão na consulta:

```sql
SELECT
    venda_id, observacao
FROM
    vendas_itens
WHERE
    observacao NOT IN ('Entrega expressa')
    OR observacao IS NULL;
```

Resultado: **47 linhas**, que é o complemento correto das 3 excluídas.

### 7.11 `COALESCE` e a apresentação de nulos

A função `COALESCE` recebe vários valores e devolve o primeiro que não for nulo. É o modo padronizado de substituir a ausência por um texto legível.

```sql
SELECT
    venda_id,
    produto_id,
    COALESCE(observacao, 'Sem observacao') AS observacao
FROM
    vendas_itens
WHERE
    venda_id = 2001;
```

| venda_id | produto_id | observacao |
|---|---|---|
| 2001 | 1 | Entrega expressa |
| 2001 | 3 | Sem observacao |
| 2001 | 5 | Sem observacao |
| 2001 | 9 | Item em promocao |
| 2001 | 10 | Sem observacao |

`COALESCE` altera a apresentação e não o dado armazenado. A coluna continua nula na tabela, e `IS NULL` continua encontrando aquelas linhas.

**Regra de boa prática:** substituir o nulo na apresentação, nunca no armazenamento. Gravar o texto `'Sem observacao'` na tabela destruiria a informação de que ali não havia observação alguma, e tornaria impossível distinguir a ausência de uma anotação que por acaso dissesse isso.

---

## 8. `DISTINCT`, `ORDER BY`, `LIMIT` e `OFFSET`

### 8.1 `DISTINCT`

Uma tabela SQL admite linhas repetidas, e um resultado de consulta também. `DISTINCT` remove as repetições do resultado.

```sql
SELECT DISTINCT
    valor_unitario
FROM
    vendas_itens
ORDER BY
    valor_unitario;
```

Resultado completo, dez linhas: `10.00`, `12.75`, `34.50`, `45.00`, `60.00`, `88.78`, `99.90`, `150.55`, `199.99`, `220.00`.

Cinquenta linhas produziram dez, que é a quantidade de valores unitários distintos praticados. Sem `DISTINCT`, a mesma consulta devolveria 50 linhas com muitas repetições.

### 8.2 `DISTINCT` opera sobre a linha inteira

`DISTINCT` não é um modificador de uma coluna, é um modificador do resultado. Ele elimina linhas idênticas em **todas** as colunas listadas.

```sql
SELECT DISTINCT
    produto_id,
    valor_unitario
FROM
    vendas_itens
ORDER BY
    produto_id;
```

Resultado completo, dez linhas:

| produto_id | valor_unitario |
|---|---|
| 1 | 150.55 |
| 2 | 99.90 |
| 3 | 45.00 |
| 4 | 220.00 |
| 5 | 12.75 |
| 6 | 60.00 |
| 7 | 199.99 |
| 8 | 34.50 |
| 9 | 88.78 |
| 10 | 10.00 |

Este resultado é uma descoberta sobre os dados, e não apenas um exercício de sintaxe: dez produtos e dez pares distintos significam que **cada produto tem um único valor unitário em toda a tabela**. Se algum produto tivesse sido vendido por dois preços diferentes, apareceriam onze ou mais linhas.

Acrescentar `venda_id` à lista devolveria as 50 linhas, porque a combinação das três colunas é distinta em cada uma delas.

### 8.3 `ORDER BY` com vários critérios

```sql
SELECT
    venda_id,
    produto_id,
    valor_unitario
FROM
    vendas_itens
ORDER BY
    valor_unitario DESC,
    venda_id ASC,
    produto_id ASC;
```

Os critérios são aplicados em cadeia: o segundo só decide entre linhas empatadas no primeiro, e o terceiro só entre as empatadas nos dois anteriores. Cada critério tem o seu próprio `ASC` ou `DESC`.

Primeiras linhas do resultado:

| venda_id | produto_id | valor_unitario |
|---|---|---|
| 2002 | 4 | 220.00 |
| 2004 | 4 | 220.00 |
| 2005 | 4 | 220.00 |
| 2008 | 4 | 220.00 |
| 2012 | 4 | 220.00 |
| 2003 | 7 | 199.99 |

Este `ORDER BY` é **determinado**: como a combinação das três colunas não se repete, não há empate possível na última posição, e o resultado é sempre o mesmo. Ordenar só por `valor_unitario` deixaria a ordem entre os cinco itens de 220.00 indefinida.

### 8.4 A posição dos nulos na ordenação

Um valor nulo não é maior nem menor que os demais, e o SGBD precisa de uma regra para colocá-lo em algum lugar. No PostgreSQL, o padrão é considerar o nulo como o maior valor: ele vai para o fim em `ASC` e para o começo em `DESC`.

A regra pode ser declarada:

```sql
SELECT
    venda_id,
    observacao
FROM
    vendas_itens
ORDER BY
    observacao ASC NULLS FIRST;
```

As 36 linhas nulas aparecem primeiro, e depois as 14 com texto, em ordem alfabética.

**Regra de boa prática:** quando a coluna de ordenação admite nulo e a posição deles importa para quem vai ler, escrever `NULLS FIRST` ou `NULLS LAST`. O padrão do PostgreSQL não é o mesmo de todos os SGBDs.

### 8.5 `LIMIT` e `OFFSET`

`LIMIT` recorta a quantidade de linhas. `OFFSET` descarta linhas do começo antes do recorte. Juntos, produzem páginas.

```sql
-- Pagina 1
SELECT
    venda_id, produto_id, valor_unitario
FROM
    vendas_itens
ORDER BY
    valor_unitario DESC, venda_id ASC, produto_id ASC
LIMIT 5 OFFSET 0;
```

| venda_id | produto_id | valor_unitario |
|---|---|---|
| 2002 | 4 | 220.00 |
| 2004 | 4 | 220.00 |
| 2005 | 4 | 220.00 |
| 2008 | 4 | 220.00 |
| 2012 | 4 | 220.00 |

```sql
-- Pagina 2
SELECT
    venda_id, produto_id, valor_unitario
FROM
    vendas_itens
ORDER BY
    valor_unitario DESC, venda_id ASC, produto_id ASC
LIMIT 5 OFFSET 5;
```

| venda_id | produto_id | valor_unitario |
|---|---|---|
| 2003 | 7 | 199.99 |
| 2004 | 7 | 199.99 |
| 2007 | 7 | 199.99 |
| 2009 | 7 | 199.99 |
| 2016 | 7 | 199.99 |

```sql
-- Pagina 3
SELECT
    venda_id, produto_id, valor_unitario
FROM
    vendas_itens
ORDER BY
    valor_unitario DESC, venda_id ASC, produto_id ASC
LIMIT 5 OFFSET 10;
```

| venda_id | produto_id | valor_unitario |
|---|---|---|
| 2001 | 1 | 150.55 |
| 2002 | 1 | 150.55 |
| 2004 | 1 | 150.55 |
| 2006 | 1 | 150.55 |
| 2008 | 1 | 150.55 |

A relação entre número da página e `OFFSET` é `OFFSET = (pagina - 1) * LIMIT`.

**Regra de boa prática, e a razão de ser desta seção.** `OFFSET` sem um `ORDER BY` determinado é um defeito, não um estilo. Sem ordem garantida, a página 2 pode repetir uma linha que já apareceu na página 1 e omitir outra que nunca aparecerá. O `ORDER BY` usado nos três comandos acima tem três critérios exatamente por isso: ele não deixa empate algum sem resolver.

Um segundo ponto vale registrar. `OFFSET 1000` obriga o SGBD a produzir as mil primeiras linhas e descartá-las. O custo cresce com o número da página, e por isso a paginação por `OFFSET`, correta e adequada em telas de consulta, não é a técnica indicada para percorrer tabelas muito grandes do início ao fim.

---

## 9. Funções de agregação, `GROUP BY` e `HAVING`

Uma função de agregação recebe um conjunto de linhas e devolve um único valor. É a operação que responde a perguntas sobre o conjunto, e não sobre cada linha.

### 9.1 As funções

| Função | Devolve |
|---|---|
| `COUNT(*)` | Quantidade de linhas |
| `COUNT(coluna)` | Quantidade de linhas em que a coluna **não é nula** |
| `COUNT(DISTINCT coluna)` | Quantidade de valores distintos e não nulos da coluna |
| `SUM(coluna)` | Soma dos valores |
| `AVG(coluna)` | Média aritmética dos valores |
| `MIN(coluna)` | Menor valor |
| `MAX(coluna)` | Maior valor |

Todas ignoram os valores nulos, com a única exceção de `COUNT(*)`, que conta linhas e não valores.

```sql
SELECT
    COUNT(*)                  AS itens,
    COUNT(observacao)         AS itens_com_observacao,
    COUNT(DISTINCT venda_id)  AS vendas,
    COUNT(DISTINCT produto_id) AS produtos,
    SUM(valor_unitario)       AS soma,
    ROUND(AVG(valor_unitario), 2) AS media,
    MIN(valor_unitario)       AS menor,
    MAX(valor_unitario)       AS maior
FROM
    vendas_itens;
```

Resultado, uma única linha:

| itens | itens_com_observacao | vendas | produtos | soma | media | menor | maior |
|---|---|---|---|---|---|---|---|
| 50 | 14 | 16 | 10 | 4752.18 | 95.04 | 10.00 | 220.00 |

Sem `GROUP BY`, a tabela inteira é tratada como um único grupo, e o resultado tem exatamente uma linha.

### 9.2 `COUNT(*)` e `COUNT(coluna)` não são a mesma coisa

A diferença entre `50` e `14` na tabela acima é a resposta a duas perguntas distintas. `COUNT(*)` pergunta quantos itens existem. `COUNT(observacao)` pergunta quantos itens têm observação.

Escrever `COUNT(observacao)` pretendendo contar linhas é um dos erros mais difíceis de perceber, porque o comando funciona, o número é plausível e só está errado quando há nulos.

**Regra de boa prática:** para contar linhas, `COUNT(*)`. `COUNT(coluna)` apenas quando a intenção for justamente descartar os nulos, e nesse caso convém deixar isso claro no alias, como em `itens_com_observacao`.

### 9.3 `AVG` e o arredondamento

`AVG` sobre uma coluna `NUMERIC` devolve `NUMERIC` com casas decimais adicionais, pelo mesmo motivo discutido no arquivo 02: a divisão preserva dígitos para não descartar informação. Toda média destinada à leitura passa por `ROUND`.

Um segundo cuidado, este de natureza estatística. A média calculada acima é a média do **valor unitário por item**, e não o valor médio de uma venda. As duas perguntas são diferentes, e a diferença fica evidente na seção 9.4: uma venda com cinco itens contribui com cinco valores para a primeira média e com um único total para a segunda.

### 9.4 `GROUP BY` por uma coluna

```sql
SELECT
    venda_id,
    SUM(valor_unitario) AS valor_total,
    data_venda
FROM
    vendas_itens
GROUP BY
    venda_id, data_venda
ORDER BY
    valor_total ASC;
```

Resultado completo, dezesseis linhas:

| venda_id | valor_total | data_venda |
|---|---|---|
| 2014 | 10.00 | 2025-09-14 |
| 2015 | 12.75 | 2025-09-15 |
| 2011 | 123.28 | 2025-09-11 |
| 2010 | 144.90 | 2025-09-10 |
| 2013 | 150.55 | 2025-09-13 |
| 2016 | 199.99 | 2025-09-16 |
| 2012 | 220.00 | 2025-09-12 |
| 2006 | 262.08 | 2025-09-06 |
| 2009 | 282.74 | 2025-09-09 |
| 2001 | 307.08 | 2025-09-01 |
| 2007 | 394.39 | 2025-09-07 |
| 2003 | 446.42 | 2025-09-03 |
| 2005 | 488.18 | 2025-09-05 |
| 2008 | 504.33 | 2025-09-08 |
| 2002 | 564.95 | 2025-09-02 |
| 2004 | 640.54 | 2025-09-04 |

Cinquenta linhas produziram dezesseis, uma por venda. Esta é a consulta que transforma itens em vendas, e é o resultado que um relatório de faturamento diário utilizaria.

**A cláusula `GROUP BY` lista duas colunas.** A coluna `data_venda` aparece na lista do `SELECT` sem estar dentro de uma função de agregação, e portanto precisa constar do `GROUP BY`, pela regra estabelecida no arquivo 02. Neste caso o acréscimo não altera o agrupamento, porque todos os itens de uma venda têm a mesma data. Mas o SGBD não sabe disso: para ele, `data_venda` poderia variar dentro do grupo, e recusa-se a escolher um valor. A alternativa seria `MAX(data_venda)`, que declara explicitamente qual valor tomar.

### 9.5 `GROUP BY` por outra coluna

```sql
SELECT
    produto_id,
    SUM(valor_unitario) AS valor_final,
    COUNT(*)            AS vezes_vendido
FROM
    vendas_itens
GROUP BY
    produto_id
ORDER BY
    valor_final ASC;
```

Resultado completo, dez linhas:

| produto_id | valor_final | vezes_vendido |
|---|---|---|
| 10 | 50.00 | 5 |
| 5 | 63.75 | 5 |
| 8 | 138.00 | 4 |
| 3 | 225.00 | 5 |
| 6 | 240.00 | 4 |
| 2 | 499.50 | 5 |
| 9 | 532.68 | 6 |
| 1 | 903.30 | 6 |
| 7 | 999.95 | 5 |
| 4 | 1100.00 | 5 |

Os mesmos 50 itens, agrupados por outro critério, respondem a outra pergunta. O produto 9 foi vendido mais vezes que o produto 7, e ainda assim rendeu menos: a coluna `vezes_vendido` ao lado do total é o que permite enxergar isso.

### 9.6 `GROUP BY` por várias colunas

Quando o `GROUP BY` lista mais de uma coluna, cada **combinação distinta** de valores forma um grupo.

```sql
SELECT
    data_venda,
    produto_id,
    COUNT(*) AS itens
FROM
    vendas_itens
WHERE
    data_venda BETWEEN '2025-09-01' AND '2025-09-02'
GROUP BY
    data_venda, produto_id
ORDER BY
    data_venda, produto_id;
```

Resultado completo, dez linhas:

| data_venda | produto_id | itens |
|---|---|---|
| 2025-09-01 | 1 | 1 |
| 2025-09-01 | 3 | 1 |
| 2025-09-01 | 5 | 1 |
| 2025-09-01 | 9 | 1 |
| 2025-09-01 | 10 | 1 |
| 2025-09-02 | 1 | 1 |
| 2025-09-02 | 2 | 1 |
| 2025-09-02 | 4 | 1 |
| 2025-09-02 | 6 | 1 |
| 2025-09-02 | 8 | 1 |

Cada combinação de data e produto ocorre uma única vez neste cenário, o que faz a coluna `itens` valer `1` em todas as linhas. O resultado é correto e revela uma característica dos dados: nenhum produto se repete dentro da mesma venda.

### 9.7 A cláusula `HAVING`

`HAVING` filtra **grupos**, depois que a agregação foi calculada. `WHERE` filtra **linhas**, antes do agrupamento. As duas cláusulas não são intercambiáveis, e a diferença decorre da ordem lógica de execução.

```sql
-- Vendas cujo total passa de 400
SELECT
    venda_id,
    SUM(valor_unitario) AS valor_total,
    COUNT(*)            AS itens
FROM
    vendas_itens
GROUP BY
    venda_id
HAVING
    SUM(valor_unitario) > 400
ORDER BY
    valor_total DESC;
```

Resultado completo, cinco linhas:

| venda_id | valor_total | itens |
|---|---|---|
| 2004 | 640.54 | 5 |
| 2002 | 564.95 | 5 |
| 2008 | 504.33 | 4 |
| 2005 | 488.18 | 5 |
| 2003 | 446.42 | 5 |

A condição `SUM(valor_unitario) > 400` não poderia estar na cláusula `WHERE`, porque no momento em que `WHERE` é avaliada nenhuma soma existe ainda. A tentativa produz:

```
ERROR:  aggregate functions are not allowed in WHERE
```

### 9.8 `HAVING` com `COUNT`

```sql
-- Vendas com cinco itens ou mais
SELECT
    venda_id,
    COUNT(*)            AS itens,
    SUM(valor_unitario) AS valor_total
FROM
    vendas_itens
GROUP BY
    venda_id
HAVING
    COUNT(*) >= 5
ORDER BY
    venda_id;
```

Resultado completo, cinco linhas:

| venda_id | itens | valor_total |
|---|---|---|
| 2001 | 5 | 307.08 |
| 2002 | 5 | 564.95 |
| 2003 | 5 | 446.42 |
| 2004 | 5 | 640.54 |
| 2005 | 5 | 488.18 |

A expressão `COUNT(*)` está repetida no `SELECT` e no `HAVING`. Pela mesma razão já vista, o alias `itens` não pode ser usado na condição: `HAVING` é avaliada antes de `SELECT`.

### 9.9 `WHERE`, `GROUP BY` e `HAVING` na mesma consulta

```sql
-- Considerando apenas os itens de 50 reais ou mais,
-- as vendas cujo subtotal passa de 300
SELECT
    venda_id,
    COUNT(*)            AS itens_considerados,
    SUM(valor_unitario) AS subtotal
FROM
    vendas_itens
WHERE
    valor_unitario >= 50
GROUP BY
    venda_id
HAVING
    SUM(valor_unitario) > 300
ORDER BY
    subtotal DESC;
```

Resultado completo, seis linhas:

| venda_id | itens_considerados | subtotal |
|---|---|---|
| 2004 | 4 | 630.54 |
| 2002 | 4 | 530.45 |
| 2008 | 3 | 459.33 |
| 2005 | 3 | 408.68 |
| 2003 | 3 | 388.67 |
| 2007 | 3 | 359.89 |

Comparar esta tabela com a da seção 9.4 mostra o efeito do `WHERE`. A venda 2004 tem cinco itens e total `640.54`. Aqui aparece com quatro itens e `630.54`, porque o item de `10.00` foi descartado **antes** do agrupamento e nunca chegou a compor a soma.

O percurso completo da consulta:

```
FROM       obtem as 50 linhas
WHERE      descarta os itens abaixo de 50, restam 30
GROUP BY   reune as linhas restantes por venda, formando 13 grupos
HAVING     descarta os grupos com subtotal ate 300, restam 6
SELECT     calcula as colunas do resultado
ORDER BY   ordena pelo subtotal
```

**Regra de boa prática:** filtrar o quanto for possível na cláusula `WHERE`. Toda linha eliminada antes do agrupamento é uma linha a menos para agrupar. Reservar `HAVING` para o que só pode ser decidido depois do cálculo.

### 9.10 Uma função de agregação sobre texto

O conjunto de funções do PostgreSQL vai além das sete da seção 9.1. Uma delas é útil aqui e ilustra um ponto sobre agregação em geral:

```sql
SELECT
    venda_id,
    COUNT(*)          AS itens,
    COUNT(observacao) AS com_observacao,
    STRING_AGG(observacao, ' | ' ORDER BY id) AS observacoes
FROM
    vendas_itens
GROUP BY
    venda_id
ORDER BY
    venda_id
LIMIT 5;
```

| venda_id | itens | com_observacao | observacoes |
|---|---|---|---|
| 2001 | 5 | 2 | Entrega expressa \| Item em promocao |
| 2002 | 5 | 2 | Entrega agendada \| Retirada na loja |
| 2003 | 5 | 1 | Troca autorizada |
| 2004 | 5 | 2 | Entrega expressa \| Cliente preferencial |
| 2005 | 5 | 2 | Retirada na loja \| Entrega agendada |

`STRING_AGG` concatena os valores de um grupo, separando-os pelo texto indicado. Os nulos são ignorados, como em toda função de agregação.

O detalhe que importa é o `ORDER BY id` **dentro** dos parênteses da função. Sem ele, a ordem em que os textos são concatenados não é garantida, e o resultado poderia mudar entre execuções. A ordem dentro de um grupo, assim como a ordem do resultado, precisa ser pedida quando importa.

---

## 10. Boas práticas consolidadas

Cada regra abaixo apareceu junto ao comando que a motivou. Reunidas, formam a lista de verificação a aplicar antes de considerar uma consulta pronta.

### 10.1 Definição de dados

| Regra | Razão |
|---|---|
| `NUMERIC` com escala explícita para dinheiro | Ponto flutuante acumula erro de centavos |
| `GENERATED ALWAYS AS IDENTITY` em vez de `SERIAL` | Forma da norma, e recusa a inserção manual que dessincroniza a sequência |
| `DROP TABLE IF EXISTS` antes de `CREATE TABLE` em script de cenário | Torna o script reexecutável e garante a estrutura escrita no arquivo |
| `NOT NULL` em toda coluna cujo valor é obrigatório | A omissão autoriza dados incompletos que ninguém pediu |
| Nomes em minúscula, sem acento, com sublinhado | Dispensa aspas duplas em toda referência futura |
| Um banco de dados por minimundo | Um banco é a fronteira de um universo de discurso |

### 10.2 Escrita de consultas

| Regra | Razão |
|---|---|
| Listar as colunas em vez de `SELECT *` | O resultado não muda sozinho quando a tabela muda |
| Listar as colunas no `INSERT` | Protege contra a alteração da estrutura da tabela |
| Alias em toda coluna calculada | Sem alias o cabeçalho é `?column?` e a coluna não pode ser ordenada |
| Parênteses sempre que `AND` e `OR` convivem | A precedência produz resultados corretos e inesperados |
| `BETWEEN` e `IN` em lugar de cadeias de comparação | Menciona a coluna uma vez, e não mistura conectivos |
| `<>` em vez de `!=` | Forma da norma |
| `ORDER BY` determinado sempre que houver `LIMIT` ou `OFFSET` | Sem ele, páginas repetem e omitem linhas |
| `COUNT(*)` para contar linhas | `COUNT(coluna)` descarta nulos silenciosamente |
| `ROUND` em toda média destinada à leitura | `AVG` não arredonda |
| Filtrar no `WHERE` o que não depende da agregação | Cada linha eliminada antes é uma linha a menos para agrupar |

### 10.3 Tratamento de nulos

| Regra | Razão |
|---|---|
| `IS NULL` e `IS NOT NULL`, nunca `= NULL` | A comparação com nulo é desconhecida, e desconhecido não é verdadeiro |
| Verificar a coluna antes de escrever `NOT IN` ou `NOT LIKE` | As linhas nulas não entram no complemento |
| `COALESCE` na apresentação, nunca no armazenamento | Gravar um texto no lugar do nulo destrói a informação de ausência |

### 10.4 Legibilidade

| Regra | Razão |
|---|---|
| Palavras reservadas em maiúscula, identificadores em minúscula | Separa visualmente a linguagem dos nomes do minimundo |
| Uma cláusula por linha, colunas indentadas | Permite ler a consulta pela borda esquerda |
| Comentário que explica o que o comando não diz | Um comentário que repete o comando envelhece e passa a mentir |

O tratamento estendido está em `referencia/04-boas-praticas-sql.md`.

---

## 11. Erros frequentes e leitura das mensagens

| Mensagem ou sintoma | Causa | Correção |
|---|---|---|
| `database "bd_vendas" already exists` | `CREATE DATABASE` executado duas vezes | Nenhuma, o banco já existe |
| `CREATE DATABASE cannot run inside a transaction block` | O comando foi enviado junto com outros | Executar a instrução isoladamente |
| `relation "vendas_itens" does not exist` | Conexão apontando para `bd_aula` | Conferir a linha `-- Active:` e a conexão selecionada |
| `cannot insert a non-DEFAULT value into column "id"` | A coluna `id` foi informada no `INSERT` | Omitir `id` da lista de colunas |
| `column "valor_venda" does not exist` | Alias usado em `WHERE` ou em outra coluna do mesmo `SELECT` | Repetir a expressão |
| `aggregate functions are not allowed in WHERE` | Função de agregação na cláusula `WHERE` | Passar a condição para `HAVING` |
| `column "vendas_itens.data_venda" must appear in the GROUP BY clause` | Coluna não agregada fora do `GROUP BY` | Acrescentá-la ao `GROUP BY` ou envolvê-la em uma função |
| `operator does not exist: text >= integer` | Comparação entre tipos incompatíveis | Conferir aspas: `'50'` é texto, `50` é número |
| `numeric field overflow` | Valor acima do que `NUMERIC(10,2)` comporta | Conferir o dado, ou a precisão declarada |
| `WHERE observacao = NULL` devolve zero linhas | Comparação com nulo | Usar `IS NULL` |
| `NOT IN` devolve menos linhas que o esperado | A coluna admite nulo | Acrescentar `OR coluna IS NULL` |
| `NOT LIKE` devolve menos linhas que o esperado | A coluna admite nulo | Acrescentar `OR coluna IS NULL` |
| `LIKE 'entrega%'` devolve zero linhas | `LIKE` diferencia maiúsculas | Usar `ILIKE` ou corrigir a caixa do padrão |
| `BETWEEN 100 AND 50` devolve zero linhas | Extremos invertidos | O menor valor vem primeiro |
| Divisão devolve inteiro | Os dois operandos são inteiros | Tornar um deles decimal |
| Cabeçalho `?column?` | Coluna calculada sem alias | Acrescentar `AS` |

Duas linhas dessa tabela não descrevem erro algum, e sim resultado inesperado sem erro. São as mais perigosas: o SGBD compreendeu o comando e respondeu à pergunta que foi feita, que não era a pretendida.

---

## 12. Script consolidado

Todo o código do arquivo, na ordem de execução.

```sql
-- ===============================================================
-- ETAPA 1. Criacao do banco
-- Executar com a conexao apontando para bd_aula.
-- Executar esta instrucao isoladamente.
-- ===============================================================
CREATE DATABASE bd_vendas;

-- ===============================================================
-- ETAPA 2. Trocar a conexao para bd_vendas antes de prosseguir
-- ===============================================================
-- Active: 1787177433004@@127.0.0.1@5432@bd_vendas@public

-- ---------------------------------------------------------------
-- 2.1 Estrutura
-- ---------------------------------------------------------------
DROP TABLE IF EXISTS vendas_itens;

CREATE TABLE vendas_itens (
    id             INTEGER       GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    venda_id       INTEGER       NOT NULL,
    produto_id     INTEGER       NOT NULL,
    valor_unitario NUMERIC(10,2) NOT NULL,
    data_venda     DATE          NOT NULL,
    observacao     TEXT
);

-- Esquema criado, instancia vazia: seis colunas, nenhuma linha
SELECT * FROM vendas_itens;

-- ---------------------------------------------------------------
-- 2.2 Carga
-- ---------------------------------------------------------------
INSERT INTO vendas_itens (venda_id, produto_id, valor_unitario, data_venda, observacao) VALUES
-- Cinco vendas com cinco itens cada (venda_id 2001 a 2005)
(2001,  1, 150.55, '2025-09-01', 'Entrega expressa'),
(2001,  3,  45.00, '2025-09-01', NULL),
(2001,  5,  12.75, '2025-09-01', NULL),
(2001,  9,  88.78, '2025-09-01', 'Item em promocao'),
(2001, 10,  10.00, '2025-09-01', NULL),

(2002,  2,  99.90, '2025-09-02', NULL),
(2002,  4, 220.00, '2025-09-02', 'Entrega agendada'),
(2002,  6,  60.00, '2025-09-02', NULL),
(2002,  8,  34.50, '2025-09-02', NULL),
(2002,  1, 150.55, '2025-09-02', 'Retirada na loja'),

(2003,  7, 199.99, '2025-09-03', NULL),
(2003,  9,  88.78, '2025-09-03', 'Troca autorizada'),
(2003,  3,  45.00, '2025-09-03', NULL),
(2003,  2,  99.90, '2025-09-03', NULL),
(2003,  5,  12.75, '2025-09-03', NULL),

(2004,  4, 220.00, '2025-09-04', 'Entrega expressa'),
(2004,  6,  60.00, '2025-09-04', NULL),
(2004,  1, 150.55, '2025-09-04', NULL),
(2004,  7, 199.99, '2025-09-04', 'Cliente preferencial'),
(2004, 10,  10.00, '2025-09-04', NULL),

(2005,  8,  34.50, '2025-09-05', NULL),
(2005,  9,  88.78, '2025-09-05', 'Retirada na loja'),
(2005,  2,  99.90, '2025-09-05', NULL),
(2005,  3,  45.00, '2025-09-05', NULL),
(2005,  4, 220.00, '2025-09-05', 'Entrega agendada'),

-- Quatro vendas com quatro itens cada (venda_id 2006 a 2009)
(2006,  1, 150.55, '2025-09-06', NULL),
(2006,  5,  12.75, '2025-09-06', NULL),
(2006,  9,  88.78, '2025-09-06', NULL),
(2006, 10,  10.00, '2025-09-06', NULL),

(2007,  7, 199.99, '2025-09-07', 'Item em promocao'),
(2007,  6,  60.00, '2025-09-07', NULL),
(2007,  8,  34.50, '2025-09-07', NULL),
(2007,  2,  99.90, '2025-09-07', NULL),

(2008,  3,  45.00, '2025-09-08', NULL),
(2008,  4, 220.00, '2025-09-08', 'Entrega expressa'),
(2008,  1, 150.55, '2025-09-08', NULL),
(2008,  9,  88.78, '2025-09-08', NULL),

(2009,  5,  12.75, '2025-09-09', NULL),
(2009, 10,  10.00, '2025-09-09', NULL),
(2009,  6,  60.00, '2025-09-09', NULL),
(2009,  7, 199.99, '2025-09-09', 'Retirada na loja'),

-- Duas vendas com dois itens cada (venda_id 2010 e 2011)
(2010,  2,  99.90, '2025-09-10', NULL),
(2010,  3,  45.00, '2025-09-10', NULL),

(2011,  8,  34.50, '2025-09-11', NULL),
(2011,  9,  88.78, '2025-09-11', NULL),

-- Cinco vendas com um item cada (venda_id 2012 a 2016)
(2012,  4, 220.00, '2025-09-12', 'Cliente preferencial'),
(2013,  1, 150.55, '2025-09-13', NULL),
(2014, 10,  10.00, '2025-09-14', NULL),
(2015,  5,  12.75, '2025-09-15', NULL),
(2016,  7, 199.99, '2025-09-16', 'Entrega agendada');

-- Conferencia: 50 linhas
SELECT * FROM vendas_itens;

-- ===============================================================
-- ETAPA 3. Recuperacao basica
-- ===============================================================
SELECT
    venda_id,
    produto_id,
    valor_unitario,
    data_venda
FROM
    vendas_itens;

-- Todos os itens do produto 10
SELECT
    venda_id,
    produto_id,
    valor_unitario,
    data_venda
FROM
    vendas_itens
WHERE
    produto_id = 10;

-- Todos os itens da venda 2001
SELECT
    venda_id,
    data_venda,
    produto_id,
    valor_unitario
FROM
    vendas_itens
WHERE
    venda_id = 2001;

-- ===============================================================
-- ETAPA 4. Operadores e expressoes
-- ===============================================================
-- Divisao inteira, resto e divisao decimal
SELECT
    produto_id,
    produto_id / 3   AS divisao_inteira,
    produto_id % 3   AS resto,
    produto_id / 3.0 AS divisao_decimal
FROM
    vendas_itens
WHERE
    produto_id = 10;

-- Acrescimo de dez por cento
SELECT
    venda_id,
    produto_id,
    valor_unitario,
    valor_unitario * 1.1 AS valor_venda
FROM
    vendas_itens;

-- O mesmo, arredondado para duas casas
SELECT
    venda_id,
    produto_id,
    valor_unitario,
    ROUND(valor_unitario * 1.1, 2)                  AS valor_venda,
    ROUND(valor_unitario * 1.1, 2) - valor_unitario AS acrescimo
FROM
    vendas_itens;

-- Concatenacao de texto
SELECT
    'Venda ' || venda_id || ', produto ' || produto_id AS descricao,
    valor_unitario
FROM
    vendas_itens
WHERE
    venda_id = 2010;

-- Precedencia: sem parenteses, 7 linhas
SELECT
    venda_id, produto_id, valor_unitario, data_venda
FROM
    vendas_itens
WHERE
    data_venda = '2025-09-01' OR data_venda = '2025-09-02' AND valor_unitario > 100;

-- Precedencia: com parenteses, 3 linhas
SELECT
    venda_id, produto_id, valor_unitario, data_venda
FROM
    vendas_itens
WHERE
    (data_venda = '2025-09-01' OR data_venda = '2025-09-02') AND valor_unitario > 100;

-- ===============================================================
-- ETAPA 5. WHERE ampliado
-- ===============================================================
-- BETWEEN sobre numero: 15 linhas
SELECT
    venda_id, produto_id, valor_unitario, data_venda
FROM
    vendas_itens
WHERE
    valor_unitario BETWEEN 50 AND 100
ORDER BY
    valor_unitario DESC;

-- A forma equivalente com comparacoes
SELECT
    venda_id, produto_id, valor_unitario, data_venda
FROM
    vendas_itens
WHERE
    valor_unitario >= 50
    AND valor_unitario <= 100
ORDER BY
    valor_unitario DESC;

-- BETWEEN sobre data: 15 linhas
SELECT
    venda_id, produto_id, valor_unitario, data_venda
FROM
    vendas_itens
WHERE
    data_venda BETWEEN '2025-09-01' AND '2025-09-03'
ORDER BY
    data_venda;

-- NOT BETWEEN: 35 linhas
SELECT
    venda_id, produto_id, valor_unitario
FROM
    vendas_itens
WHERE
    valor_unitario NOT BETWEEN 50 AND 100
ORDER BY
    valor_unitario ASC;

-- Os extremos do catalogo: 20 linhas
SELECT
    venda_id, produto_id, valor_unitario, data_venda
FROM
    vendas_itens
WHERE
    valor_unitario < 15
    OR valor_unitario > 180
ORDER BY
    valor_unitario ASC;

-- IN: 15 linhas
SELECT
    venda_id, produto_id, valor_unitario, data_venda
FROM
    vendas_itens
WHERE
    produto_id IN (1, 3, 6)
ORDER BY
    produto_id ASC;

-- IN com outra condicao entre parenteses: 3 linhas
SELECT
    venda_id, produto_id, valor_unitario, data_venda
FROM
    vendas_itens
WHERE
    produto_id IN (1, 3, 6)
    AND (data_venda = '2025-09-01' OR data_venda = '2025-09-10');

-- A mesma pergunta com dois IN
SELECT
    venda_id, produto_id, valor_unitario, data_venda
FROM
    vendas_itens
WHERE
    produto_id IN (1, 3, 6)
    AND data_venda IN ('2025-09-01', '2025-09-10');

-- NOT IN: 35 linhas
SELECT
    venda_id, produto_id, valor_unitario
FROM
    vendas_itens
WHERE
    produto_id NOT IN (1, 3, 6)
ORDER BY
    produto_id;

-- LIKE: 6 linhas
SELECT
    venda_id, produto_id, observacao
FROM
    vendas_itens
WHERE
    observacao LIKE 'Entrega%';

-- LIKE com curinga no meio: 3 linhas
SELECT
    venda_id, observacao
FROM
    vendas_itens
WHERE
    observacao LIKE '%loja%';

-- LIKE com sublinhado: 6 linhas
SELECT
    venda_id, observacao
FROM
    vendas_itens
WHERE
    observacao LIKE '_ntrega%';

-- LIKE diferencia maiuscula: 0 linhas
SELECT
    venda_id, observacao
FROM
    vendas_itens
WHERE
    observacao LIKE 'entrega%';

-- ILIKE nao diferencia: 6 linhas
SELECT
    venda_id, observacao
FROM
    vendas_itens
WHERE
    observacao ILIKE 'entrega%';

-- NOT LIKE: 8 linhas, e nao 44
SELECT
    venda_id, observacao
FROM
    vendas_itens
WHERE
    observacao NOT LIKE 'Entrega%';

-- Comparacao com nulo: 0 linhas, sem erro
SELECT venda_id, observacao FROM vendas_itens WHERE observacao = NULL;

-- IS NULL: 36 linhas
SELECT
    venda_id, produto_id, valor_unitario
FROM
    vendas_itens
WHERE
    observacao IS NULL;

-- IS NOT NULL: 14 linhas
SELECT
    venda_id, produto_id, observacao
FROM
    vendas_itens
WHERE
    observacao IS NOT NULL
ORDER BY
    observacao;

-- NOT IN sobre coluna com nulo: 11 linhas, e nao 47
SELECT
    venda_id, observacao
FROM
    vendas_itens
WHERE
    observacao NOT IN ('Entrega expressa');

-- Nulo dentro da lista: 0 linhas, sempre
SELECT venda_id FROM vendas_itens WHERE produto_id NOT IN (1, 3, NULL);

-- O complemento correto: 47 linhas
SELECT
    venda_id, observacao
FROM
    vendas_itens
WHERE
    observacao NOT IN ('Entrega expressa')
    OR observacao IS NULL;

-- COALESCE na apresentacao
SELECT
    venda_id,
    produto_id,
    COALESCE(observacao, 'Sem observacao') AS observacao
FROM
    vendas_itens
WHERE
    venda_id = 2001;

-- ===============================================================
-- ETAPA 6. DISTINCT, ORDER BY, LIMIT e OFFSET
-- ===============================================================
-- DISTINCT sobre uma coluna: 10 linhas
SELECT DISTINCT
    valor_unitario
FROM
    vendas_itens
ORDER BY
    valor_unitario;

-- DISTINCT sobre duas colunas: 10 linhas
SELECT DISTINCT
    produto_id,
    valor_unitario
FROM
    vendas_itens
ORDER BY
    produto_id;

-- Ordenacao com tres criterios
SELECT
    venda_id,
    produto_id,
    valor_unitario
FROM
    vendas_itens
ORDER BY
    valor_unitario DESC,
    venda_id ASC,
    produto_id ASC;

-- Posicao dos nulos
SELECT
    venda_id,
    observacao
FROM
    vendas_itens
ORDER BY
    observacao ASC NULLS FIRST;

-- Paginacao: pagina 1
SELECT
    venda_id, produto_id, valor_unitario
FROM
    vendas_itens
ORDER BY
    valor_unitario DESC, venda_id ASC, produto_id ASC
LIMIT 5 OFFSET 0;

-- Paginacao: pagina 2
SELECT
    venda_id, produto_id, valor_unitario
FROM
    vendas_itens
ORDER BY
    valor_unitario DESC, venda_id ASC, produto_id ASC
LIMIT 5 OFFSET 5;

-- Paginacao: pagina 3
SELECT
    venda_id, produto_id, valor_unitario
FROM
    vendas_itens
ORDER BY
    valor_unitario DESC, venda_id ASC, produto_id ASC
LIMIT 5 OFFSET 10;

-- ===============================================================
-- ETAPA 7. Agregacao, GROUP BY e HAVING
-- ===============================================================
-- Agregados sobre a tabela inteira: uma linha
SELECT
    COUNT(*)                       AS itens,
    COUNT(observacao)              AS itens_com_observacao,
    COUNT(DISTINCT venda_id)       AS vendas,
    COUNT(DISTINCT produto_id)     AS produtos,
    SUM(valor_unitario)            AS soma,
    ROUND(AVG(valor_unitario), 2)  AS media,
    MIN(valor_unitario)            AS menor,
    MAX(valor_unitario)            AS maior
FROM
    vendas_itens;

-- Total por venda: 16 linhas
SELECT
    venda_id,
    SUM(valor_unitario) AS valor_total,
    data_venda
FROM
    vendas_itens
GROUP BY
    venda_id, data_venda
ORDER BY
    valor_total ASC;

-- Total por produto: 10 linhas
SELECT
    produto_id,
    SUM(valor_unitario) AS valor_final,
    COUNT(*)            AS vezes_vendido
FROM
    vendas_itens
GROUP BY
    produto_id
ORDER BY
    valor_final ASC;

-- Agrupamento por duas colunas: 10 linhas
SELECT
    data_venda,
    produto_id,
    COUNT(*) AS itens
FROM
    vendas_itens
WHERE
    data_venda BETWEEN '2025-09-01' AND '2025-09-02'
GROUP BY
    data_venda, produto_id
ORDER BY
    data_venda, produto_id;

-- HAVING com SUM: 5 linhas
SELECT
    venda_id,
    SUM(valor_unitario) AS valor_total,
    COUNT(*)            AS itens
FROM
    vendas_itens
GROUP BY
    venda_id
HAVING
    SUM(valor_unitario) > 400
ORDER BY
    valor_total DESC;

-- HAVING com COUNT: 5 linhas
SELECT
    venda_id,
    COUNT(*)            AS itens,
    SUM(valor_unitario) AS valor_total
FROM
    vendas_itens
GROUP BY
    venda_id
HAVING
    COUNT(*) >= 5
ORDER BY
    venda_id;

-- WHERE, GROUP BY e HAVING na mesma consulta: 6 linhas
SELECT
    venda_id,
    COUNT(*)            AS itens_considerados,
    SUM(valor_unitario) AS subtotal
FROM
    vendas_itens
WHERE
    valor_unitario >= 50
GROUP BY
    venda_id
HAVING
    SUM(valor_unitario) > 300
ORDER BY
    subtotal DESC;

-- Agregacao sobre texto
SELECT
    venda_id,
    COUNT(*)          AS itens,
    COUNT(observacao) AS com_observacao,
    STRING_AGG(observacao, ' | ' ORDER BY id) AS observacoes
FROM
    vendas_itens
GROUP BY
    venda_id
ORDER BY
    venda_id
LIMIT 5;

-- ===============================================================
-- ETAPA 8. Comandos que produzem erro
-- Executar um a um para ler a mensagem
-- ===============================================================
-- ERROR: aggregate functions are not allowed in WHERE
SELECT venda_id, SUM(valor_unitario)
FROM vendas_itens
WHERE SUM(valor_unitario) > 400
GROUP BY venda_id;

-- ERROR: column "vendas_itens.data_venda" must appear in the GROUP BY clause
SELECT venda_id, data_venda, SUM(valor_unitario)
FROM vendas_itens
GROUP BY venda_id;

-- ERROR: cannot insert a non-DEFAULT value into column "id"
INSERT INTO vendas_itens (id, venda_id, produto_id, valor_unitario, data_venda)
VALUES (999, 2020, 1, 10.00, '2025-09-20');
```

---

## 13. Exercícios

Os enunciados devem ser resolvidos sem consultar a seção 14. Cada resposta deve ser escrita por inteiro.

**Minimundo**

1. Enunciar, em uma frase, uma regra do minimundo desta aula que a tabela `vendas_itens` **não** consegue impedir que seja violada. Explicar por quê.
2. Descrever qual coluna seria acrescentada à tabela para que ela passasse a representar a quantidade de unidades vendidas em cada item, e qual restrição essa coluna deveria receber.

**Operadores e expressões**

3. Listar `venda_id`, `produto_id`, `valor_unitario` e uma coluna calculada com o valor após um desconto de quinze por cento, arredondada a duas casas, chamada `valor_com_desconto`.
4. Listar `produto_id` e `valor_unitario` dos itens cujo `produto_id` é par. O resto da divisão por dois resolve o problema.
5. Explicar, sem executar, quantas linhas cada uma das duas consultas abaixo devolve, e por que os números diferem.

```sql
SELECT * FROM vendas_itens
WHERE produto_id = 5 OR produto_id = 1 AND valor_unitario > 100;

SELECT * FROM vendas_itens
WHERE (produto_id = 5 OR produto_id = 1) AND valor_unitario > 100;
```

**Filtro**

6. Listar os itens cujo valor unitário está entre 30 e 90 reais, inclusive, ordenado do maior para o menor valor.
7. Listar os itens dos produtos 2, 4 e 7, vendidos a partir de 2025-09-05, ordenado por data e por produto.
8. Listar os itens que **não** pertencem aos produtos 1, 5 e 10, ordenado por `produto_id`.
9. Listar `venda_id` e `observacao` dos itens cuja observação contém a palavra `promocao` em qualquer posição.
10. Listar `venda_id` e `produto_id` dos itens sem observação, ordenado por `venda_id`.
11. Listar `venda_id` e `observacao` de todos os itens cuja observação seja diferente de `Retirada na loja`, incluindo os itens sem observação. Informar quantas linhas a consulta devolve e explicar por que a resposta ingênua estaria errada.

**Apresentação**

12. Listar as datas de venda distintas, em ordem crescente.
13. Apresentar a terceira página de um relatório que ordena os itens por `data_venda` crescente e `produto_id` crescente, com cinco linhas por página.

**Agregação**

14. Apresentar a quantidade de itens e o valor total de cada data de venda, ordenado pela data.
15. Apresentar, por produto, a quantidade de vezes que ele foi vendido e o valor médio arredondado a duas casas, apenas para os produtos vendidos cinco vezes ou mais, ordenado pela quantidade em ordem decrescente.
16. Apresentar as vendas cujo total está entre 200 e 500 reais, com o total arredondado a duas casas, ordenado pelo total em ordem decrescente.
17. Explicar por que a consulta abaixo produz erro, e escrever duas versões corretas que respondam a perguntas diferentes.

```sql
SELECT venda_id, produto_id, SUM(valor_unitario) AS total
FROM vendas_itens
GROUP BY venda_id;
```

18. Explicar a diferença entre os dois números que a consulta abaixo devolve.

```sql
SELECT COUNT(*) AS a, COUNT(observacao) AS b FROM vendas_itens;
```

---

## 14. Gabarito

**1.** A regra 3 do minimundo diz que cada item se refere a um produto, e a tabela não consegue impedir a inserção de um `produto_id` inexistente, como `999`.

O motivo está na seção 4.4: não existe uma tabela `produto` para ser referenciada, e sem ela nenhuma restrição de chave estrangeira pode ser declarada. A regra permanece enunciada em linguagem natural, e sua verificação depende de quem escreve os comandos. A regra 2, que diz que não existe venda sem item, também não é verificável, e pela mesma razão.

**2.** Uma coluna `quantidade INTEGER NOT NULL`, com a restrição adicional `CHECK (quantidade > 0)`.

A obrigatoriedade decorre do minimundo: não existe item de venda sem quantidade. A verificação decorre do mesmo lugar: uma quantidade zero ou negativa não representa nada no mundo real. O tipo é inteiro porque unidades não se fracionam neste recorte. A cláusula `CHECK` é tratada no arquivo 11.

Com essa coluna, o valor total do item passaria a ser `valor_unitario * quantidade`, e a soma da seção 9.4 deixaria de estar correta.

**3.** Desconto de quinze por cento.

```sql
SELECT
    venda_id,
    produto_id,
    valor_unitario,
    ROUND(valor_unitario * 0.85, 2) AS valor_com_desconto
FROM
    vendas_itens;
```

Primeiras linhas:

| venda_id | produto_id | valor_unitario | valor_com_desconto |
|---|---|---|---|
| 2001 | 1 | 150.55 | 127.97 |
| 2001 | 3 | 45.00 | 38.25 |
| 2001 | 5 | 12.75 | 10.84 |
| 2001 | 9 | 88.78 | 75.46 |
| 2001 | 10 | 10.00 | 8.50 |

Multiplicar por `0.85` e subtrair `0.15 * valor` levam ao mesmo resultado. A primeira forma tem uma operação em lugar de duas.

**4.** Produtos de número par.

```sql
SELECT
    produto_id,
    valor_unitario
FROM
    vendas_itens
WHERE
    produto_id % 2 = 0
ORDER BY
    produto_id;
```

Resultado: **23 linhas**, dos produtos 2, 4, 6, 8 e 10.

A alternativa `produto_id IN (2, 4, 6, 8, 10)` produz o mesmo resultado neste conjunto de dados, e deixa de produzir se um produto 12 for cadastrado. A expressão com resto descreve a regra, a lista descreve os dados de hoje.

**5.** A primeira devolve **11 linhas**, a segunda **6 linhas**.

`AND` é avaliado antes de `OR`. A primeira consulta é lida como `produto_id = 5 OR (produto_id = 1 AND valor_unitario > 100)`, e devolve os 5 itens do produto 5, cujo valor é `12.75`, mais os 6 itens do produto 1, cujo valor é `150.55`.

Na segunda, os parênteses forçam a alternativa a ser avaliada primeiro, e a condição de valor é aplicada ao resultado. Os itens do produto 5 são eliminados, porque `12.75` não passa de 100, restando apenas os 6 do produto 1.

**6.** Valor entre 30 e 90.

```sql
SELECT
    venda_id,
    produto_id,
    valor_unitario,
    data_venda
FROM
    vendas_itens
WHERE
    valor_unitario BETWEEN 30 AND 90
ORDER BY
    valor_unitario DESC;
```

Resultado: **19 linhas**, distribuídas entre os valores `88.78` (6), `60.00` (4), `45.00` (5) e `34.50` (4).

**7.** Produtos 2, 4 e 7 a partir de 2025-09-05.

```sql
SELECT
    venda_id,
    produto_id,
    valor_unitario,
    data_venda
FROM
    vendas_itens
WHERE
    produto_id IN (2, 4, 7)
    AND data_venda >= '2025-09-05'
ORDER BY
    data_venda,
    produto_id;
```

Resultado completo, nove linhas:

| venda_id | produto_id | valor_unitario | data_venda |
|---|---|---|---|
| 2005 | 2 | 99.90 | 2025-09-05 |
| 2005 | 4 | 220.00 | 2025-09-05 |
| 2007 | 2 | 99.90 | 2025-09-07 |
| 2007 | 7 | 199.99 | 2025-09-07 |
| 2008 | 4 | 220.00 | 2025-09-08 |
| 2009 | 7 | 199.99 | 2025-09-09 |
| 2010 | 2 | 99.90 | 2025-09-10 |
| 2012 | 4 | 220.00 | 2025-09-12 |
| 2016 | 7 | 199.99 | 2025-09-16 |

O enunciado diz "a partir de 2025-09-05", e o operador correspondente é `>=`. Trocá-lo por `>` excluiria as duas linhas do dia 5 e devolveria sete, respondendo a "depois de 2025-09-05". A distinção entre os dois enunciados existe em português e precisa sobreviver à tradução para SQL.

**8.** Complemento dos produtos 1, 5 e 10.

```sql
SELECT
    venda_id,
    produto_id,
    valor_unitario
FROM
    vendas_itens
WHERE
    produto_id NOT IN (1, 5, 10)
ORDER BY
    produto_id;
```

Resultado: **34 linhas**. Os produtos 1, 5 e 10 somam 6, 5 e 5 itens, ou seja 16, e 50 menos 16 dá 34.

O complemento fecha porque `produto_id` é `NOT NULL`. Se admitisse nulo, as linhas nulas ficariam de fora, como no exercício 11.

**9.** Observação contendo `promocao`.

```sql
SELECT
    venda_id,
    observacao
FROM
    vendas_itens
WHERE
    observacao LIKE '%promocao%';
```

| venda_id | observacao |
|---|---|
| 2001 | Item em promocao |
| 2007 | Item em promocao |

Duas linhas. Os curingas nas duas pontas são necessários porque a palavra não está nem no começo nem no fim do texto.

**10.** Itens sem observação.

```sql
SELECT
    venda_id,
    produto_id
FROM
    vendas_itens
WHERE
    observacao IS NULL
ORDER BY
    venda_id;
```

Resultado: **36 linhas**. Escrever `observacao = NULL` devolveria zero linhas, sem erro.

**11.** Diferente de `Retirada na loja`, incluindo os sem observação.

```sql
SELECT
    venda_id,
    observacao
FROM
    vendas_itens
WHERE
    observacao <> 'Retirada na loja'
    OR observacao IS NULL
ORDER BY
    observacao NULLS LAST;
```

Resultado: **47 linhas**.

A resposta ingênua seria `WHERE observacao <> 'Retirada na loja'`, que devolve apenas **11 linhas**: as 14 com observação menos as 3 iguais ao texto procurado. As 36 linhas nulas são descartadas porque a comparação entre um valor desconhecido e um texto conhecido resulta desconhecido, e a cláusula `WHERE` só mantém o que é verdadeiro.

Somar as 3 excluídas às 47 mantidas devolve as 50 linhas da tabela, o que confirma o resultado.

**12.** Datas distintas.

```sql
SELECT DISTINCT
    data_venda
FROM
    vendas_itens
ORDER BY
    data_venda;
```

Resultado: **16 linhas**, de `2025-09-01` a `2025-09-16`, uma por dia.

Neste cenário cada venda ocorre em um dia distinto, e por isso a quantidade de datas coincide com a quantidade de vendas. As duas coisas não são a mesma, e a coincidência é uma propriedade destes dados.

**13.** Terceira página.

```sql
SELECT
    venda_id,
    produto_id,
    valor_unitario,
    data_venda
FROM
    vendas_itens
ORDER BY
    data_venda ASC,
    produto_id ASC
LIMIT 5 OFFSET 10;
```

| venda_id | produto_id | valor_unitario | data_venda |
|---|---|---|---|
| 2003 | 2 | 99.90 | 2025-09-03 |
| 2003 | 3 | 45.00 | 2025-09-03 |
| 2003 | 5 | 12.75 | 2025-09-03 |
| 2003 | 7 | 199.99 | 2025-09-03 |
| 2003 | 9 | 88.78 | 2025-09-03 |

O cálculo do `OFFSET` é `(3 - 1) * 5`, que resulta 10. A ordenação é determinada, porque a combinação de data e produto não se repete.

**14.** Itens e total por data.

```sql
SELECT
    data_venda,
    COUNT(*)            AS itens,
    SUM(valor_unitario) AS valor_total
FROM
    vendas_itens
GROUP BY
    data_venda
ORDER BY
    data_venda;
```

Resultado completo, dezesseis linhas:

| data_venda | itens | valor_total |
|---|---|---|
| 2025-09-01 | 5 | 307.08 |
| 2025-09-02 | 5 | 564.95 |
| 2025-09-03 | 5 | 446.42 |
| 2025-09-04 | 5 | 640.54 |
| 2025-09-05 | 5 | 488.18 |
| 2025-09-06 | 4 | 262.08 |
| 2025-09-07 | 4 | 394.39 |
| 2025-09-08 | 4 | 504.33 |
| 2025-09-09 | 4 | 282.74 |
| 2025-09-10 | 2 | 144.90 |
| 2025-09-11 | 2 | 123.28 |
| 2025-09-12 | 1 | 220.00 |
| 2025-09-13 | 1 | 150.55 |
| 2025-09-14 | 1 | 10.00 |
| 2025-09-15 | 1 | 12.75 |
| 2025-09-16 | 1 | 199.99 |

O resultado é idêntico ao da seção 9.4, com outra chave de agrupamento, porque cada venda ocorre em um dia distinto. A soma da coluna `itens` é 50 e a da coluna `valor_total` é `4752.18`, que são os totais da seção 9.1.

**15.** Produtos vendidos cinco vezes ou mais.

```sql
SELECT
    produto_id,
    COUNT(*)                      AS vezes_vendido,
    ROUND(AVG(valor_unitario), 2) AS valor_medio
FROM
    vendas_itens
GROUP BY
    produto_id
HAVING
    COUNT(*) >= 5
ORDER BY
    vezes_vendido DESC;
```

Resultado completo, oito linhas:

| produto_id | vezes_vendido | valor_medio |
|---|---|---|
| 1 | 6 | 150.55 |
| 9 | 6 | 88.78 |
| 2 | 5 | 99.90 |
| 3 | 5 | 45.00 |
| 4 | 5 | 220.00 |
| 5 | 5 | 12.75 |
| 7 | 5 | 199.99 |
| 10 | 5 | 10.00 |

Ficam de fora os produtos 6 e 8, com quatro vendas cada.

A coluna `valor_medio` repete o valor unitário de cada produto, porque cada produto tem sempre o mesmo preço, conforme a seção 8.2. Uma média que coincide com todos os valores do grupo é um sinal de que aquele dado não varia, e portanto de que ele está armazenado no lugar errado. É a redundância da seção 4.5 aparecendo em um relatório.

A ordem entre os produtos 1 e 9, empatados em seis, não está determinada. O mesmo vale para os seis empatados em cinco.

**16.** Vendas com total entre 200 e 500.

```sql
SELECT
    venda_id,
    ROUND(SUM(valor_unitario), 2) AS valor_total
FROM
    vendas_itens
GROUP BY
    venda_id
HAVING
    SUM(valor_unitario) BETWEEN 200 AND 500
ORDER BY
    valor_total DESC;
```

Resultado completo, sete linhas:

| venda_id | valor_total |
|---|---|
| 2005 | 488.18 |
| 2003 | 446.42 |
| 2007 | 394.39 |
| 2001 | 307.08 |
| 2009 | 282.74 |
| 2006 | 262.08 |
| 2012 | 220.00 |

A venda 2012 tem total exatamente `220.00` e entra no resultado, porque `BETWEEN` inclui os dois extremos. Uma condição escrita como `SUM(valor_unitario) > 200 AND SUM(valor_unitario) < 500` devolveria seis linhas, e responderia a outra pergunta.

A função `ROUND` aplicada a `SUM` não altera nenhum valor aqui, porque a soma de números de escala 2 tem escala 2. Ela permanece na consulta como hábito, e é dispensável neste caso específico.

**17.** A consulta produz:

```
ERROR:  column "vendas_itens.produto_id" must appear in the GROUP BY clause or be used in an aggregate function
```

A coluna `produto_id` está na lista do `SELECT`, não é argumento de função de agregação e não consta do `GROUP BY`. O grupo da venda 2001 reúne cinco linhas com cinco produtos distintos, e não existe "o produto do grupo".

Primeira versão correta, que responde por venda:

```sql
SELECT
    venda_id,
    SUM(valor_unitario) AS total
FROM
    vendas_itens
GROUP BY
    venda_id;
```

Dezesseis linhas, uma por venda.

Segunda versão correta, que responde por venda e produto:

```sql
SELECT
    venda_id,
    produto_id,
    SUM(valor_unitario) AS total
FROM
    vendas_itens
GROUP BY
    venda_id, produto_id;
```

Cinquenta linhas. Como nenhum produto se repete dentro de uma venda, cada grupo tem uma linha só, e a soma de um valor é o próprio valor. O resultado é correto e inútil, o que é uma boa demonstração de que agrupar por colunas em excesso desfaz o agrupamento.

**18.** `COUNT(*)` devolve `50` e `COUNT(observacao)` devolve `14`.

`COUNT(*)` conta linhas e não olha para o conteúdo. `COUNT(observacao)` conta valores presentes naquela coluna, e as 36 linhas com observação nula não são contadas.

As duas formas respondem a perguntas diferentes: quantos itens existem, e quantos itens têm observação. A escolha entre elas é uma decisão sobre o que se quer saber, não sobre estilo de escrita.

---

## 15. Referências

ELMASRI, Ramez. NAVATHE, Shamkant B. *Sistemas de Banco de Dados*. 7. ed. São Paulo: Pearson, 2018. Capítulo 1, seção 1.1, sobre minimundo e as propriedades de um banco de dados. Capítulo 6, seções 6.3 e 6.4, sobre a consulta de recuperação. Capítulo 7, seção 7.1, sobre funções de agregação e agrupamento.

POSTGRESQL GLOBAL DEVELOPMENT GROUP. *PostgreSQL 17 Documentation*. Capítulo 9, *Functions and Operators*. Disponível em `https://www.postgresql.org/docs/17/functions.html`.

Material de apoio: `referencia/01-tipos-de-dados.md`, sobre domínios e critérios de escolha de tipo. `referencia/04-boas-praticas-sql.md`, sobre caixa, nomenclatura, formatação e scripts reexecutáveis.
