import Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :counter, CounterWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "s6yJokD0JnokRYt6fBCX53uDtyL6TNeiIH2WYIXRo7VP/sFAZA1f2oaBNcEoG0YO",
  server: false

# Print only warnings and errors during test
config :logger, level: :warning

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime
