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

  def handle_cast({:addToQueue, tx}, {queue}) do
    queue = [queue | tx]
    # FIXME: For now adding the block to the chain as soon as transaction is regitered
    # In Part 2, we will let node validate the transaction and do the voting.
    createBlockAndAdd(queue)
    {:noreply, {queue}}
  end

  defp createBlockAndAdd(queue) do
    IO.inspect("Su")
    previousBlock = GenServer.call(:Chain,:getLatestBlock)
    IO.inspect("Su")
    block = Block.createBlock(previousBlock.hash, queue)
    IO.inspect("Su")
    {blockHash, nonce} = proofOfWork(block, :rand.uniform(32))
    IO.inspect("Su")
    block = %{block | hash: blockHash}
    IO.inspect("Su")
    block = %{block | nonce: nonce}
    IO.inspect block
    op = GenServer.call(:Chain,{:addBlock, block})
    Logger.info("New Block added #{inspect(op)}")
  end

  defp validateProofOfWork(hash) do
    IO.inspect hash
    target = Application.get_env(:bitcoin, :target)
    IO.inspect(target)
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
