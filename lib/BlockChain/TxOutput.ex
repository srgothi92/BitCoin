defmodule BITCOIN.BlockChain.TxOutput do
  # Transaction Value (in satoshis)
  defstruct [
    :value,
    # Indentifier of user whose this output belongs too
    :wallet_address
  ]

  @type t :: %__MODULE__{
          value: non_neg_integer,
          wallet_address: String.t()
        }
end
