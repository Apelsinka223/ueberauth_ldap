defmodule Ueberauth.Strategy.LDAP.Adapter.Exldap do
  @behaviour Ueberauth.Strategy.LDAP.Adapter

  def connect do
    config = Application.get_env(:ueberauth, Ueberauth.Strategy.LDAP)
    Exldap.open(config[:server], config[:port], config[:ssl], config[:timeout], config[:sslopts])
  end

  def verify(connection, uid, password) do
    config = Application.get_env(:ueberauth, Ueberauth.Strategy.LDAP)
    Exldap.verify_credentials(connection, "uid=#{uid},#{config[:base]}", password)
  end

  def get(connection, uid) do
    config = Application.get_env(:ueberauth, Ueberauth.Strategy.LDAP)

    with filter                      = Exldap.equalityMatch("uid", uid),
         {:ok, [search_result | _]} <- Exldap.search(connection, [
                                         base: config[:base],
                                         scope: :eldap.wholeSubtree(),
                                         filter: filter,
                                         timeout: config[:timeout]
                                       ])
      do
      {:ok, %{
         email: Exldap.get_attribute!(search_result, "mail"),
         name: Exldap.get_attribute!(search_result, "cn"),
         password: Exldap.get_attribute!(search_result, "userPassword"),
         raw: search_result
       }}
    end
  end
end
