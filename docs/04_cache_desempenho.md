# 04 - Cache e desempenho

## Objetivo
- Reduzir latencia percebida e eliminar chamadas de rede desnecessarias.
- Permitir uso do app em modo offline com os ultimos dados conhecidos.

## Observacoes (estado anterior)
- Toda abertura de tela disparava nova chamada a `https://dummyjson.com/products`.
- Ao voltar da tela de detalhes a lista era recarregada por completo, sem motivo (a tela de detalhes recebe o produto inteiro por parametro, nao consulta a API).
- Imagens usavam `Image.network` direto, sem cache em disco: a mesma thumb era baixada novamente a cada reentrada.
- O loading bloqueava a tela inteira (`CircularProgressIndicator` fullscreen) mesmo quando ja havia dados em memoria.
- Sem nenhum tratamento explicito para falta de conexao.
- Multiplos toques no botao refresh disparavam requisicoes em paralelo.

## Proposta de cache
- Tipo: disco (persistente entre sessoes), com TTL curto.
- Ferramenta: `shared_preferences` (JSON serializado da lista + timestamp).
- Cache de imagens: `cached_network_image` (gerencia cache de disco + memoria automaticamente).
- Onde aplicar:
	- Camada `data/`: novo `ProductLocalDatasource` com `read/save/clear`.
	- Repositorio `ProductRepositoryImpl` orquestra `remote` + `local`.
	- Widget `ProductImage` consome `cached_network_image` em vez de `Image.network`.

## Politica de cache (network-first com TTL e fallback offline)
- TTL = 2 minutos.
- Se houver cache e ele estiver dentro do TTL: retorna cache instantaneamente, sem ir a rede (status `fresh`).
- Caso contrario: tenta a rede (timeout de 10s); se sucesso, atualiza cache e retorna `network`.
- Se a rede falhar (`SocketException`, `TimeoutException`, `ClientException`):
	- Houver cache (de qualquer idade) → devolve cache marcado como `offline`.
	- Nao houver cache → lanca `NetworkUnavailableException`.
- Botao refresh manual ignora o TTL (forca ida a rede), mas mantem o fallback offline.

## Trade-offs
- Custo de armazenamento: irrisorio. O JSON da lista (~30 produtos) ocupa <50 KB; o cache de imagens cresce conforme uso, mas o `cached_network_image` faz LRU automatico.
- Consistencia dos dados: o TTL de 2 min limita a janela em que o usuario pode ver dado desatualizado em condicao normal. Em modo offline a UI deixa explicito por meio de banner.
- Complexidade adicional: um datasource extra, um enum (`CacheStatus`) e uma excecao (`NetworkUnavailableException`). Sem container de DI, o `main.dart` cresceu poucas linhas.

## Beneficios esperados
- Reducao de latencia: aberturas dentro de 2 min do ultimo sync sao instantaneas (zero round-trip).
- Melhor responsividade: revalidacoes nao bloqueiam mais a tela. Quando ja existe lista em memoria, o spinner vira uma `LinearProgressIndicator` fina no topo.
- Suporte a offline: usuario continua navegando com os ultimos dados conhecidos quando a rede cair.
- Imagens viajadas uma vez por dispositivo e nao novamente.

## Mudancas realizadas
1. Adicionadas dependencias `shared_preferences` e `cached_network_image` no `pubspec.yaml`.
2. Criado `lib/data/datasources/product_local_datasource.dart` com `read/save/clear` e serializacao JSON.
3. `ProductDto` ganhou `toMap()` (par do `fromMap`).
4. `ProductRemoteDatasource` agora aplica `timeout(10s)` no `client.get`.
5. Contrato `ProductRepository` retorna `ProductsResult` (record com `products`, `status`, `cachedAt`) e aceita `forceRefresh`. `GetProducts` propaga.
6. `ProductRepositoryImpl` implementa o algoritmo network-first com TTL e fallback offline.
7. `ProductListViewModel` adquiriu guarda de concorrencia (`_inFlight`), separacao `load()`/`refresh()`, e expoe `isOffline`/`lastSyncedAt`/`lastStatus`.
8. `ProductListPage`:
	- removeu o reload pos-detalhes;
	- usa `LinearProgressIndicator` quando ja ha dados em tela;
	- mostra `OfflineBanner` quando o status e `offline`.
9. Novo widget `OfflineBanner` exibe a idade do cache em linguagem natural ("ha X min").
10. `ProductImage` migrou para `CachedNetworkImage`.
11. `main.dart` inicializa `SharedPreferences` antes do `runApp` e injeta o `ProductLocalDatasource` no repositorio.
