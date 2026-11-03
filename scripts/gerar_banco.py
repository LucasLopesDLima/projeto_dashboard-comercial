import sqlite3
import random
from datetime import date, timedelta
from pathlib import Path

# Gera um banco SQLite com dados inteiramente fictícios.
# Uso: python scripts/gerar_banco.py (ajuste DB_PATH se necessário)
random.seed(42)

DB_PATH = Path(__file__).resolve().parent.parent / "database" / "comercial.db"
DB_PATH.parent.mkdir(parents=True, exist_ok=True)

SCHEMA_PATH = Path(__file__).resolve().parent.parent / "database" / "schema.sql"
SCHEMA = SCHEMA_PATH.read_text(encoding="utf-8")

conn = sqlite3.connect(DB_PATH)
conn.execute("PRAGMA foreign_keys = ON")
conn.executescript(SCHEMA)
cur = conn.cursor()

meses = ["Janeiro", "Fevereiro", "Março", "Abril", "Maio", "Junho",
         "Julho", "Agosto", "Setembro", "Outubro", "Novembro", "Dezembro"]
dias = ["Segunda-feira", "Terça-feira", "Quarta-feira", "Quinta-feira",
        "Sexta-feira", "Sábado", "Domingo"]

# 1) Calendário: 01/11/2024 a 31/10/2026
inicio, fim = date(2024, 11, 1), date(2026, 10, 31)
d = inicio
while d <= fim:
    key = int(d.strftime("%Y%m%d"))
    cur.execute("""INSERT INTO dim_calendario VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)""",
        (key, d.isoformat(), d.day, d.month, meses[d.month-1],
         (d.month-1)//3+1, 1 if d.month <= 6 else 2, d.year,
         d.weekday()+1, dias[d.weekday()]))
    d += timedelta(days=1)

# 2) Produtos
categorias = {
    "Tecnologia": ["Notebook", "Monitor", "Teclado", "Mouse", "Headset"],
    "Escritório": ["Cadeira", "Mesa", "Armário", "Papel A4", "Caneta"],
    "Acessórios": ["Mochila", "Suporte", "Cabo", "Adaptador", "Webcam"],
    "Mobiliário": ["Estante", "Gaveteiro", "Luminária", "Mesa auxiliar", "Poltrona"]
}
marcas = ["NorteTech", "PontoOffice", "AlfaPro", "ViaDigital", "Orbe"]
produtos = []
pk = 1
for categoria, subcats in categorias.items():
    for sub in subcats:
        for variante in range(1, 6):
            preco = round(random.uniform(35, 3200), 2)
            custo = round(preco * random.uniform(0.48, 0.78), 2)
            nome = f"{sub} Modelo {variante:02d}"
            row = (pk, f"PRD-{pk:04d}", nome, categoria, sub,
                   random.choice(marcas), preco, custo)
            cur.execute("INSERT INTO dim_produtos VALUES (?, ?, ?, ?, ?, ?, ?, ?)", row)
            produtos.append((pk, preco, custo))
            pk += 1

# 3) Clientes fictícios
nomes = ["Ana", "Bruno", "Carla", "Daniel", "Eduarda", "Felipe", "Giovana",
         "Henrique", "Isabela", "João", "Larissa", "Marcos", "Natália", "Otávio",
         "Paula", "Rafael", "Sofia", "Tiago", "Valentina", "Wesley"]
sobrenomes = ["Almeida", "Barbosa", "Carvalho", "Dias", "Esteves", "Ferreira",
              "Gomes", "Lima", "Mendes", "Nogueira", "Oliveira", "Pereira",
              "Ribeiro", "Santos", "Teixeira", "Vieira"]
cidades = [
    ("São Paulo", "SP", "Sudeste"), ("Campinas", "SP", "Sudeste"),
    ("Rio de Janeiro", "RJ", "Sudeste"), ("Belo Horizonte", "MG", "Sudeste"),
    ("Curitiba", "PR", "Sul"), ("Porto Alegre", "RS", "Sul"),
    ("Florianópolis", "SC", "Sul"), ("Salvador", "BA", "Nordeste"),
    ("Recife", "PE", "Nordeste"), ("Fortaleza", "CE", "Nordeste"),
    ("Brasília", "DF", "Centro-Oeste"), ("Goiânia", "GO", "Centro-Oeste"),
    ("Cuiabá", "MT", "Centro-Oeste"), ("Manaus", "AM", "Norte"),
    ("Belém", "PA", "Norte"), ("Palmas", "TO", "Norte")
]
segmentos = ["Pequena empresa", "Média empresa", "Grande empresa", "Pessoa física"]
clientes = []
for i in range(1, 1001):
    cidade, estado, regiao = random.choice(cidades)
    nome = f"{random.choice(nomes)} {random.choice(sobrenomes)}"
    cadastro = date(2020, 1, 1) + timedelta(days=random.randint(0, 2400))
    row = (i, f"CLI-{i:05d}", nome, random.choice(segmentos), cadastro.isoformat(),
           cidade, estado, regiao)
    cur.execute("INSERT INTO dim_clientes VALUES (?, ?, ?, ?, ?, ?, ?, ?)", row)
    clientes.append(i)

