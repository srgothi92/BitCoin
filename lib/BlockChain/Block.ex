defmodule BITCOIN.BlockChain.Block do
  use GenServer
  alias BITCOIN.BlockChain.{TransactionVerify}

  defstruct [:previous_block, #The hash value of the previous block this particular block references
            :timestamp, # uint32_t, A Unix timestamp recording when this block was created (Currently limited to dates before the year 2106!)
            :nonce, # uint32_t, The nonce used to generate this block… to allow variations of the header and compute different hashes
            :transactions,
            :index,
            :hash
]

  @type t :: %__MODULE__{
    previous_block: String,
    timestamp: non_neg_integer,
    nonce: non_neg_integer,
    transactions: list(Trasaction.t()),
    index: integer,
    hash: String
  }

  def initialBlock() do
    %__MODULE__{
      previous_block: "0",
      timestamp: :os.system_time(:millisecond),
      nonce: 123,
      transactions: [],
      index: 0,
      hash: "0012345"
    }
  end


  def stringifyHeader(%__MODULE__{} = block) do
    <<
      block.previous_block :: bytes-size(32),
      block.timestamp :: unsigned-little-integer-size(32),
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
