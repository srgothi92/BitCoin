defmodule BITCOIN.BlockChain.TxInput do
  @moduledoc """
  Manages the input for a block
  """
  defstruct [
    # Hash value of transacation in previous block
    :previous_op_tx_hash,
    # index number of output in previous transaction
    :index
  ]

  @type t :: %__MODULE__{
          previous_op_tx_hash: String.t(),
          index: integer
        }

  @doc """
  Creates the input for a block.
  """
  def createTxInput(hash, index) do
    %__MODULE__{
      previous_op_tx_hash: hash,
      index: index
    }
  end
end