# 4) Vendedores
vendedores = []
for i in range(1, 31):
    admissao = date(2019, 1, 1) + timedelta(days=random.randint(0, 2500))
    row = (i, f"VEN-{i:03d}", f"{random.choice(nomes)} {random.choice(sobrenomes)}",
           f"Equipe {((i-1)//5)+1}", random.choice(["Executivo de vendas", "Analista comercial", "Consultor"]),
           admissao.isoformat(), random.choices(["Ativo", "Inativo"], weights=[92, 8])[0])
    cur.execute("INSERT INTO dim_vendedores VALUES (?, ?, ?, ?, ?, ?, ?)", row)
    vendedores.append(i)

# 5) Territórios comerciais (uma região por macro-região)
regioes = [
    (1, "REG-N", "Norte", "Gerência Norte", 180000),
    (2, "REG-NE", "Nordeste", "Gerência Nordeste", 260000),
    (3, "REG-CO", "Centro-Oeste", "Gerência Centro-Oeste", 210000),
    (4, "REG-SE", "Sudeste", "Gerência Sudeste", 520000),
    (5, "REG-S", "Sul", "Gerência Sul", 330000),
]
cur.executemany("INSERT INTO dim_regioes VALUES (?, ?, ?, ?, ?)", regioes)

# 6) Canais
canais = [
    (1, "CAN-ECOM", "E-commerce", "Digital"),
    (2, "CAN-LOJA", "Loja física", "Presencial"),
    (3, "CAN-REP", "Representante comercial", "Vendas diretas"),
    (4, "CAN-MKT", "Marketplace", "Digital")
]
cur.executemany("INSERT INTO dim_canais VALUES (?, ?, ?, ?)", canais)

# 7) 20.000 linhas de itens de venda; pedidos podem conter vários itens.
datas = []
d = inicio
while d <= fim:
    datas.append(int(d.strftime("%Y%m%d")))
    d += timedelta(days=1)

linhas = []
pedido_num = 1
while len(linhas) < 20000:
    itens_pedido = random.choices([1, 2, 3, 4], weights=[45, 35, 15, 5])[0]
    id_pedido = f"PED-{pedido_num:06d}"
    data_key = random.choice(datas)
    cliente = random.choice(clientes)
    vendedor = random.choice(vendedores)
    regiao = random.choices([1,2,3,4,5], weights=[8,20,10,42,20])[0]
    canal = random.choices([1,2,3,4], weights=[35,25,25,15])[0]
    for item in range(1, itens_pedido+1):
        if len(linhas) >= 20000:
            break
        produto_key, preco_base, custo_base = random.choice(produtos)
        qtd = random.randint(1, 20)
        preco = round(preco_base * random.uniform(0.90, 1.10), 2)
        desconto_pct = round(random.uniform(0, 0.25), 4)
        bruto = round(qtd * preco, 2)
        desconto = round(bruto * desconto_pct, 2)
        liquida = round(bruto - desconto, 2)
        custo_unit = round(custo_base * random.uniform(0.97, 1.03), 2)
        custo_total = round(qtd * custo_unit, 2)
        lucro = round(liquida - custo_total, 2)
        status = random.choices(
            ["Concluída", "Pendente", "Cancelada", "Devolvida"],
            weights=[88, 5, 5, 2]
        )[0]
        linhas.append((id_pedido, item, data_key, produto_key, cliente, vendedor,
                       regiao, canal, qtd, preco, desconto_pct, bruto, desconto,
                       liquida, custo_unit, custo_total, lucro, status))
    pedido_num += 1

cur.executemany("""
INSERT INTO fato_vendas (
    id_pedido, numero_item, data_key, produto_key, cliente_key, vendedor_key,
    regiao_key, canal_key, quantidade, preco_unitario, desconto_percentual,
    valor_bruto, valor_desconto, receita_liquida, custo_unitario, custo_total,
    lucro, status_venda
) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
""", linhas)

conn.commit()

# Validações básicas
total = cur.execute("SELECT COUNT(*) FROM fato_vendas").fetchone()[0]
dim_counts = {
    "produtos": cur.execute("SELECT COUNT(*) FROM dim_produtos").fetchone()[0],
    "clientes": cur.execute("SELECT COUNT(*) FROM dim_clientes").fetchone()[0],
    "vendedores": cur.execute("SELECT COUNT(*) FROM dim_vendedores").fetchone()[0],
    "calendario": cur.execute("SELECT COUNT(*) FROM dim_calendario").fetchone()[0],
    "regioes": cur.execute("SELECT COUNT(*) FROM dim_regioes").fetchone()[0],
    "canais": cur.execute("SELECT COUNT(*) FROM dim_canais").fetchone()[0],
}
fk_errors = cur.execute("PRAGMA foreign_key_check").fetchall()
print(f"Banco criado em: {DB_PATH}")
print(f"Itens de venda: {total:,}".replace(",", "."))
print(f"Dimensões: {dim_counts}")
print(f"Erros de chave estrangeira: {len(fk_errors)}")
conn.close()
