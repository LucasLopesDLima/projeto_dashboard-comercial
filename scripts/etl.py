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

# Agregação simples (ex: total por vendedor)
resumo = df.groupby('vendedor')['total'].sum().reset_index()

# Salvar JSON para dashboard
resumo.to_json('docs/data.json', orient='records')

print("ETL executado com sucesso")
