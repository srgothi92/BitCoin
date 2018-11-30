defmodule BITCOIN.BlockChain.TxInput do
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
end
