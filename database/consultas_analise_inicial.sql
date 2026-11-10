-- ============================================================
-- PROJETO: Dashboard Comercial
-- ARQUIVO: consultas_analise_inicial.sql
-- BANCO: SQLite
--
-- Objetivo:
-- Reunir as consultas utilizadas na exploracao inicial do banco,
-- validacao dos dados e primeiros indicadores comerciais.
--
-- Observacao:
-- sqlite_master, PRAGMA table_info, GROUP_CONCAT e LIMIT sao
-- recursos/sintaxes do SQLite. Em SQL Server, algumas partes
-- precisam ser adaptadas.
-- ============================================================


-- ------------------------------------------------------------
-- 01. LISTAR TABELAS E VIEWS DO BANCO
-- Objetivo: conhecer os objetos existentes no banco.
-- ------------------------------------------------------------

SELECT
    name,
    type
FROM sqlite_master
WHERE type IN ('table', 'view')
ORDER BY type, name;


-- ------------------------------------------------------------
-- 02. VOLUME DE REGISTROS, PEDIDOS E UNIDADES
-- Objetivo: validar o volume e a granularidade da tabela fato.
-- ------------------------------------------------------------

SELECT
    COUNT(*) AS total_registros,
    COUNT(DISTINCT id_pedido) AS total_pedidos,
    SUM(quantidade) AS total_unidades
FROM fato_vendas;


-- ------------------------------------------------------------
-- 03. DISTRIBUICAO DOS STATUS
-- Objetivo: contar quantos itens existem em cada status.
-- ------------------------------------------------------------

SELECT
    status_venda,
    COUNT(*) AS total_registros
FROM fato_vendas
GROUP BY status_venda
ORDER BY total_registros DESC;


-- ------------------------------------------------------------
-- 04. VALORES FINANCEIROS POR STATUS
-- Objetivo: comparar valores brutos, descontos, receita,
-- custos e lucro entre os status.
-- Atencao: valores de status nao concluido nao representam
-- necessariamente receita realizada.
-- ------------------------------------------------------------

SELECT
    status_venda,
    COUNT(*) AS total_registros,
    SUM(valor_bruto) AS valor_bruto,
    SUM(valor_desconto) AS valor_desconto,
    SUM(receita_liquida) AS receita_liquida,
    SUM(custo_total) AS custo_total,
    SUM(lucro) AS lucro
FROM fato_vendas
GROUP BY status_venda
ORDER BY receita_liquida DESC;


-- ------------------------------------------------------------
-- 05. KPIs DOS ITENS CONCLUIDOS
-- Objetivo: calcular indicadores comerciais e financeiros.
-- Regra provisoria: considerar somente itens concluidos.
-- Ticket medio = receita dos itens concluidos / pedidos
-- distintos que possuem ao menos um item concluido.
-- ------------------------------------------------------------

SELECT
    COUNT(*) AS total_itens_vendidos,
    COUNT(DISTINCT id_pedido) AS total_pedidos,
    SUM(quantidade) AS unidades_vendidas,

    ROUND(SUM(valor_bruto), 2) AS valor_bruto,
    ROUND(SUM(valor_desconto), 2) AS descontos,
    ROUND(SUM(receita_liquida), 2) AS receita_liquida,
    ROUND(SUM(custo_total), 2) AS custo_total,
    ROUND(SUM(lucro), 2) AS lucro,

    ROUND(
        SUM(lucro) * 100.0 /
        NULLIF(SUM(receita_liquida), 0),
        2
    ) AS margem_percentual,

    ROUND(
        SUM(receita_liquida) /
        NULLIF(COUNT(DISTINCT id_pedido), 0),
        2
    ) AS ticket_medio

FROM fato_vendas
WHERE status_venda = 'Concluída';


-- ------------------------------------------------------------
-- 06. QUANTIDADE DE PEDIDOS COM STATUS MISTOS
-- Objetivo: identificar pedidos que possuem mais de um status
-- entre seus itens.
-- ------------------------------------------------------------

SELECT
    COUNT(*) AS pedidos_com_status_misto
FROM (
    SELECT
        id_pedido
    FROM fato_vendas
    GROUP BY id_pedido
    HAVING COUNT(DISTINCT status_venda) > 1
);


-- ------------------------------------------------------------
-- 07. EXEMPLOS DE PEDIDOS COM STATUS MISTOS
-- Objetivo: visualizar ate 20 pedidos com mais de um status.
-- GROUP_CONCAT e LIMIT nesta consulta sao do SQLite.
-- ------------------------------------------------------------

SELECT
    id_pedido,
    COUNT(*) AS total_itens,
    GROUP_CONCAT(DISTINCT status_venda) AS status_encontrados
FROM fato_vendas
GROUP BY id_pedido
HAVING COUNT(DISTINCT status_venda) > 1
ORDER BY id_pedido
LIMIT 20;


-- ------------------------------------------------------------
-- 08. INSPECIONAR ITENS DE PEDIDOS ESPECIFICOS
-- Objetivo: comparar os itens e seus status/valores.
-- ------------------------------------------------------------

SELECT
    id_pedido,
    numero_item,
    produto_key,
    quantidade,
    status_venda,
    valor_bruto,
    valor_desconto,
    receita_liquida,
    custo_total,
    lucro
FROM fato_vendas
WHERE id_pedido IN (
    'PED-000128',
    'PED-000138',
    'PED-000009',
    'PED-000020'
)
ORDER BY id_pedido, numero_item;


-- ------------------------------------------------------------
-- 09. ESTRUTURA DA TABELA fato_vendas
-- Objetivo: listar colunas, tipos e informacoes estruturais.
-- PRAGMA table_info e especifico do SQLite.
-- ------------------------------------------------------------

PRAGMA table_info(fato_vendas);


-- ------------------------------------------------------------
-- 10. RECEITA E PEDIDOS POR MES
-- Objetivo: analisar a evolucao mensal dos itens concluidos.
-- Relacionamento: fato_vendas.data_key = dim_calendario.data_key.
-- ------------------------------------------------------------

SELECT
    c.ano,
    c.mes,
    c.nome_mes,
    COUNT(DISTINCT f.id_pedido) AS total_pedidos,
    ROUND(SUM(f.receita_liquida), 2) AS receita_liquida
FROM fato_vendas f
INNER JOIN dim_calendario c
    ON f.data_key = c.data_key
WHERE f.status_venda = 'Concluída'
GROUP BY
    c.ano,
    c.mes,
    c.nome_mes
ORDER BY
    c.ano,
    c.mes;


-- ============================================================
-- FIM DAS CONSULTAS INICIAIS
--
-- Proximas analises previstas:
-- - Receita por categoria/produto
-- - Receita por regiao
-- - Receita por canal
-- - Receita por vendedor
-- - Analise de clientes e segmentos
--
-- Antes de consolidar os KPIs, revisar as regras de negocio
-- para itens devolvidos e pedidos com status mistos.
-- ============================================================
