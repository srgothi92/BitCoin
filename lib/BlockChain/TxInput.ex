defmodule BITCOIN.BlockChain.TxInput do
  # The previous output transaction reference, as an OutPoint structure
  defstruct previous_output: %Outpoint{},
            # Computational Script for confirming transaction authorization
            signature_script: <<>>,
            # Transaction version as defined by the sender. Intended for "replacement" of transactions when information is updated before inclusion into a block.
            sequence: 0

  @type t :: %__MODULE__{
          previous_output: Outpoint.t(),
          signature_script: binary,
          sequence: non_neg_integer
        }
end
