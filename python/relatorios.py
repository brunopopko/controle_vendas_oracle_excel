"""
Sistema de controle de vendas - Relatórios
Autor: Bruno Henrique Popko
Descrição: Gera relatórios automáticos a partir do banco Oracle e exporta para Excel.
"""

import oracledb
import pandas as pd
import os


def conectar_oracle():
    try:
        conn = oracledb.connect(
            user="controle_vendas", password="2169", dsn="localhost/XEPDB1"
        )
        print("✅ Conexão bem sucedida.")
        return conn
    except Exception as e:
        print("❌ Erro na conexão:", e)
        exit()


def gerar_relatorio(nome_arquivo, sql, conn):
    df = pd.read_sql(sql, conn)

    # pasta de saída
    pasta = "C:/Users/bruno/Documents/controle_vendas_oracle_excel/excel"
    os.makedirs(pasta, exist_ok=True)  # cria se não existir

    # arquivo com extensão correta
    caminho = os.path.join(pasta, f"relatorio_{nome_arquivo}.xlsx")

    # salva Excel
    df.to_excel(caminho, index=False, engine="openpyxl")
    print(f"📊 Relatório '{nome_arquivo}' salvo em {caminho}")


def main():
    conn = conectar_oracle()

    consultas = {
        "vendas_por_cliente": """
            SELECT c.nome AS cliente, SUM(v.valor_total) AS total_vendido
            FROM vendas v
            JOIN clientes c ON v.id_cliente = c.id_cliente
            GROUP BY c.nome
            ORDER BY total_vendido DESC
        """,
        "vendas_por_produto": """
            SELECT p.nome AS produto, SUM(iv.quantidade) AS total_vendido
            FROM itens_venda iv
            JOIN produtos p ON iv.id_produto = p.id_produto
            GROUP BY p.nome
            ORDER BY total_vendido DESC
        """,
    }

    for nome, sql in consultas.items():
        gerar_relatorio(nome, sql, conn)

    conn.close()
    print("🔒 Conexão encerrada.")


if __name__ == "__main__":
    main()
