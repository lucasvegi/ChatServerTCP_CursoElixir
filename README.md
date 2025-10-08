# ChatServer (Quadro de Mensagens TCP)

Este projeto implementa um **pequeno servidor TCP** desenvolvido em **Elixir puro**, com fins didáticos para um curso introdutório sobre a linguagem.

Os clientes podem se conectar ao servidor utilizando ``telnet`` ou ``nc``.

Para cada conexão, o servidor cria um **novo processo** com ``spawn/1``, responsável por lidar com as interações daquele cliente.

Cada cliente pode:

- Enviar mensagens para o servidor;
- Listar todas as mensagens enviadas por outros clientes;
- Visualizar os processos atualmente criados pelo servidor.

## Como executar no modo desenvolvimento

```bash
mix run --no-halt   # no diretório do projeto
```

## Como gerar e executar um release

```bash
MIX_ENV=prod
mix deps.get --only prod
mix compile
mix release
chat_server/_build/prod/rel/chat_server/bin/chat_server start
```

## Como os clientes se conectam ao servidor

```bash
telnet <IP_SERVIDOR> 4040
# ou
nc <IP_SERVIDOR> 4040
```

## Comandos disponíveis para os clientes

```bash
POST <mensagem>   # adiciona mensagem
LIST_MSGS         # busca todas as mensagens e envia ao cliente.
LIST_PIDS         # lista todos os processos criados no server e envia ao cliente.
EXIT              # encerra conexão
```