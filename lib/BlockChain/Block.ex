defmodule BITCOIN.BlockChain.Block do
  use GenServer
  alias BITCOIN.BlockChain.{TransactionVerify}

  defstruct version: 0, # Block version information, based upon the software version creating this block
            previous_block: "", #The hash value of the previous block this particular block references
            timestamp: 0, # uint32_t, A Unix timestamp recording when this block was created (Currently limited to dates before the year 2106!)
            bits: 0, # uint32_t, The calculated difficulty target being used for this block
            nonce: 0, # uint32_t, The nonce used to generate this block… to allow variations of the header and compute different hashes
            transactions: [],
            index: 0,
            hash: ""

  @type t :: %__MODULE__{
    version: integer,
    previous_block: String,
    timestamp: non_neg_integer,
    bits: non_neg_integer,
    nonce: non_neg_integer,
    transactions: list(Trasaction.t()),
    index: integer,
    hash: String
  }


  def stringifyHeader(%__MODULE__{} = block) do
    <<
      block.version :: little-integer-size(32),
      block.previous_block :: bytes-size(32),
      block.timestamp :: unsigned-little-integer-size(32),
      block.bits :: unsigned-little-integer-size(32),
      block.nonce :: unsigned-little-integer-size(32),
      block.index :: little-integer-size(32)
    >>
  end

  def hash(%__MODULE__{} = block) do
    headerString = stringifyHeader(block)
    :crypto.hash(:sha256, :crypto.hash(:sha256, headerString))
  end

  def validateBlock(%__MODULE__{} = block) do
    Enum.each(block.transactions,fn tx -> TransactionVerify.validateTransactions(tx) end)

  end

  defp validateHeaderHash(%__MODULE__{} = block) do

  end
end
