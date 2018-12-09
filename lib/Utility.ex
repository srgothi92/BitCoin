defmodule BITCOIN.Utility do
  alias BITCOIN.BlockChain.Block
  require Logger
  def createDummyBlock(txs) do
    block = Block.createBlock(0, "", txs)
    block
  end

  def computeHash(block) do
    {blockHash, nonce} = proofOfWork(block, :rand.uniform(32))
    block = %{block | hash: blockHash}
    block = %{block | nonce: nonce}
    block
  end

  def mine({block, chain}) do
    [previousBlock | _] = chain
    block = %{block | previous_block: previousBlock.hash}
    block = %{block | index: previousBlock.index+1}
    block = computeHash(block)
    #BroadCast new block for nodes to validate
    GenServer.cast(:Server, {:broadCastNewBlock, block, chain})
  end

  defp validateProofOfWork(hash) do
    target = Application.get_env(:bitcoin, :target)
    String.slice(hash, 0, target) == String.duplicate("0", target)
  end

  @doc """
  Calculates the hash of the block
  Keeps calculating until it gets the valid hash value.
  """
  def proofOfWork(%Block{} = block, nonce \\ 0) do
    block = %{block | nonce: nonce}
    blockHash = Block.hash(block)

    if(!validateProofOfWork(blockHash)) do
      proofOfWork(block, block.nonce + 1)
    else
      {blockHash, nonce}
    end
  end
end
