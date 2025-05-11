defmodule Allure.Repo do
  use Ecto.Repo,
    otp_app: :allure,
    adapter: Ecto.Adapters.Postgres
end
