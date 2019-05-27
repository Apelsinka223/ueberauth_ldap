defmodule Ueberauth.Strategy.LDAP do
  use Ueberauth.Strategy,
      uid_field: :uid,
      password_field: :password,
      param_nesting: nil,
      adapter: Ueberauth.Strategy.LDAP.Adapter.Exldap

  alias Ueberauth.Auth.{Credentials, Extra, Info}

  def handle_callback!(conn) do
    with adapter            = option(conn, :adapter),
         uid                = param_for(conn, :uid_field),
         password           = param_for(conn, :password_field),
         {:ok, ldap_conn}  <- adapter.connect(),
         :ok               <- adapter.verify(ldap_conn, uid, password),
         {:ok, ldap_user}  <- adapter.get(ldap_conn, uid) do
      put_private(conn, :ldap_user, ldap_user)
    else
      {:error, reason} ->
        set_errors!(conn, [error("exldap", reason)])
    end
  end

  def uid(conn) do
    param_for(conn, :uid_field)
  end

  def extra(conn), do: %Extra{raw_info: conn.private.ldap_user.raw}

  def credentials(%{private: %{ldap_user: %{password: password}}}) do
    %Credentials{
      other: %{
        password: password,
      }
    }
  end

  def info(%{private: %{ldap_user: ldap_user}}) do
    name = ldap_user.name
    first_name = name |> String.split(" ") |> Enum.at(0)
    last_name = name |> String.split(" ") |> Enum.at(-1)

    %Info{
      email: ldap_user.email,
      name: ldap_user.name,
      first_name: first_name,
      last_name: last_name,
    }
  end

  def handle_cleanup!(conn) do
    conn
    |> put_private(:ldap_user, nil)
  end

  defp option(conn, name) do
    Keyword.get(options(conn), name, Keyword.get(default_options(), name))
  end

  defp param_for(conn, name) do
    param_for(conn, name, option(conn, :param_nesting))
  end

  defp param_for(conn, name, nil) do
    conn.params
    |> Map.get(to_string(option(conn, name)))
  end

  defp param_for(conn, name, nesting) do
    attrs =
      nesting
      |> List.wrap()
      |> Enum.map(fn item -> to_string(item) end)

    case Kernel.get_in(conn.params, attrs) do
      nil ->
        nil

      nested ->
        nested
        |> Map.get(to_string(option(conn, name)))
    end
  end
end
