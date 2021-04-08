defmodule Bonfire.Mailer do
  use Bamboo.Mailer, otp_app: Bonfire.Common.Config.get!(:otp_app)
  alias Bamboo.Email
  require Logger

  def send_now(email, to) do
    from =
      Bonfire.Common.Config.get(__MODULE__, [])
      |> Keyword.get(:from_address, "noreply@bonfire.local")
    try do
      mail =
        email
        |> Email.from(from)
        |> Email.to(to)
      deliver_now(mail)
      {:ok, mail}
    rescue
      error in Bamboo.SMTPAdapter.SMTPError ->
        # le sigh, i give up
        Logger.error("Email delivery error: #{inspect(error.raw)}")
        {:error, error}
        # case error.raw do
        #   {:no_credentials, _} -> {:error, :config}
        #   {:retries_exceeded, _} -> {:error, :rejected}
        #   # give up
        #   _ -> raise error
        # end
      error ->
        Logger.error("Email delivery error: #{inspect(error)}")
        {:error, error}
    end
  end

end
