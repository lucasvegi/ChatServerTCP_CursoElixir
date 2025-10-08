
defmodule ChatServer.Server do
  @menu "Comandos: POST <mensagem>, LIST_MSGS, LIST_PIDS e EXIT\n"

  @moduledoc """
    - start/1 inicia o servidor.
    - loop_accept/1 aceita conexões de alunos.
    - Cada aluno que conecta é tratado por handle_client/1 → que chama loop/1.
    - O loop/1 interpreta os comandos e interage com o Agent MessageBoard.
  """

  # Função start/1
  # - Ponto de entrada do servidor.
  # - Abre um socket TCP escutando na porta especificada (padrão: 4040).
  # - Inicia o loop que aceita conexões (loop_accept/1).

  def start(port \\ 4040) do
    {:ok, socket} = :gen_tcp.listen(port, [:binary, packet: :line, active: false, reuseaddr: true])
    IO.puts("Servidor rodando na porta #{port}")
    loop_accept(socket)
  end

  # Função loop_accept/1
  # - Espera por uma nova conexão TCP com :gen_tcp.accept/1.
  # - Quando um cliente conecta, cria um processo novo com spawn(fn -> handle_client(...) end) para lidar com ele.
  # - Retorna para escutar por mais conexões (via recursividade).
  #   → Cada conexão é independente, tratada em seu próprio processo.

  defp loop_accept(socket) do
    {:ok, client} = :gen_tcp.accept(socket)

    pid =
      spawn(fn ->
        ChatServer.Registry.add(self())
        handle_client(client)
        ChatServer.Registry.remove(self()) # Remove processo da list quando cliente der EXIT, encerrando loop/1 e handle_client/1
      end)

    IO.puts("Cliente conectado = [Processo: #{inspect(pid)}]")
    list = list_clients()
    IO.puts("#{length(list)} Processo(s) criado(s) até o momento #{inspect(list)}\n")

    loop_accept(socket)
  end

  # Função handle_client/1
  # - Envia uma mensagem de boas-vindas e instruções ao cliente conectado.
  # - Chama loop/1 para iniciar o diálogo com o usuário.

  defp handle_client(socket) do
    :gen_tcp.send(socket, "\nBem-vindo ao Quadro de Mensagens!\n#{@menu}")

    IO.puts("\nCliente conectado = [Socket: #{inspect(socket)}]")
    loop(socket)
    IO.puts("\nCliente encerrado = [Socket: #{inspect(socket)}]\n") # só chega aqui quando função recursiva loop/1 terminar!
  end

  # Função loop/1
  # - É o "coração" da comunicação com um único cliente.
  # - Espera por entrada de dados com :gen_tcp.recv/2
  # - Interpreta o que foi digitado:
  #       -> POST <mensagem> → envia para MessageBoard, responde com confirmação.
  #       -> LIST_MSGS → busca todas as mensagens e envia ao cliente.
  #       -> LIST_PIDS → lista todos os processos criados no server e envia ao cliente.
  #       -> EXIT → fecha a conexão.
  #       -> Qualquer outra entrada → envia mensagem de erro.
  # - Depois de cada comando (exceto EXIT), volta para o próprio loop (via recursividade), permitindo múltiplas interações.

  defp loop(socket) do
    case :gen_tcp.recv(socket, 0) do
      {:ok, data} ->
        cleaned = String.trim(data)

        case String.split(cleaned, " ", parts: 2) do
          ["POST", msg] ->
            ChatServer.MessageBoard.post("#{inspect(socket)}: " <> msg)
            :gen_tcp.send(socket, "\nMensagem adicionada!\n\n#{@menu}")
            IO.puts("Mensagem \"#{msg}\" recebida de cliente: #{inspect(socket)}")
            loop(socket)

          ["LIST_MSGS"] ->
            messages = ChatServer.MessageBoard.list()
            :gen_tcp.send(socket,"\n" <> Enum.join(messages, "\n") <> "\n\n#{@menu}")
            loop(socket)

          ["LIST_PIDS"] ->
            pids = list_clients()
            :gen_tcp.send(socket, "\nTotal: #{length(pids)} processo(s)\n#{inspect(pids)}" <> "\n\n#{@menu}")
            loop(socket)

          ["EXIT"] ->
            :gen_tcp.send(socket, "\nTchau!\n")
            :gen_tcp.close(socket)

          _ ->
            :gen_tcp.send(socket, "\nComando inválido. Use #{@menu}")
            loop(socket)
        end

      {:error, _} -> :gen_tcp.close(socket)
    end
  end

  # Função list_clients/0
  # Mostra os processos de clientes registrados

  def list_clients() do
    ChatServer.Registry.list()
  end
end
