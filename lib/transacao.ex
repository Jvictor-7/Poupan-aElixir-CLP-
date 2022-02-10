defmodule Transacao do
  #Definindo uma estrutura
  defstruct data: Date.utc_today, tipo: nil, valor: 0, de: nil, para: nil

  #Denominado o arquivo "transacoes.txt" na variavel @transacoes
  @transacoes "transacoes.txt"

  #Função de gravar os dados de transações ocorridas com contas poupanças
  def gravar(tipo, de, valor, data, para \\ nil) do
    transacoes = busca_transacoes() ++
    [%__MODULE__{tipo: tipo, de: de, valor: valor, data: data, para: para}]
    #Escrevendo os dados no arquivo "transacoes.txt"
    File.write(@transacoes, :erlang.term_to_binary(transacoes))
  end

  #Função de buscar todas as transações
  def busca_todas(), do: busca_transacoes()

  #Função de ler todas as transações no arquivo "transacoes.txt" e transformar de binario para termo
  defp busca_transacoes() do
      File.read(@transacoes)
      {:ok, binario} = File.read(@transacoes)
      binario
      |> :erlang.binary_to_term()
  end
end
