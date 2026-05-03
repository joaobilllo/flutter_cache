# 03 - Arquitetura e organizacao

## Objetivo
- Ver se o codigo esta bem separado e facil de manter.

## Estrutura atual (resumo)
- lib/
	- main.dart: contem toda a aplicacao (UI, modelo, requisicoes HTTP e regras).
- docs/: textos das tarefas e analises.
- test/: testes padrao do template.
- android/, ios/, web/, macos/, windows/, linux/: scaffolding multiplataforma do Flutter.

## Problemas identificados
1. Acoplamento excessivo:
	- A UI chama a API diretamente (http + jsonDecode dentro do widget).
	- Modelo, parsing e regras de carregamento ficam no mesmo arquivo.
2. Falta de separacao entre UI, dados e regras:
	- Nao existe camada de dados (datasource/repository) nem dominio (use cases).
	- Estado e fluxo de carregamento ficam no State do widget.
3. Repeticao de logica:
	- Carregamento e tratamento de erro aparecem na tela e se repetiriam em outras telas.
	- Logica de imagens (Image.network + errorBuilder) repetida em lista e detalhe.

## Impacto tecnico
- Dificil testar (necessita widget test para testar regra de negocio e HTTP).
- Qualquer ajuste de API impacta diretamente a UI.
- Baixa reutilizacao: nao ha como reaproveitar regra de fetch/cache em outras telas.
- Refatoracao lenta: tudo concentrado em um arquivo.

## Sugestoes iniciais
- Reorganizar em camadas: data/ (datasources, DTOs), domain/ (entidades, use cases), presentation/ (widgets, view models).
- Criar repository (interface no dominio + implementacao em data) para buscar produtos.
- Mover parsing JSON para modelos em data/ e expor entidades limpas no dominio.
- Adotar um gerenciador de estado simples (ChangeNotifier, ValueNotifier) para separar fluxo da UI.
- Centralizar logica de imagens (widget reutilizavel com placeholder/erro).
