defmodule BITCOIN.BlockChain.TxInput do
  # The previous output transaction reference, as an OutPoint structure
  alias BITCOIN.BlockChain.OutputRef
  defstruct previous_output: %OutputRef{},
            # Computational Script for confirming transaction authorization
            signature_script: <<>>,
            # Transaction version as defined by the sender. Intended for "replacement" of transactions when information is updated before inclusion into a block.
            sequence: 0

  @type t :: %__MODULE__{
          previous_output: OutputRef.t(),
          signature_script: binary,
          sequence: non_neg_integer
        }
end
