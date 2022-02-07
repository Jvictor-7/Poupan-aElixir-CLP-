defmodule Poupanca do
  defstruct usuario: Usuario, saldo: 1000
  @contas "contas.txt"

  def cadastrar(usuario) do
    case busca_por_email(usuario.email) do
      nil ->
        binary = [%__MODULE__{usuario: usuario}] ++ busca_contas()
        |> :erlang.term_to_binary()
        File.write(@contas, binary)
      _ -> {:error, "Conta ja cadastrada!"}
    end
  end

  def busca_contas() do
    {:ok, binary} = File.read(@contas)
    :erlang.binary_to_term(binary)
  end

  def busca_por_email(email), do: Enum.find(busca_contas(), &(&1.usuario.email == email))

  def investir(de, para, valor) do
    de = busca_por_email(de.usuario.email)
    cond do
      valida_saldo(de.saldo, valor) -> {:error, "Saldo insuficiente!"}
      true ->
        contas = busca_contas()
        contas = List.delete contas, de
        contas = List.delete contas, para
        de = %Poupanca{de | saldo: de.saldo - valor}
        para = %Poupanca{para | saldo: para.saldo + valor}
        contas = contas ++ [de,para]
        File.write(@contas, :erlang.term_to_binary(contas))
    end
  end

  def retirar(poupanca, valor) do
    cond do
      valida_saldo(poupanca.saldo, valor) -> {:error, "Saldo insuficiente!"}
      true ->
        contas = busca_contas()
        contas = List.delete contas, poupanca
        poupanca = %Poupanca{poupanca | saldo: poupanca.saldo - valor}
        contas = contas ++ [poupanca]
        File.write(@contas, :erlang.term_to_binary(contas))
        {:ok, poupanca, "mensagem de email encaminhada!"}
    end
  end

  defp valida_saldo(saldo, valor), do: saldo < valor
end
