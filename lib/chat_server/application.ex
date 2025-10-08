defmodule ChatServer.Application do
  use Application # Esse comando indica que este módulo é o ponto de entrada da aplicação supervisionada.
                  # Ele implementa o comportamento (ou "contract") necessário para que o Elixir saiba como inicializar a aplicação.

  @doc """
    - Essa função é chamada automaticamente quando a aplicação inicia (no mix run ou no release).
    - Ela retorna um Supervisor com os processos filhos que devem ser iniciados e monitorados.

    children = [...]
      - Essa lista define os processos que o Elixir deve iniciar e manter vivos. Aqui temos dois:
          1. {ChatServer.MessageBoard, []}
              -> Inicia o módulo ChatServer.MessageBoard, que é um Agent.
              -> Esse Agent mantém a lista global de mensagens.
              -> Ele é nomeado (name: __MODULE__) dentro do módulo, então pode ser acessado globalmente.

          2. {Task, fn -> ChatServer.Server.start(4040) end}
              -> Inicia o servidor TCP na porta 4040 dentro de uma tarefa supervisionada (Task).
              -> A função ChatServer.Server.start/1 inicia o socket TCP e começa a aceitar conexões.
              -> Como está em um processo supervisionado, se ele falhar, o supervisor pode reiniciá-lo.

    opts = [strategy: :one_for_one, name: ChatServer.Supervisor]
      - Define o nome e a estratégia de supervisão.
      - :one_for_one: se algum processo filho cair, só ele será reiniciado (não todos).
      - O nome ChatServer.Supervisor permite referenciar o supervisor se necessário (por exemplo, para debugging).

    Supervisor.start_link(children, opts)
      - Inicia o supervisor com os filhos definidos.
      - A árvore de supervisão é ativada, e todos os processos são lançados automaticamente.
  """
  def start(_type, _args) do
    children = [
      {ChatServer.MessageBoard, []},
      {ChatServer.Registry, []},
      {Task, fn -> ChatServer.Server.start() end}
    ]

    opts = [strategy: :one_for_one, name: ChatServer.Supervisor]
    Supervisor.start_link(children, opts)
  end
end

# Como o projeto foi criado:
# mix new chat_server --sup

# Como iniciar a aplicação:
# mix.bat run --no-halt
# ou
# bin/chat_server start (no caso de release standalone)

# Como gerar release:
# 1) Compile e gere o release com:
#      SET MIX_ENV=prod
#      mix deps.get --only prod
#      mix compile
#      mix release
# 2) O release será gerado em: _build/prod/rel/chat_server/
# 3) Entre na pasta do release: cd _build/prod/rel/chat_server
# 4) Inicie o sistema com: bin/chat_server start
# 5) Parar o sistema de forma segura: bin/chat_server stop

# Acesso dos alunos:
# telnet <IP_DA_MAQUINA> 4040
# ou
# nc <IP_DA_MAQUINA> 4040 (no mac como cliente funcionou esse)
