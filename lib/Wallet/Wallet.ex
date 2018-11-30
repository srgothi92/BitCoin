defmodule BITCOIN.Wallet.Wallet do
  import BITCOIN.Wallet.KeyHandler

  @type t :: %__MODULE__{
          address: String.t(),
          public_key: String.t(),
          private_key: String.t()
        }

  defstruct [
    :address,
    :public_key,
    :private_key
  ]

  def sign(msg, %__MODULE__{private_key: pvKey}) do
    signMessage(pvKey, msg)
  end
end
