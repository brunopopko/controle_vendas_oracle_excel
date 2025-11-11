CREATE OR REPLACE TRIGGER trg_atualiza_valor_total
FOR INSERT OR UPDATE OR DELETE ON itens_venda
COMPOUND TRIGGER

    -- Coleção para armazenar os IDs das vendas afetadas
    TYPE t_vendas IS TABLE OF itens_venda.id_venda%TYPE;
    v_vendas t_vendas := t_vendas();

AFTER EACH ROW IS
BEGIN
    -- Armazena o id_venda afetado (NEW em inserts/updates, OLD em deletes)
    v_vendas.EXTEND;
    v_vendas(v_vendas.LAST) := NVL(:NEW.id_venda, :OLD.id_venda);
END AFTER EACH ROW;

AFTER STATEMENT IS
    -- Associative array para evitar processar o mesmo id_venda duas vezes
    TYPE t_flag IS TABLE OF BOOLEAN INDEX BY PLS_INTEGER;
    v_flag t_flag;
    v_id itens_venda.id_venda%TYPE;
BEGIN
    -- Verifica se houve alguma venda afetada
    IF v_vendas.COUNT > 0 THEN
        FOR i IN 1 .. v_vendas.COUNT LOOP
            v_id := v_vendas(i);

            -- Ignora IDs nulos e duplicados
            IF v_id IS NOT NULL AND NOT v_flag.EXISTS(v_id) THEN
                -- Atualiza o total da venda
                UPDATE vendas v
                   SET v.valor_total = (
                       SELECT NVL(SUM(iv.quantidade * iv.valor_unitario), 0)
                         FROM itens_venda iv
                        WHERE iv.id_venda = v_id
                   )
                 WHERE v.id_venda = v_id;

                -- Marca o ID como já processado
                v_flag(v_id) := TRUE;
            END IF;
        END LOOP;
    END IF;
END AFTER STATEMENT;

END trg_atualiza_valor_total;
/