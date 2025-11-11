# 💼 Sistema de Controle de Vendas (Oracle + Excel)

![Python](https://img.shields.io/badge/Python-3.11-blue) ![Oracle](https://img.shields.io/badge/Oracle-DB-orange) ![License](https://img.shields.io/badge/License-Free-green)

Projeto acadêmico para praticar **SQL**, **Python** e **integração com Excel**, gerando relatórios automáticos de vendas.

---

## 🧠 Objetivo

Criar um sistema simples de controle de vendas que permite:

- Gerenciar e consultar dados em um banco Oracle  
- Executar relatórios automáticos via Python  
- Exportar resultados diretamente para arquivos Excel (.xlsx)

---

## ⚙️ Funcionalidades

| Funcionalidade | Descrição |
|----------------|-----------|
| Tabelas Oracle | Criação de tabelas (`clientes`, `produtos`, `vendas`, `itens_venda`) |
| Trigger | Atualiza automaticamente o valor total da venda ao inserir itens |
| Inserção de dados | Dados de teste para simulação de vendas |
| Consultas SQL | Relatórios por cliente e por produto |
| Exportação Excel | Planilhas geradas automaticamente |
| Logs e erros | Mensagens detalhadas de execução e logs em arquivo |

---

## 📁 Estrutura do Projeto

controle_vendas_oracle_excel/
│
├── docs/ # Documentação e anotações
├── excel/ # Planilhas de saída
│ ├── relatorio_vendas_por_cliente.xlsx
│ └── relatorio_vendas_por_produto.xlsx
├── python/ # Scripts Python de automação
│ └── relatorios.py
└── sql/ # Scripts SQL do Oracle
├── create_tables.sql
├── insert_data.sql
├── queries_relatorios.sql
└── trg_atualiza_valor_total.sql


---

## 🚀 Execução

### 1️⃣ Pré-requisitos

- Python 3.11+  
- Oracle Database XE (ou outro ambiente Oracle configurado)  
- Bibliotecas Python:
```bash
pip install oracledb pandas openpyxl
2️⃣ Gerar Relatórios
Execute o script principal:

bash
Copiar código
python python/relatorios.py
Os relatórios serão salvos automaticamente na pasta:

bash
Copiar código
/excel
3️⃣ Logs
Todas as execuções geram logs em:

bash
Copiar código
/logs/execucao.log
🧱 Banco de Dados
Schema: controle_vendas

Tabelas principais: clientes, produtos, vendedores, vendas, itens_venda

Trigger: trg_atualiza_valor_total atualiza o valor total das vendas automaticamente

👨‍💻 Autor
Bruno Henrique Popko
Estudante de Ciência da Computação | Foco em Banco de Dados e Análise de Dados

📧 bruno.email@exemplo.com

🏗️ Próximos Passos
Criar executável .exe com PyInstaller

Interface gráfica com Tkinter ou Streamlit

Dashboard interativo com Power BI

💡 Projeto acadêmico para fins educacionais e portfólio.
