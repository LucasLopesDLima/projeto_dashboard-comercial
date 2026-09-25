import pandas as pd
from datetime import datetime

# Ler CSV
df = pd.read_csv('data/vendas.csv')

# Limpeza
df = df.dropna()

# Transformação
df['data'] = pd.to_datetime(df['data'])
df['mes'] = df['data'].dt.month

# Cálculo
df['total'] = df['quantidade'] * df['preco_unitario']

# 📌 Data de atualização
atualizacao = datetime.utcnow().strftime('%Y-%m-%d %H:%M:%S')

# 📦 Estrutura final
output = {
    "atualizado_em": atualizacao,
    "dados": df.to_dict(orient='records')
}

# Salvar JSON
import json
with open('docs/data.json', 'w', encoding='utf-8') as f:
    json.dump(output, f, ensure_ascii=False)

print("ETL executado com sucesso")
