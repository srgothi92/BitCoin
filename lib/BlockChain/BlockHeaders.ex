defmodule BITCOIN.BlockChain.BlockHeaders do
  use GenServer

  defstruct version: 0, # Block version information, based upon the software version creating this block
            previous_block: <<0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0>>, # char[32], The hash value of the previous block this particular block references
            timestamp: 0, # uint32_t, A Unix timestamp recording when this block was created (Currently limited to dates before the year 2106!)
            bits: 0, # uint32_t, The calculated difficulty target being used for this block
            nonce: 0, # uint32_t, The nonce used to generate this block… to allow variations of the header and compute different hashes
            transactions: []

  @type t :: %__MODULE__{
    version: integer,
    previous_block: BITCOIN.BlockChain.Block.t_hash,
    timestamp: non_neg_integer,
    bits: non_neg_integer,
    nonce: non_neg_integer,
    transactions: list(Trasaction.t())
  }


  def stringifyHeader(%__MODULE__{} = s) do
    <<
      s.version :: little-integer-size(32),
      s.previous_block :: bytes-size(32),
      s.timestamp :: unsigned-little-integer-size(32),
      s.bits :: unsigned-little-integer-size(32),
      s.nonce :: unsigned-little-integer-size(32),
    >>
  end
end
