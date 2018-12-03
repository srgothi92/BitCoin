defmodule BITCOIN.BlockChain.TxOutput do
  @moduledoc """
  Manages the output for a block
  """
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

  @doc """
  Creates the output for a block.
  """
  def createTxOutput(address, amount) do
    %__MODULE__{
      value: amount,
      wallet_address: address
    }
  end
end
