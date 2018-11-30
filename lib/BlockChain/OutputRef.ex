defmodule BITCOIN.BlockChain.OutputRef do

  defstruct hash: <<0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0>>, # char[32] - The hash of the referenced transaction.
            index: 0 # The index of the specific output in the transaction. The first output is 0, etc.

  @type t :: %__MODULE__{
    hash: Bitcoin.Tx.t_hash,
    index: non_neg_integer
  }
end
