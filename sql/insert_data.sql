-- insert_data.sql
-- Popula o esquema com dados de exemplo
-- Autor: Bruno Henrique Popko
-- ============================================================

SET DEFINE OFF;

-- === LIMPEZA DAS TABELAS (ordem importa por causa das FKs) ===
BEGIN
    EXECUTE IMMEDIATE 'DELETE FROM itens_venda';
    EXECUTE IMMEDIATE 'DELETE FROM vendas';
    EXECUTE IMMEDIATE 'DELETE FROM vendedores';
    EXECUTE IMMEDIATE 'DELETE FROM produtos';
    EXECUTE IMMEDIATE 'DELETE FROM clientes';
    COMMIT;
END;
/

-- ============================================================
-- INSERÇÃO DOS DADOS
-- ============================================================
DECLARE
    v_id_cliente1 clientes.id_cliente%TYPE;
    v_id_cliente2 clientes.id_cliente%TYPE;
    v_id_cliente3 clientes.id_cliente%TYPE;

    v_id_prod1 produtos.id_produto%TYPE;
    v_id_prod2 produtos.id_produto%TYPE;
    v_id_prod3 produtos.id_produto%TYPE;

    v_id_vend1 vendedores.id_vendedor%TYPE;
    v_id_vend2 vendedores.id_vendedor%TYPE;

    v_id_venda1 vendas.id_venda%TYPE;
    v_id_venda2 vendas.id_venda%TYPE;
    v_id_venda3 vendas.id_venda%TYPE;
BEGIN
    -- === CLIENTES ===
    INSERT INTO clientes (nome, email, telefone, cidade, estado, data_cadastro)
    VALUES ('Loja Central', 'contato@lojacentral.com', '(51) 99999-1111', 'Porto Alegre', 'RS', SYSDATE)
    RETURNING id_cliente INTO v_id_cliente1;

    INSERT INTO clientes (nome, email, telefone, cidade, estado, data_cadastro)
    VALUES ('Super Compras', 'financeiro@supercompras.com', '(51) 98888-2222', 'Canoas', 'RS', SYSDATE)
    RETURNING id_cliente INTO v_id_cliente2;

    INSERT INTO clientes (nome, email, telefone, cidade, estado, data_cadastro)
    VALUES ('Mercado Bom Preço', 'contato@bompreco.com', '(51) 97777-3333', 'Novo Hamburgo', 'RS', SYSDATE)
    RETURNING id_cliente INTO v_id_cliente3;

    -- === PRODUTOS ===
    INSERT INTO produtos (nome, categoria, preco, estoque, ativo)
    VALUES ('Arroz 5kg', 'Alimentos', 25.90, 120, 'S')
    RETURNING id_produto INTO v_id_prod1;

    INSERT INTO produtos (nome, categoria, preco, estoque , ativo)
    VALUES ('Feijão', 'Alimentos', 8.5, 200, 'S')
    RETURNING id_produto INTO v_id_prod2;

    INSERT INTO produtos (nome, categoria, preco, estoque, ativo)
    VALUES ('Detergente 500ml', 'Limpeza', 3.99, 300, 'S')
    RETURNING id_produto INTO v_id_prod3;

    -- === VENDEDORES ===
    INSERT INTO vendedores (nome, email, ativo)
    VALUES ('Carlos Silva', 'carlos.silva@empresa.com', 'S')
    RETURNING id_vendedor INTO v_id_vend1;

    INSERT INTO vendedores (nome, email, ativo)
    VALUES ('Mariana Souza', 'mariana.souza@empresa.com', 'S')
    RETURNING id_vendedor INTO v_id_vend2;

    -- === VENDAS ===
    INSERT INTO vendas (id_cliente, id_vendedor, data_venda, status, valor_total)
    VALUES (v_id_cliente1, v_id_vend1, SYSDATE, 'FECHADA', 0)
    RETURNING id_venda INTO v_id_venda1;

    INSERT INTO vendas (id_cliente, id_vendedor, data_venda, status, valor_total)
    VALUES (v_id_cliente2, v_id_vend2, SYSDATE, 'FECHADA', 0)
    RETURNING id_venda INTO v_id_venda2;

    INSERT INTO vendas (id_cliente, id_vendedor, data_venda, status, valor_total)
    VALUES (v_id_cliente3, v_id_vend1, SYSDATE, 'FECHADA', 0)
    RETURNING id_venda INTO v_id_venda3;

    -- === ITENS_VENDA ===
    -- Venda 1 (Loja Central)
    INSERT INTO itens_venda (id_venda, id_produto, quantidade, valor_unitario)
    VALUES (v_id_venda1, v_id_prod1, 5, 25.90);

    INSERT INTO itens_venda (id_venda, id_produto, quantidade, valor_unitario)
    VALUES (v_id_venda1, v_id_prod3, 10, 3.99);

    -- Venda 2 (Super Compras)
    INSERT INTO itens_venda (id_venda, id_produto, quantidade, valor_unitario)
    VALUES (v_id_venda2, v_id_prod1, 3, 25.90);

    INSERT INTO itens_venda (id_venda, id_produto, quantidade, valor_unitario)
    VALUES (v_id_venda2, v_id_prod2, 5, 8.50);

    -- Venda 3 (Mercado Bom Preço)
    INSERT INTO itens_venda (id_venda, id_produto, quantidade, valor_unitario)
    VALUES (v_id_venda3, v_id_prod2, 10, 8.50);

    INSERT INTO itens_venda (id_venda, id_produto, quantidade, valor_unitario)
    VALUES (v_id_venda3, v_id_prod3, 15, 3.99);

    COMMIT;
END;
/