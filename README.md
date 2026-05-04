# Flutter Problemático - Catálogo com Latência e Sem Cache

Os documentos detalhados e o resumo geral da atividade estao na pasta docs/.

Projeto didático propositalmente ruim para identificação e correção de problemas de:

- latência percebida
- baixa responsividade
- ausência de cache de dados
- ausência de cache explícito de imagens
- acoplamento entre UI e infraestrutura
- recarregamento desnecessário

## API usada

Este projeto consome a API pública DummyJSON:
- `GET https://dummyjson.com/products`

## Como executar

```bash
flutter pub get
flutter run
```
---

# Atividade Prática: Análise e Evolução de Aplicação Flutter

Esta atividade propõe a análise de um projeto Flutter construído propositalmente com limitações arquiteturais e problemas de comportamento relacionados a **latência**, **responsividade** e **ausência de estratégias adequadas de cache**.

A proposta consiste em examinar o sistema, identificar os problemas existentes e desenvolver uma versão estruturalmente mais adequada, justificando tecnicamente as decisões adotadas ao longo da evolução da aplicação.

## Acesso ao Projeto

O projeto-base da atividade está disponível neste repositório.

A partir dele, deve-se observar o comportamento da aplicação, analisar suas limitações e realizar as modificações consideradas necessárias.

## Objetivo da Atividade

O foco da atividade está em compreender que a qualidade de uma aplicação não depende apenas de seu funcionamento correto, mas também de sua organização interna e de sua forma de responder às interações do usuário.

Assim, a proposta não se limita a fazer o sistema “funcionar”, mas a examinar **como ele se comporta**, quais decisões prejudicam sua qualidade e quais mudanças podem torná-lo mais adequado do ponto de vista arquitetural e da experiência de uso.

## Proposta de Trabalho

Ao realizar esta atividade, espera-se que sejam desenvolvidas as seguintes ações:

1. Executar o projeto original e observar seu comportamento em uso.
2. Identificar os problemas arquiteturais e funcionais presentes na aplicação.
3. Registrar quais limitações afetam latência, responsividade, organização do código e experiência do usuário.
4. Evoluir o projeto para uma versão mais adequada.
5. Descrever com clareza as mudanças realizadas.
6. Justificar tecnicamente por que essas mudanças melhoram o sistema.
7. Apresentar o resultado final de forma organizada.

## Estrutura Atual (resumo)

Estrutura atual do projeto:

```
lib/
	main.dart
docs/
test/
android/
ios/
web/
macos/
windows/
linux/
```

Observacoes:
- lib/main.dart: concentra UI, modelo, requisicoes HTTP e regras.
- docs/: documentos da atividade.
- pastas de plataforma: scaffolding do Flutter.

## Problemas Identificados (resumo)

1. Acoplamento excessivo:
	- UI chamando API diretamente (http + jsonDecode no widget).
	- Modelo, parsing e regras no mesmo arquivo.
2. Falta de separacao entre UI, dados e regras:
	- Sem camada de dados ou dominio.
	- Estado e fluxo de carregamento no State do widget.
3. Repeticao de logica:
	- Tratamento de erro e carregamento espalhados.
	- Logica de imagens repetida em lista e detalhe.

## Resultado Esperado

Como resultado, espera-se uma versão modificada da aplicação acompanhada de uma análise objetiva dos problemas encontrados, de uma descrição das mudanças implementadas e de uma justificativa técnica que relacione cada alteração aos problemas identificados no projeto original.

## Critério Central de Análise

A análise da atividade deve considerar principalmente a capacidade de:

* compreender os problemas existentes no projeto original;
* reconhecer impactos arquiteturais e de experiência do usuário;
* propor e implementar melhorias coerentes;
* explicar tecnicamente as mudanças realizadas.

> Esta atividade não se limita à implementação de código. Seu propósito é desenvolver análise, diagnóstico, evolução arquitetural e argumentação técnica sobre decisões de projeto em aplicações interativas.


## Tasks

Organizacao do trabalho registrada no Jira, com tasks para completar a atividade e acompanhar o progresso.

### 01 - Latencia: diagnostico e evidencias (Luan Muhlbeier)
- Objetivo: encontrar onde o app fica lento e registrar provas simples (passos e prints).
- Ambiente de teste:
	- Dispositivo/Emulador: (ex.: iPhone 12, Pixel 5, emulador)
	- SO e versao: (ex.: iOS 17.2, Android 14)
	- Versao do Flutter:
	- Modo de execucao: debug / profile / release
- Passos para reproducao:
	- Abrir a tela X.
	- Tocar no botao Y.
	- Aguardar Z segundos e observar o atraso.
- Evidencias:
	- Tela/fluxo afetado:
	- Tempo percebido (aproximado): (ex.: 3 a 5s)
	- Prints/gravacao: (adicione o arquivo ou link)
- Hipoteses tecnicas:
	- Possiveis causas (ex.: chamadas repetidas, parsing pesado, imagens grandes):
- Impacto para o usuario:
	- Explique o efeito (ex.: usuario acha que travou, abandona a tela).
- Sugestoes iniciais:
	- Ideias de melhoria (nao precisa implementar aqui).

### 02 - Responsividade e UX (Matheus Akio)
- Objetivo: anotar problemas de layout e usabilidade em telas diferentes.
- Dispositivos/tamanhos testados:
	- Ex.: 360x640, 412x915, tablet 768x1024
- Problemas encontrados:
	- Tela/fluxo:
	- O que esta errado: (ex.: botao corta, texto estoura)
	- Como reproduzir: (passos simples)
- Evidencias:
	- Prints/gravacao: (adicione o arquivo ou link)
- Impacto para o usuario:
	- Ex.: quebra de layout, texto ilegivel, botao inacessivel.
- Sugestoes iniciais:
	- Ajustes possiveis (ex.: LayoutBuilder, MediaQuery, Expanded, FittedBox).

### 03 - Arquitetura e organizacao (Joao Victor Cassula Billo)
- Objetivo: ver se o codigo esta bem separado e facil de manter.
- Estrutura atual (resumo):
	- Liste as pastas principais e o que cada uma faz.
- Problemas identificados:
	- Acoplamento excessivo:
	- Falta de separacao entre UI, dados e regras:
	- Repeticao de logica:
- Impacto tecnico:
	- Explique o impacto (ex.: dificil testar, quebrar sem querer, refatorar demora).
- Sugestoes iniciais:
	- Possiveis reorganizacoes (ex.: data/domain/presentation).
	- Uso de services/repositories.

### 04 - Cache e desempenho (Arthur Felipe)
- Objetivo: propor cache para reduzir latencia e repeticao de chamadas.
- Observacoes:
	- Onde o app mais repete requisicoes ou recomputa dados:
- Proposta de cache:
	- Tipo: memoria / disco / ambos
	- Ferramentas sugeridas (ex.: shared_preferences, hive, sqlite)
	- Onde aplicar:
- Trade-offs:
	- Custo de armazenamento:
	- Consistencia dos dados:
	- Complexidade adicional:
- Beneficios esperados:
	- Reducao de latencia:
	- Melhor responsividade:

### 05 - Mudancas e justificativas tecnicas (Joao Victor Cassula Billo)
- Objetivo:
	- Registrar mudancas e explicar por que cada uma melhora o projeto.
- Mudancas realizadas:
	
	
	
	
- Justificativas tecnicas:
	- Para cada mudanca, explique qual problema resolve e por que melhora.
- Impacto esperado:
	- Performance:
	- Manutenibilidade:
	- Experiencia do usuario:
- Referencias:
	- Se houver artigos ou docs usados.

