defmodule Ueberauth.Strategy.LDAPTest do
  use ExUnit.Case
  use Plug.Test
  import Mox

  setup :verify_on_exit!

  @router SpecRouter.init([])

  test "request phase" do
    conn =
      :get
      |> conn("/auth/ldap")
      |> SpecRouter.call(@router)

    assert conn.resp_body == "ldap request"
  end

  test "default callback phase" do
    Ueberauth.Strategy.LDAP.AdapterMock
    |> expect(:connect, fn -> {:ok, "connection"} end)
    |> expect(:verify, fn "connection", "some uid", "password" -> :ok end)
    |> expect(:get, fn "connection", "some uid" ->
         {:ok,
           %{
             email: "some email",
             name: "first_name last_name",
             password: "some encrypted password",
             raw: "some raw result"
           }}
       end)

    opts = %{
      uid: "some uid",
      password: "password",
    }

    query = URI.encode_query(opts)

    conn =
      :get
      |> conn("/auth/ldap/callback?#{query}")
      |> SpecRouter.call(@router)

    assert conn.resp_body == "ldap callback"

    auth = conn.assigns.ueberauth_auth

    assert auth.provider == :ldap
    assert auth.strategy == Ueberauth.Strategy.LDAP
    assert auth.uid == opts.uid

    info = auth.info
    assert info.email == "some email"
    assert info.name == "first_name last_name"
    assert info.first_name == "first_name"
    assert info.last_name == "last_name"
    assert info.nickname == nil
    assert info.phone == nil
    assert info.location == nil
    assert info.description == nil

    creds = auth.credentials
    assert creds.other.password == "some encrypted password"

    extra = auth.extra

    assert extra.raw_info == "some raw result"
  end

  test "overridden callback phase" do
    Ueberauth.Strategy.LDAP.AdapterMock
    |> expect(:connect, fn -> {:ok, "connection"} end)
    |> expect(:verify, fn "connection", "some uid", "password" -> :ok end)
    |> expect(:get, fn "connection", "some uid" ->
      {:ok,
        %{
          email: "some email",
          name: "first_name last_name",
          password: "some encrypted password",
          raw: "some raw result"
        }}
    end)

    opts = %{
      "user[username]" => "some uid",
      "user[password]" => "password",
    }

    query = URI.encode_query(opts)

    conn =
      :get
      |> conn("/auth/ldap_with_options/callback?#{query}")
      |> SpecRouter.call(@router)

    assert conn.resp_body == "ldap with options callback"

    auth = conn.assigns.ueberauth_auth

    assert auth.provider == :ldap_with_options
    assert auth.strategy == Ueberauth.Strategy.LDAP
    assert auth.uid == "some uid"

    info = auth.info
    assert info.email == "some email"
    assert info.name == "first_name last_name"
    assert info.first_name == "first_name"
    assert info.last_name == "last_name"
    assert info.nickname == nil
    assert info.phone == nil
    assert info.location == nil
    assert info.description == nil
  end

  test "callback phase with nested params" do
    Ueberauth.Strategy.LDAP.AdapterMock
    |> expect(:connect, fn -> {:ok, "connection"} end)
    |> expect(:verify, fn "connection", "some uid", "password" -> :ok end)
    |> expect(:get, fn "connection", "some uid" ->
      {:ok,
        %{
          email: "some email",
          name: "first_name last_name",
          password: "some encrypted password",
          raw: "some raw result"
        }}
    end)

    opts = %{
      "data[attributes][uid]" => "some uid",
      "data[attributes][password]" => "password",
    }

    query = URI.encode_query(opts)

    conn =
      :get
      |> conn("/auth/ldap_with_nested_options/callback?#{query}")
      |> SpecRouter.call(@router)

    assert conn.resp_body == "ldap with nested options callback"

    auth = conn.assigns.ueberauth_auth

    assert auth.provider == :ldap_with_nested_options
    assert auth.strategy == Ueberauth.Strategy.LDAP
    assert auth.uid == "some uid"

    info = auth.info
    assert info.email == "some email"
    assert info.name == "first_name last_name"
    assert info.first_name == "first_name"
    assert info.last_name == "last_name"
    assert info.nickname == nil
    assert info.phone == nil
    assert info.location == nil
    assert info.description == nil
  end

  @tag skip: true
  test "test on real server" do
    opts = %{
      "uid" => "riemann",
      "password" => "password",
    }

    query = URI.encode_query(opts)

    conn =
      :get
      |> conn("/auth/ldap_real_server/callback?#{query}")
      |> SpecRouter.call(@router)

    assert conn.resp_body == "ldap with real server"

    auth = conn.assigns.ueberauth_auth

    assert auth.provider == :ldap_real_server
    assert auth.strategy == Ueberauth.Strategy.LDAP
    assert auth.uid == "riemann"

    info = auth.info
    assert info.email == "riemann@ldap.forumsys.com"
    assert info.name == "Bernhard Riemann"
    assert info.first_name == "Bernhard"
    assert info.last_name == "Riemann"
    assert info.nickname == nil
    assert info.phone == nil
    assert info.location == nil
    assert info.description == nil
  end

  test "with `connect/0` returning error callback phase" do
    Ueberauth.Strategy.LDAP.AdapterMock
    |> expect(:connect, fn -> {:error, "some error"} end)

    opts = %{
      uid: "some uid",
      password: "password",
    }

    query = URI.encode_query(opts)

    conn =
      :get
      |> conn("/auth/ldap/callback?#{query}")
      |> SpecRouter.call(@router)

    assert conn.resp_body == "ldap callback"

    error = conn.assigns.ueberauth_failure
    assert %Ueberauth.Failure{
             errors: [
               %Ueberauth.Failure.Error{message: "some error", message_key: "exldap"}
             ],
             provider: :ldap,
             strategy: Ueberauth.Strategy.LDAP
           } = error
  end

  test "with `verify/3` returning error callback phase" do
    Ueberauth.Strategy.LDAP.AdapterMock
    |> expect(:connect, fn -> {:ok, "connection"} end)
    |> expect(:verify, fn "connection", "some uid", "password" -> {:error, "some error"} end)

    opts = %{
      uid: "some uid",
      password: "password",
    }

    query = URI.encode_query(opts)

    conn =
      :get
      |> conn("/auth/ldap/callback?#{query}")
      |> SpecRouter.call(@router)

    assert conn.resp_body == "ldap callback"

    error = conn.assigns.ueberauth_failure
    assert %Ueberauth.Failure{
             errors: [
               %Ueberauth.Failure.Error{message: "some error", message_key: "exldap"}
             ],
             provider: :ldap,
             strategy: Ueberauth.Strategy.LDAP
           } = error
  end

  test "with `get/2` returning error callback phase" do
    Ueberauth.Strategy.LDAP.AdapterMock
    |> expect(:connect, fn -> {:ok, "connection"} end)
    |> expect(:verify, fn "connection", "some uid", "password" -> :ok end)
    |> expect(:get, fn "connection", "some uid" -> {:error, "some error"} end)

    opts = %{
      uid: "some uid",
      password: "password",
    }

    query = URI.encode_query(opts)

    conn =
      :get
      |> conn("/auth/ldap/callback?#{query}")
      |> SpecRouter.call(@router)

    assert conn.resp_body == "ldap callback"

    error = conn.assigns.ueberauth_failure
    assert %Ueberauth.Failure{
             errors: [
               %Ueberauth.Failure.Error{message: "some error", message_key: "exldap"}
             ],
             provider: :ldap,
             strategy: Ueberauth.Strategy.LDAP
           } = error
  end
end
