defmodule Poupanca do
  #Definimos que a criação de conta começa com 300 de saldo, para testarmos as funções
  defstruct usuario: Usuario, saldo: 300
  #Definindo o "contas.txt" em @contas
  @contas "contas.txt"

  #Função de cadastrar uma nova conta poupança, além disso transforma a conta criada em binario e escreve no "contas.txt"
  def cadastrar(usuario) do
    #Tratamento de erro de emails repetidos em contas
    case busca_por_email(usuario.email) do
      nil ->
        binary = [%__MODULE__{usuario: usuario}] ++ busca_contas()
        |> :erlang.term_to_binary()
        File.write(@contas, binary)
      _ -> {:error, "Conta ja cadastrada!"}
    end
  end

  #Função que busca todas as conas que estão no arquivo contas.txt, e as transforma de binario para termo
  def busca_contas do
    {:ok, binary} = File.read(@contas)
    :erlang.binary_to_term(binary)
  end

  #Função para comparar um email pesquisado com os emails ja criados
  def busca_por_email(email), do: Enum.find(busca_contas(), &(&1.usuario.email == email))

  #A função a seguir é uma função de investimento
  #de = email de uma conta_qualquer (em teoria, mas estamos usando um email de uma conta poupança)
  #para = email de uma conta_poupança
  def investir(de, para, valor_investido) do
    de = busca_por_email(de)
    para = busca_por_email(para)
    cond do
      #Tratamento de erro quando Saldo < valor_investido
      valida_saldo(de.saldo, valor_investido) -> {:error, "Saldo insuficiente!"}
      true ->
        #Aqui nós deletamos as contas da lista, modificamos os valores, e depois adicionamos de volta na lista
        contas = Poupanca.deletar([de, para])
        de = %Poupanca{de | saldo: de.saldo - valor_investido}
        para = %Poupanca{para | saldo: para.saldo + valor_investido}
        contas = contas ++ [de,para]
        #Salvando a transferência em "transacoes.txt" através do modulo de Transacao
        Transacao.gravar("Investimento", de.usuario.email, valor_investido, Date.utc_today(), para.usuario.email)
        File.write(@contas, :erlang.term_to_binary(contas))
    end
  end

  #Função de deletar conta, ou contas da lista
  def deletar(contas_deletar) do
    Enum.reduce(contas_deletar, busca_contas(), fn c, acc -> List.delete(acc, c) end)
  end

  #Função de retirar/sacar valores da conta_poupança
  def retirar(conta_poupanca, valor_retirado) do
    conta_poupanca = busca_por_email(conta_poupanca)
    cond do
      #Tratamento de erro de quando Saldo < valor_retirado
      valida_saldo(conta_poupanca.saldo, valor_retirado) -> {:error, "Saldo insuficiente!"}
      true ->
        #Aqui nós deletamos a contas da lista, modificamos o valor_retirado, e depois adicionamos de volta na lista
        contas = Poupanca.deletar([conta_poupanca])
        conta_poupanca = %Poupanca{conta_poupanca | saldo: conta_poupanca.saldo - valor_retirado}
        contas = contas ++ [conta_poupanca]
        #Salvando o recebimento em "transacoes.txt" através do modulo de Transacao
        Transacao.gravar("Recebimento/Saque", conta_poupanca.usuario.email, valor_retirado, Date.utc_today())
        File.write(@contas, :erlang.term_to_binary(contas))
        {:ok, conta_poupanca, "mensagem de email encaminhada!"}
    end
  end

  #Desenvolvendo a função de lucro das contas_poupanças
  #def lucros(conta_poupança, saldo) do
  #  conta_poupanca = busca_por_email(conta_poupanca)

  #end

  #Função que verifica se o saldo < valor
  defp valida_saldo(saldo, valor), do: saldo < valor
end
