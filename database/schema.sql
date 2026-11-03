PRAGMA foreign_keys = ON;

DROP VIEW IF EXISTS vw_resumo_mensal;
DROP VIEW IF EXISTS vw_vendas_concluidas;
DROP TABLE IF EXISTS fato_vendas;
DROP TABLE IF EXISTS dim_canais;
DROP TABLE IF EXISTS dim_regioes;
DROP TABLE IF EXISTS dim_calendario;
DROP TABLE IF EXISTS dim_vendedores;
DROP TABLE IF EXISTS dim_clientes;
DROP TABLE IF EXISTS dim_produtos;

CREATE TABLE dim_produtos (
    produto_key INTEGER PRIMARY KEY,
    codigo_produto TEXT NOT NULL UNIQUE,
    nome_produto TEXT NOT NULL,
    categoria TEXT NOT NULL,
    subcategoria TEXT NOT NULL,
    marca TEXT NOT NULL,
    preco_tabela REAL NOT NULL CHECK (preco_tabela >= 0),
    custo_referencia REAL NOT NULL CHECK (custo_referencia >= 0)
);

CREATE TABLE dim_clientes (
    cliente_key INTEGER PRIMARY KEY,
    codigo_cliente TEXT NOT NULL UNIQUE,
    nome_cliente TEXT NOT NULL,
    segmento TEXT NOT NULL,
    data_cadastro TEXT NOT NULL,
    cidade TEXT NOT NULL,
    estado TEXT NOT NULL,
    regiao_cliente TEXT NOT NULL
);

CREATE TABLE dim_vendedores (
    vendedor_key INTEGER PRIMARY KEY,
    codigo_vendedor TEXT NOT NULL UNIQUE,
    nome_vendedor TEXT NOT NULL,
    equipe TEXT NOT NULL,
    cargo TEXT NOT NULL,
    data_admissao TEXT NOT NULL,
    status TEXT NOT NULL CHECK (status IN ('Ativo', 'Inativo'))
);

CREATE TABLE dim_calendario (
    data_key INTEGER PRIMARY KEY,
    data_completa TEXT NOT NULL UNIQUE,
    dia INTEGER NOT NULL,
    mes INTEGER NOT NULL,
    nome_mes TEXT NOT NULL,
    trimestre INTEGER NOT NULL,
    semestre INTEGER NOT NULL,
    ano INTEGER NOT NULL,
    dia_semana INTEGER NOT NULL,
    nome_dia TEXT NOT NULL
);

CREATE TABLE dim_regioes (
    regiao_key INTEGER PRIMARY KEY,
    codigo_regiao TEXT NOT NULL UNIQUE,
    nome_regiao TEXT NOT NULL,
    gerente_territorio TEXT NOT NULL,
    meta_mensal REAL NOT NULL CHECK (meta_mensal >= 0)
);

CREATE TABLE dim_canais (
    canal_key INTEGER PRIMARY KEY,
    codigo_canal TEXT NOT NULL UNIQUE,
    nome_canal TEXT NOT NULL,
    tipo_canal TEXT NOT NULL
);

CREATE TABLE fato_vendas (
    id_venda INTEGER PRIMARY KEY,
    id_pedido TEXT NOT NULL,
    numero_item INTEGER NOT NULL CHECK (numero_item >= 1),
    data_key INTEGER NOT NULL,
    produto_key INTEGER NOT NULL,
    cliente_key INTEGER NOT NULL,
    vendedor_key INTEGER NOT NULL,
    regiao_key INTEGER NOT NULL,
    canal_key INTEGER NOT NULL,
    quantidade INTEGER NOT NULL CHECK (quantidade > 0),
    preco_unitario REAL NOT NULL CHECK (preco_unitario >= 0),
    desconto_percentual REAL NOT NULL CHECK (desconto_percentual BETWEEN 0 AND 0.25),
    valor_bruto REAL NOT NULL CHECK (valor_bruto >= 0),
    valor_desconto REAL NOT NULL CHECK (valor_desconto >= 0),
    receita_liquida REAL NOT NULL CHECK (receita_liquida >= 0),
    custo_unitario REAL NOT NULL CHECK (custo_unitario >= 0),
    custo_total REAL NOT NULL CHECK (custo_total >= 0),
    lucro REAL NOT NULL,
    status_venda TEXT NOT NULL CHECK (
        status_venda IN ('Concluída', 'Pendente', 'Cancelada', 'Devolvida')
    ),
    UNIQUE (id_pedido, numero_item),
    FOREIGN KEY (data_key) REFERENCES dim_calendario(data_key),
    FOREIGN KEY (produto_key) REFERENCES dim_produtos(produto_key),
    FOREIGN KEY (cliente_key) REFERENCES dim_clientes(cliente_key),
    FOREIGN KEY (vendedor_key) REFERENCES dim_vendedores(vendedor_key),
    FOREIGN KEY (regiao_key) REFERENCES dim_regioes(regiao_key),
    FOREIGN KEY (canal_key) REFERENCES dim_canais(canal_key)
);

CREATE INDEX idx_fato_data ON fato_vendas(data_key);
CREATE INDEX idx_fato_produto ON fato_vendas(produto_key);
CREATE INDEX idx_fato_cliente ON fato_vendas(cliente_key);
CREATE INDEX idx_fato_pedido ON fato_vendas(id_pedido);
CREATE INDEX idx_fato_status ON fato_vendas(status_venda);

-- View para facilitar consultas: considera somente vendas concluídas.
CREATE VIEW vw_vendas_concluidas AS
SELECT *
FROM fato_vendas
WHERE status_venda = 'Concluída';

-- Resumo mensal pronto para exercícios de SQL e validação do dashboard.
CREATE VIEW vw_resumo_mensal AS
SELECT
    c.ano,
    c.mes,
    c.nome_mes,
    COUNT(DISTINCT f.id_pedido) AS quantidade_pedidos,
    SUM(f.quantidade) AS unidades_vendidas,
    ROUND(SUM(f.valor_bruto), 2) AS receita_bruta,
    ROUND(SUM(f.valor_desconto), 2) AS descontos,
    ROUND(SUM(f.receita_liquida), 2) AS receita_liquida,
    ROUND(SUM(f.custo_total), 2) AS custo_total,
    ROUND(SUM(f.lucro), 2) AS lucro,
    ROUND(100.0 * SUM(f.lucro) / NULLIF(SUM(f.receita_liquida), 0), 2) AS margem_percentual
FROM fato_vendas f
JOIN dim_calendario c ON c.data_key = f.data_key
WHERE f.status_venda = 'Concluída'
GROUP BY c.ano, c.mes, c.nome_mes;
