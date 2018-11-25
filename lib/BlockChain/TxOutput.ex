defmodule BITCOIN.BlockChain.TxOutput do
  # Transaction Value (in satoshis)
  defstruct value: 0,
            # Usually contains the public key as a Bitcoin script setting up conditions to claim this output.
            pk_script: <<>>

  @type t :: %__MODULE__{
          value: non_neg_integer,
          pk_script: binary
        }
end
