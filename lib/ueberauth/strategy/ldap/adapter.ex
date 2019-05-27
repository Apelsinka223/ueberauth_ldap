defmodule Ueberauth.Strategy.LDAP.Adapter do
  @callback connect() :: {:ok, term()} | {:error, term()}

  @callback verify(connection :: term(), uid :: binary(), password :: binary)
            :: :ok | {:error, term()}

  @callback get(connection :: term(), uid :: binary) :: {:ok, map()} | {:error, term()}
end
