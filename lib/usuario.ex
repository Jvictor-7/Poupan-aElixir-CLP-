defmodule Usuario do
  #Definindo estrutura com nome e email
  defstruct nome: nil, email: nil
  #Função que cria um novo usuário
  def novo(nome, email), do: %__MODULE__{nome: nome, email: email}
end
