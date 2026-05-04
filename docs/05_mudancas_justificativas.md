# 05 - Mudancas e justificativas tecnicas

## Objetivo
- Registrar mudancas e explicar por que cada uma melhora o projeto.

## Mudancas realizadas
1. Arquitetura em camadas
	- Criado modulo domain com entidades (Product), contratos (ProductRepository) e casos de uso (GetProducts).
	- Criado modulo data com DTOs, datasource remoto e repositorio concreto.
	- Criado modulo presentation com pages, viewmodel e widgets reutilizaveis.
	- main.dart ficou apenas com bootstrap e composicao de dependencias.
2. Cache de dados com persistencia local
	- Adicionado ProductLocalDatasource usando SharedPreferences.
	- Implementado TTL de 2 minutos e politica network-first.
	- Fallback offline: se falhar rede, usa cache antigo quando existir.
3. Cache de imagens e placeholders
	- ProductImage migrou para CachedNetworkImage.
	- Placeholder simples e erro padrao para manter layout estavel.
4. Melhorias no fluxo de carregamento
	- Loading inline quando ja existe lista em tela (LinearProgressIndicator).
	- Banner de modo offline exibindo a idade do cache.
	- Removido reload ao voltar da tela de detalhes.
5. Robustez de requisicoes
	- Timeout de 10s nas chamadas HTTP.
	- Bloqueio de chamadas paralelas no ViewModel (controle de concorrencia).
6. Responsividade basica
	- Lista virou GridView com maxCrossAxisExtent para adaptar a largura.

## Justificativas tecnicas
- Separacao em camadas reduz acoplamento entre UI e infraestrutura, permitindo evolucao de regra de negocio sem reescrever widgets.
- DTOs isolam parsing JSON e evitam que a UI dependa de formato de API, reduzindo impacto de mudancas no backend.
- Caso de uso centraliza a regra de carregamento, facilitando teste unitario sem widget test.
- Cache local evita novas chamadas em navegacao repetida e remove a latencia artificial percebida pelo usuario.
- TTL curto equilibra frescor e performance, evitando dados desatualizados por longos periodos.
- Fallback offline garante continuidade de uso quando a rede falha, melhorando confiabilidade.
- CachedNetworkImage reduz re-download e estabiliza layout com placeholder, evitando piscadas em lista.
- Loading inline evita tela vazia durante revalidacao e melhora percepcao de responsividade.
- Remover reload pos-detalhes elimina chamada desnecessaria e reduz consumo de rede.
- Timeout e bloqueio de concorrencia evitam fila de requisicoes e estados inconsistentes.
- Grid responsivo melhora leitura em telas grandes sem quebrar telas pequenas.

## Impacto esperado
- Performance: reducao de round-trips, uso de cache local e cache de imagens em disco, menor custo de renderizacao.
- Manutenibilidade: separacao por camadas, contratos explicitos, facil substituicao de fonte de dados.
- Experiencia do usuario: menos bloqueios, feedback de offline, navegacao mais fluida e previsivel.

## Referencias
- Flutter docs: shared_preferences.
- Flutter docs: cached_network_image.
