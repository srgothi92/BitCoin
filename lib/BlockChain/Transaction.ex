defmodule BITCOIN.BlockChain.Transaction do
  # Transaction data format version
  defstruct version: 0,
            # A list of 1 or more transaction inputs or sources for coins
            inputs: [],
            # A list of 1 or more transaction outputs or destinations for coins
            outputs: [],
            # The block number or timestamp at which this transaction is locked:
            lock_time: 0

  #   0 - Not Locked
  #   < 500000000 - Block number at which this transaction is locked
  #   >= 500000000 - UNIX timestamp at which this transaction is locked
  # If all TxIn inputs have final (0xffffffff) sequence numbers then lock_time is irrelevant.
  # Otherwise, the transaction may not be added to a block until after lock_time (see NLockTime).

  @type t :: %__MODULE__{
          # note, this is signed
          version: integer,
          inputs: list(TxInput.t()),
          outputs: list(TxOutput.t()),
          lock_time: non_neg_integer
        }
end
