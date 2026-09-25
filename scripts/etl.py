import pandas as pd

# Ler CSV
df = pd.read_csv('data/vendas.csv')

# Limpeza
df = df.dropna()

# Transformação
df['data'] = pd.to_datetime(df['data'])
df['mes'] = df['data'].dt.month

# Cálculo
df['total'] = df['quantidade'] * df['preco_unitario']

# 🔥 IMPORTANTE: não agregar
# Exporta dados detalhados
df.to_json('docs/data.json', orient='records', date_format='iso')

print("ETL executado com sucesso")
