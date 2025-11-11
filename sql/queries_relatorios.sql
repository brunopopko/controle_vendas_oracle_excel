-- queries_relatorios.sql
-- Consultas de relatórios para o Sistema de Controle de Vendas
-- Autor: Bruno Henrique Popko
SET DEFINE OFF;
-- -----------------------------------------------------------
-- 1) KPI GERAL: faturamento total, total de vendas, ticket médio
-- -----------------------------------------------------------
SELECT
    (SELECT NVL(SUM(valor_total),0) FROM vendas) AS faturamento_total,
    (SELECT COUNT(*) FROM vendas) AS total_vendas,
    CASE WHEN (SELECT COUNT(*) FROM vendas) = 0 THEN 0
        ELSE ROUND((SELECT NVL(SUM(valor_total),0) FROM vendas) / (SELECT COUNT(*) FROM vendas), 2)
    END AS ticket_medio
FROM DUAL;

-- ----------------------------------------------------------
-- 2) Faturamento por mês (MM/YYYY)
-- ----------------------------------------------------------
SELECT
    TO_CHAR(data_venda, 'MM/YYYY') AS mes,
    SUM(valor_total) AS total_mes,
    COUNT(*) AS num_vendas,
    ROUND(SUM(valor_total)/NULLIF(COUNT(*),0),2) AS ticket_medio_mes
FROM vendas
GROUP BY TO_CHAR(data_venda, 'MM/YYYY')
ORDER BY MIN(data_venda);

-- ------------------------------------------------------------
-- 3) Total de Vendas por Vendedor (Ranking)
-- ------------------------------------------------------------
SELECT
    vdr.id_vendedor,
    vdr.nome AS vendedor,
    COUNT(v.id_venda) AS qtd_vendas,
    SUM(v.valor_total) AS faturamento
FROM vendas v
JOIN vendedores vdr ON v.id_vendedor = vdr.id_vendedor
GROUP BY vdr.id_vendedor, vdr.nome
ORDER BY faturamento DESC;

-- ------------------------------------------------------------
-- 4) Produtos mais vendidos (por quantidade)
-- ------------------------------------------------------------
SELECT
    p.id_produto,
    p.nome AS produto,
    SUM(iv.quantidade) AS total_quantidade,
    SUM(iv.quantidade * iv.valor_unitario) AS receita
FROM itens_venda iv
JOIN produtos p ON iv.id_produto = p.id_produto
GROUP BY p.id_produto, p.nome
ORDER BY total_quantidade DESC;

-- ------------------------------------------------------------
-- 5) Top Clientes por faturamento
-- ------------------------------------------------------------
SELECT
    c.id_cliente,
    c.nome AS cliente,
    COUNT(v.id_venda) AS qtd_compras,
    SUM(v.valor_total) AS faturamento
FROM vendas v
JOIN clientes c ON v.id_cliente = c.id_cliente
GROUP BY c.id_cliente, c.nome
ORDER BY faturamento DESC;

-- ------------------------------------------------------------
-- 6) Vendas por Cidade / Estado
-- ------------------------------------------------------------
SELECT
    c.estado,
    c.cidade,
    COUNT(v.id_venda) AS qtd_vendas,
    SUM(v.valor_total) AS faturamento
FROM vendas v
JOIN clientes c ON v.id_cliente = c.id_cliente
GROUP BY c.estado, c.cidade
ORDER BY c.estado, faturamento DESC;

-- ------------------------------------------------------------
-- 7) Detalhe por venda (linha por item)
-- ------------------------------------------------------------
SELECT
    v.id_venda,
    v.data_venda,
    c.nome AS cliente,
    vdr.nome AS vendedor,
    iv.id_item,
    p.nome AS produto,
    iv.quantidade,
    iv.valor_unitario,
    iv.subtotal
FROM itens_venda iv
JOIN vendas v ON iv.id_venda = v.id_venda
JOIN clientes c ON v.id_cliente = c.id_cliente
JOIN vendedores vdr ON v.id_vendedor = vdr.id_vendedor
JOIN produtos p ON iv.id_produto = p.id_produto
ORDER BY v.id_venda, iv.id_item;

