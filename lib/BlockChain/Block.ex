defmodule BITCOIN.BlockChain.Block do
  # The hash value of the previous block this particular block references
  defstruct [
    :previous_block,
    # uint32_t, A Unix timestamp recording when this block was created (Currently limited to dates before the year 2106!)
    :timestamp,
    # uint32_t, The nonce used to generate this block… to allow variations of the header and compute different hashes
    :nonce,
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

  defp stringifyHeader(%__MODULE__{} = block) do
    block.previous_block <>
      Integer.to_string(block.timestamp) <>
      Integer.to_string(block.nonce) <> Integer.to_string(block.index)
  end

  defp hash(%__MODULE__{} = block) do
    headerString = stringifyHeader(block)
    :crypto.hash(:sha256, :crypto.hash(:sha256, headerString))
  end

  def createBlock(previousHash, nonce, transactions) do
    %__MODULE__{
      previous_block: previousHash,
      timestamp: :os.system_time(:millisecond),
      nonce: nonce,
      transactions: transactions,
      index: 0,
      hash: "0012345"
    }
  end
end
