# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config

config :ueberauth, Ueberauth,
       providers: [
         ldap: {Ueberauth.Strategy.LDAP, [
           adapter: Ueberauth.Strategy.LDAP.AdapterMock,
         ]},
         ldap_with_options: {
           Ueberauth.Strategy.LDAP,
           [
             uid_field: :username,
             param_nesting: "user",
             adapter: Ueberauth.Strategy.LDAP.AdapterMock,
           ]
         },
         ldap_with_nested_options: {
           Ueberauth.Strategy.LDAP,
           [
             param_nesting: ["data", "attributes"],
             adapter: Ueberauth.Strategy.LDAP.AdapterMock,
           ]
         },
         ldap_real_server: {
           Ueberauth.Strategy.LDAP,
           [
             adapter: Ueberauth.Strategy.LDAP.Adapter.Exldap,
           ]
         }
       ]

config :ueberauth, Ueberauth.Strategy.LDAP,
       server: "ldap.forumsys.com",
       base: "DC=example,DC=com",
       port: 389,
       ssl: false,
       password: "password",
       timeout: 1000
