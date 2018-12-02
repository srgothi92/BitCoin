defmodule BITCOIN.BlockChain.TransactionQueue do
  use GenServer
  require Logger
  alias BITCOIN.BlockChain.{Transaction, Block, Chain}

  def start_link() do
    GenServer.start_link(__MODULE__, {}, name: :TransactionQueue)
  end

  def init(_) do
    queue = []
    {:ok, {queue}}
  end

  def addToQueue(%Transaction{} = tx) do
    GenServer.call(__MODULE__, {:addToQueue, tx})
  end

  def handle_call({:addToQueue, tx}, _from, {queue}) do
    queue = queue ++ [tx]
    # FIXME: For now adding the block to the chain as soon as transaction is regitered
    # In Part 2, we will let node validate the transaction and do the voting.
    result = createBlockAndAdd(queue)
    {:reply, result, {[]}}
  end

  defp createBlockAndAdd(queue) do
    previousBlock = GenServer.call(:Chain, :getLatestBlock)
    block = Block.createBlock(previousBlock.index+1, previousBlock.hash, queue)
    {blockHash, nonce} = proofOfWork(block, :rand.uniform(32))
    block = %{block | hash: blockHash}
    block = %{block | nonce: nonce}
    op = GenServer.call(:Chain, {:addBlock, block})
    Logger.info("New Block added #{inspect(op)}")
  end

  defp validateProofOfWork(hash) do
    target = Application.get_env(:bitcoin, :target)
    String.slice(hash, 0, target) == String.duplicate("0", target)
  end

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
