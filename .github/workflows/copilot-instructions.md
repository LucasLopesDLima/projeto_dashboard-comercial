# Instruções permanentes — Dashboard de Compras

## 1. Identidade visual

Antes de desenvolver ou modificar componentes visuais, consulte os documentos:

- `design/apple-light.md`: identidade visual do modo claro.
- `design/linear-dark.md`: identidade visual do modo escuro.

Preserve a consistência visual entre os temas.

## 2. Arquitetura do projeto

Respeite a estrutura existente:

- `docs/index.html`: página principal do dashboard.
- `docs/data.json`: dados consumidos pelo dashboard.
- `design/`: documentação dos temas visuais.
- `scripts/`: scripts Python e processamento de dados.
- `.github/workflows/pipeline.yml`: automação do projeto.
- `README.md`: documentação principal do projeto.

Não mova, renomeie ou exclua arquivos sem autorização.

## 3. Tecnologias

- HTML, CSS e JavaScript para o dashboard.
- Python e Pandas para processamento de dados.
- GitHub Actions para automação.
- GitHub Pages para publicação, conforme configuração existente.

Não introduza frameworks ou dependências adicionais sem autorização.

## 4. Regras de desenvolvimento

- Analise os códigos existentes antes de modificá-los.
- Preserve a arquitetura e a lógica atual.
- Não altere cálculos, indicadores ou regras de negócio sem solicitação.
- Preserve a responsividade e a acessibilidade.
- Evite duplicação de código.
- Respeite os dois temas visuais.

## 5. Validação

Após cada implementação:

- Verifique o funcionamento do dashboard.
- Teste os modos claro e escuro.
- Confira gráficos, filtros, tooltips e interações.
- Verifique possíveis impactos nos caminhos dos arquivos e na integração com os dados.

## 6. Comunicação

Antes de alterações estruturais, explique o impacto e aguarde autorização.

Ao concluir cada tarefa, informe os arquivos modificados, as alterações realizadas e os testes executados.