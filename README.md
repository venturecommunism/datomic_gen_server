# DatomicGenServer

An Elixir GenServer that communicates with a Clojure Datomic peer running in the JVM, using clojure-erlastic.

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed as:

  1. Add datomic_gen_server to your list of dependencies in `mix.exs`:

        def deps do
          [{:datomic_gen_server, "~> 1.0.0"}]
        end

  2. You will need to install the Clojure leiningen build tool in order to build
     the Clojure jar with which the application communicates. Then, in the
     `priv/datomic_gen_server_peer` directory, run
     
        lein uberjar
  
  3. You may want to configure the default timeout values in the config.exs file,
     which control the default amount of time the application waits for the JVM 
     to start before crashing, and the default amount of time it waits for a 
     reply from the JVM peer before crashing.
     
  4. Ensure datomic_gen_server is started before your application:

        def application do
          [applications: [:datomic_gen_server]]
        end
