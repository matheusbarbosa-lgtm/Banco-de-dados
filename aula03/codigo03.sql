-- Active: 1787872741066@@127.0.0.1@5432@bd_vendas@public
DROP TABLE IF EXISTS vendas_itens;

CREATE TABLE vendas_itens(
    id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    venda_id INTEGER NOT NULL,
    produto_id INTEGER NOT NULL,
    valor_unitario NUMERIC(10, 2) NOT NULL,
    data_venda DATE NOT NULL,
    observacao TEXT 
);

SELECT * FROM vendas_itens;


INSERT INTO vendas_itens (venda_id, produto_id, valor_unitario, data_venda, observacao) VALUES
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

(2010,  2,  99.90, '2025-09-10', NULL),
(2010,  3,  45.00, '2025-09-10', NULL),

(2011,  8,  34.50, '2025-09-11', NULL),
(2011,  9,  88.78, '2025-09-11', NULL),

(2012,  4, 220.00, '2025-09-12', 'Cliente preferencial'),
(2013,  1, 150.55, '2025-09-13', NULL),
(2014, 10,  10.00, '2025-09-14', NULL),
(2015,  5,  12.75, '2025-09-15', NULL),
(2016,  7, 199.99, '2025-09-16', 'Entrega agendada');

-- Busca (venda_id -> Id da Venda, produto_id -> Id do Produto, valor_unitario -> Valor, data_venda -> Data)
SELECT
    venda_id AS "ID da Venda",
    produto_id AS "ID do Produto",
    valor_unitario AS "Valor",
    data_venda AS "Data"
FROM
    vendas_itens ;
--TODOS OS ITENS DA VENDA 2001 (venda_id, data_venda, produto_id, valor_unitario)

SELECT
    venda_id, 
    produto_id, 
    valor_unitario, 
    data_venda 
FROM
    vendas_itens
WHERE
    venda_id = 2001;

SELECT
    id,
    venda_id,
    produto_id,
    produto_id / 3 AS divisao_inteira,
    produto_id % 3 AS resto,
    produto_id / 3.0 as divisao_decimal
FROM
    vendas_itens
WHERE
    produto_id = 10;

-- Devolver todos os valores unitarios acrescidos de 10%
SELECT
    id,
    venda_id,
    produto_id,
    valor_unitario,
    valor_unitario * 1.1  AS valor_venda
FROM
    vendas_itens

SELECT
    'Venda ' || venda_id || ', produto' || produto_id AS "Descrição",
    valor_unitario

FROM
    vendas_itens
WHERE
    venda_id = 2001;

SELECT
    venda_id,
    produto_id,
    valor_unitario,
    data_venda
FROM
    vendas_itens
WHERE
    (data_venda = '2025-09-01' OR data_venda = '2025-09-02') AND valor_unitario > 100;

    
SELECT
    venda_id,
    produto_id,
    valor_unitario,
    data_venda
FROM
    vendas_itens
WHERE
    (data_venda BETWEEN '2025-09-01' AND '2025-09-03') AND (valor_unitario >= 50 AND valor_unitario < 200)
ORDER BY    
    data_venda DESC;