-- -----------------------------------------------------------
-- 8) Conferência: soma dos itens vs valor_total em vendas (integridade)
-- -----------------------------------------------------------
SELECT
    v.id_venda,
    v.valor_total AS valor_total_venda,
    NVL((SELECT SUM(quantidade * valor_unitario) FROM itens_venda WHERE id_venda = v.id_venda),0) AS soma_itens,
    CASE WHEN ROUND(v.valor_total,2) = ROUND(NVL((SELECT SUM(quantidade * valor_unitario) FROM itens_venda WHERE id_venda = v.id_venda),0),2)
        THEN '0K' ELSE 'DIVERGENTE' END AS status
FROM vendas v
ORDER BY v.id_venda;

-- -----------------------------------------------------------
-- 9) Estoque atual e alerta (produtos abaixo do mínimo)
-- -- --------------------------------------------------------
SELECT
    id_produto,
    nome,
    categoria,
    estoque,
    preco,
    CASE WHEN estoque <= 20 THEN 'BAIXO' ELSE 'OK' END AS alerta_estoque
FROM produtos
ORDER BY estoque ASC;

-- -----------------------------------------------------------
-- 10) Receita por categoria de produto
-- -----------------------------------------------------------
SELECT
    p.categoria,
    SUM(iv.quantidade * iv.valor_unitario) AS receita_total,
    SUM(iv.quantidade) AS qte_total
FROM itens_venda iv
JOIN produtos p ON iv.id_produto = p.id_produto
GROUP BY p.categoria
ORDER BY receita_total DESC;

-- -----------------------------------------------------------
-- 11) Vendas por dia (últimos 30 dias)
-- -----------------------------------------------------------
SELECT
    TRUNC(data_venda) AS dia,
    COUNT(*) as qte_vendas,
    SUM(valor_total) AS receita_dia
FROM vendas
WHERE data_venda >= TRUNC(SYSDATE) - 30
GROUP BY TRUNC(data_venda)
ORDER BY dia;

-- -----------------------------------------------------------
-- 12) Views úteis (criar para facilitar relatórios / BI)
-- -----------------------------------------------------------

-- View: vw_vendas_detalhadas (uma vista que junta cabeçalhos + itens)
CREATE OR REPLACE VIEW vw_vendas_detalhadas AS
SELECT
    v.id_venda,
    v.data_venda,
    c.id_cliente,
    c.nome cliente,
    vdr.id_vendedor,
    vdr.nome vendedor,
    iv.id_item,
    p.id_produto,
    p.nome produto,
    iv.quantidade,
    iv.valor_unitario,
    iv.subtotal,
    v.valor_total
FROM vendas v
JOIN clientes c ON v.id_cliente = c.id_cliente
JOIN vendedores vdr ON v.id_vendedor = vdr.id_vendedor
JOIN itens_venda iv ON iv.id_venda = v.id_venda
JOIN produtos p ON iv.id_produto = p.id_produto;

-- View: vw_faturamento_mensal (resumida)
CREATE OR REPLACE VIEW vw_faturamento_mensal AS
SELECT
    TO_CHAR(data_venda, 'MM/YYYY') AS mes,
    SUM(valor_total) AS total_mes,
    COUNT(*) AS num_vendas
FROM vendas
GROUP BY TO_CHAR(data_venda, 'MM/YYYY');


-- -----------------------------------------------------------
-- 13) Exemplos de queries parametrizadas (usar bind variables no SQL Developer)
--     Ex: :p_data_inicio e :p_data_fim são parâmetros que você define no momento da execução
-- -----------------------------------------------------------
-- Faturamento entre datas (use Run Statement e informe p_data_inicio/p_data_fim, formato 'YYYY-MM-DD')
SELECT
    TO_CHAR(data_venda,'YYYY-MM-DD') AS dia,
    SUM(valor_total) AS receita
FROM vendas
WHERE data_venda BETWEEN TO_DATE(:p_data_inicio,'YYYY-MM-DD') AND TO_DATE(:p_data_fim, 'YYYY-MM-DD')
GROUP BY TO_CHAR(data_venda,'YYYY-MM-DD')
ORDER BY dia;