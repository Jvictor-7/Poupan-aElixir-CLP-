defmodule Poupanca do
  defstruct usuario: Usuario, saldo: 1000

  def cadastrar(usuario), do: %__MODULE__{usuario: usuario}

  def investir(contas, de, para, valor) do
    de = Enum.find(contas, fn poupanca -> poupanca.usuario.email == de.usuario.email end)

    cond do
      valida_saldo(de.saldo, valor) -> {:error, "Saldo insuficiente!"}
      true ->
        para = Enum.find(contas, fn poupanca -> poupanca.usuario.email == para.usuario.email end)
        de = %Poupanca{de | saldo: de.saldo - valor}
        para = %Poupanca{para | saldo: para.saldo + valor}
      [de,para]
    end
  end

  def retirar(poupanca, valor) do
    cond do
      valida_saldo(poupanca.saldo, valor) -> {:error, "Saldo insuficiente!"}
      true ->
        poupanca = %Poupanca{poupanca | saldo: poupanca.saldo - valor}
      {:ok, poupanca, "Valor retirado com sucesso!"}
    end
  end

  defp valida_saldo(saldo,valor), do: saldo < valor
end
