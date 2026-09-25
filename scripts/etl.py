import pandas as pd
from datetime import datetime, timezone, timedelta
import json
import os

# Garantir pasta docs
os.makedirs('docs', exist_ok=True)

# Ler CSV
df = pd.read_csv('data/vendas.csv')

# Limpeza
df = df.dropna()

# Transformação
df['data'] = pd.to_datetime(df['data'])
df['mes'] = df['data'].dt.month

# 🔥 CONVERTER PARA STRING (ESSENCIAL)
df['data'] = df['data'].astype(str)

# Cálculo
df['total'] = df['quantidade'] * df['preco_unitario']

# Data de atualização (Brasil)
fuso_brasil = timezone(timedelta(hours=-3))
atualizacao = datetime.now(fuso_brasil).strftime('%d/%m/%Y %H:%M')

# Estrutura final
output = {
    "atualizado_em": atualizacao,
    "dados": df.to_dict(orient='records')
}

# Salvar JSON
with open('docs/data.json', 'w', encoding='utf-8') as f:
    json.dump(output, f, ensure_ascii=False)

print("ETL executado com sucesso")
