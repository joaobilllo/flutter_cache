# 01 — Latência: Diagnóstico e Evidências

## Objetivo

Identificar onde o app fica lento e registrar evidências técnicas com base na análise do código-fonte do projeto `flutter_cache`.

---

## Ambiente de Teste

| Campo                     | Valor                                        |
|---------------------------|----------------------------------------------|
| Dispositivo / Emulador    | Emulador Android — Pixel 7 Pro (AVD Manager) |
| Sistema Operacional       | Android 14 (API Level 34)                    |
| Versão do Flutter         | Flutter 3.22.x (stable channel)              |
| Versão do Dart            | Dart 3.4.x                                   |
| Modo de execução          | Debug (`flutter run`)                        |
| Repositório analisado     | github.com/jeffersonspeck/flutter_cache       |

---

## Problemas de Latência Identificados

### Problema 1 — Atraso Artificial de 2 Segundos no Carregamento

**Localização:** `lib/main.dart` — método `loadProducts()`

```dart
// PROBLEMA INTENCIONAL (comentário do próprio código):
await Future.delayed(const Duration(seconds: 2));

final response = await http.get(
  Uri.parse('https://dummyjson.com/products?limit=30'),
);
```

Antes de realizar qualquer requisição HTTP, o método executa um delay fixo de 2 segundos sem nenhuma finalidade funcional. O próprio autor marcou isso como `// PROBLEMA INTENCIONAL` no código.

**Passos para reprodução:**

1. Abrir o aplicativo no emulador.
2. Observar a tela inicial — um `CircularProgressIndicator` é exibido imediatamente.
3. Aguardar: a lista de produtos não aparece por pelo menos 2 segundos + tempo de rede.
4. Medir o tempo total: tipicamente **3 a 5 segundos** até a lista ser exibida.

**Evidências:**

- **Tela/fluxo afetado:** `ProductListPage` — tela inicial do aplicativo
- **Tempo percebido (aproximado):** 3 a 5 segundos do lançamento até a exibição da lista
- **Causa confirmada no código:** `await Future.delayed(const Duration(seconds: 2))` executado antes do `http.get()`

---

### Problema 2 — Recarregamento Completo da Lista ao Retornar dos Detalhes

**Localização:** `lib/main.dart` — método `openDetails()`

```dart
Future<void> openDetails(Product product) async {
  await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => ProductDetailPage(product: product),
    ),
  );

  // PROBLEMA INTENCIONAL (comentário do próprio código):
  // Ao voltar da tela de detalhes, refaz a chamada remota inteira.
  await loadProducts(); // ← reload desnecessário aqui
}
```

Ao tocar em um produto e depois pressionar Voltar, o app descarta todos os dados já carregados e refaz a requisição HTTP completa — incluindo o delay artificial de 2 segundos.

**Passos para reprodução:**

1. Com a lista de produtos já carregada, tocar em qualquer item.
2. Visualizar a tela de detalhes.
3. Pressionar o botão Voltar.
4. Observar: a tela retorna ao `CircularProgressIndicator` bloqueante e a lista some por 3 a 5 segundos.

**Evidências:**

- **Tela/fluxo afetado:** Transição `ProductDetailPage` → `ProductListPage`
- **Tempo percebido (aproximado):** 3 a 5 segundos adicionais a cada retorno
- **Causa confirmada no código:** `await loadProducts()` chamado incondicionalmente após o pop da rota

---

### Problema 3 — Imagens Carregadas Sem Cache e Sem Placeholder

**Localização:** `lib/main.dart` — `ProductListPage` (thumbnails) e `ProductDetailPage` (galeria)

```dart
// PROBLEMA INTENCIONAL (comentário do próprio código):
// Uso direto, sem cache explícito, sem placeholder elegante,
// sem política mais robusta para imagens.
Image.network(
  product.thumbnail,
  width: 72,
  height: 72,
  fit: BoxFit.cover,
)
```

Todas as imagens são carregadas via `Image.network()` puro, sem cache persistente em disco, sem placeholder durante o carregamento e sem controle de prioridade. A cada reload da lista (inclusive os causados pelo Problema 2), todas as imagens precisam ser baixadas novamente.

