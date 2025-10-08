defmodule ChatServer.MessageBoard do
  use Agent # Essa linha importa funções e comportamentos do módulo Agent,
            # permitindo que MessageBoard se comporte como um processo de estado controlado.
            # O Agent é ideal quando você quer armazenar dados acessíveis por múltiplos processos.

  @doc"""
    - Cria um novo processo Agent, iniciando o estado como uma lista vazia ([]).
    - O name: __MODULE__ permite que o Agent seja registrado com o nome :ChatServer.MessageBoard, ou seja,
              você pode acessá-lo de qualquer lugar sem precisar guardar o pid.
  """
  def start_link(_) do
    Agent.start_link(fn -> [] end, name: __MODULE__)
  end

  @doc """
    - Adiciona uma nova message ao estado atual do Agent.
    - Usa Agent.update/2 que:
      -> pega o estado atual (msgs),
      -> insere a nova mensagem no início da lista (mais eficiente),
      -> atualiza o estado com a nova lista.

    A ordem cronológica fica invertida, então na list/0 usamos Enum.reverse/1 para corrigir.
  """
  def post(message) do
    Agent.update(__MODULE__, fn msgs -> [message | msgs] end)
  end

  @doc """
    - Retorna a lista de mensagens atuais, do modo mais recente para o mais antigo (ordem cronológica).
    - Usa Agent.get/2 que:
      -> lê o estado atual (msgs),
      -> aplica a função (Enum.reverse/1) sobre ele,
      -> retorna o resultado.
  """
  def list do
    Agent.get(__MODULE__, fn msgs -> Enum.reverse(msgs) end)
  end
end
