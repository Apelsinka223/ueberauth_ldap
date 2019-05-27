defmodule SpecRouter do
  require Ueberauth
  use Plug.Router

  plug(:fetch_query_params)

  plug(Ueberauth, base_path: "/auth")

  plug(:match)
  plug(:dispatch)

  get("/auth/ldap", do: send_resp(conn, 200, "ldap request"))

  get "/auth/ldap_with_options" do
    send_resp(conn, 200, "ldap with options request")
  end

  get("/auth/ldap/callback", do: send_resp(conn, 200, "ldap callback"))

  get "/auth/ldap_with_options/callback" do
    send_resp(conn, 200, "ldap with options callback")
  end

  get "/auth/ldap_with_nested_options/callback" do
    send_resp(conn, 200, "ldap with nested options callback")
  end

  get "/auth/ldap_real_server/callback" do
    send_resp(conn, 200, "ldap with real server")
  end
end