**Passos para reprodução:**

1. Com a lista carregada, rolar rapidamente pelos produtos.
2. Observar espaços vazios ou flash branco nos thumbnails enquanto as imagens carregam.
3. Voltar da tela de detalhes para acionar o reload — observar todas as imagens sumindo e reaparecendo.

**Evidências:**

- **Tela/fluxo afetado:** `ProductListPage` (thumbnails) e `ProductDetailPage` (galeria de imagens)
- **Comportamento observado:** Flash branco ou ícone de erro temporário nos thumbnails a cada rebuild
- **Causa confirmada no código:** `Image.network()` sem `cached_network_image`, sem `loadingBuilder` e sem `cacheWidth`

---

## Resumo dos Problemas

| Problema                          | Tempo de Impacto                  | Frequência                                      |
|-----------------------------------|-----------------------------------|-------------------------------------------------|
| Delay artificial de 2s            | 2s fixos + latência de rede (~1–3s) | Toda abertura do app e todo refresh             |
| Reload ao voltar dos detalhes     | 3 a 5s adicionais                 | Toda navegação para detalhes e retorno          |
| Imagens sem cache                 | Variável (depende da rede)        | Toda renderização da lista ou rebuild forçado   |

---

## Hipóteses Técnicas

**Problema 1 — Delay artificial:**
- O `Future.delayed()` simula um anti-padrão comum: código de teste esquecido em produção.
- A ausência de cache local (SharedPreferences, Hive, SQLite) força a requisição HTTP a sempre partir do zero, sem possibilidade de resposta imediata com dados previamente carregados.

**Problema 2 — Reload ao retornar:**
- O `loadProducts()` é chamado incondicionalmente após o pop, indicando ausência de gerenciamento de estado (Provider, Riverpod, Bloc) que manteria os dados em memória entre as telas.
- Sem uma camada de repositório separada da UI, o estado da lista fica acoplado ao ciclo de vida do `State<ProductListPage>`.

**Problema 3 — Imagens sem cache:**
- O Flutter possui cache interno de imagens em memória (`ImageCache`), mas ele não persiste entre sessões e pode ser descartado sob pressão de memória.
- A ausência de `cacheWidth` impede o Flutter de redimensionar as imagens antes de decodificá-las, gerando trabalho desnecessário na thread de UI.

---

## Impacto para o Usuário

- **Abertura do app:** mais de 3 segundos de tela bloqueante sem indicação de progresso parcial. Estudos de UX indicam que atrasos acima de 3 segundos aumentam expressivamente a taxa de abandono.
- **Navegação:** ao voltar da tela de detalhes, a lista some e precisa ser recarregada integralmente, fazendo o app parecer instável ou travado.
- **Rolagem:** thumbnails com espaços vazios (sem skeleton ou placeholder) criam percepção de app incompleto, mesmo com boa conexão.
- **Consumo de dados:** cada retorno da tela de detalhes gera uma nova requisição HTTP completa de 30 produtos, desperdiçando banda e bateria.

> **Efeito consolidado:** o usuário percebe o app como lento e inconsistente — não por falha da infraestrutura remota, mas por decisões arquiteturais no código da aplicação.

---

## Sugestões Iniciais de Melhoria

> *(Implementação detalhada será abordada nas demais seções da atividade.)*

**Para o Problema 1:**
- Remover o `await Future.delayed()` do código de produção.
- Implementar cache local para exibir dados previamente carregados enquanto a atualização ocorre em segundo plano (estratégia *stale-while-revalidate*).

**Para o Problema 2:**
- Introduzir camada de repositório (`ProductRepository`) que mantenha os dados em memória durante a sessão.
- Adotar gerenciamento de estado (Provider ou Riverpod) para desacoplar a lista do ciclo de vida do widget.
- Remover `loadProducts()` do `openDetails()` — o reload só deve ocorrer quando explicitamente solicitado pelo usuário.

**Para o Problema 3:**
- Adicionar o pacote `cached_network_image` para cache persistente em disco.
- Implementar `placeholder` e `errorWidget` adequados para eliminar flashes visuais.
- Utilizar `cacheWidth` nos thumbnails para reduzir consumo de memória na decodificação.