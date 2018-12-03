defmodule BITCOIN.BlockChain.TransactionQueue do
  use GenServer
  require Logger
  alias BITCOIN.BlockChain.{Transaction, Block, Chain}
  @moduledoc """
  Maintains the transactions to be added to the queue.
  """
  @doc """
  Starts the GenServer.
  """
  def start_link() do
    GenServer.start_link(__MODULE__, {}, name: :TransactionQueue)
  end

  @doc """
  Initiates the state of the GenServer.
  """
  def init(_) do
    queue = []
    {:ok, {queue}}
  end

  @doc """
  Adds the transaction to queue.
  """
  def addToQueue(%Transaction{} = txs) do
    GenServer.call(__MODULE__, {:addToQueue, txs})
  end

  @doc """
  After a transaction is complete, the result is added to the queue.
  """
  def handle_call({:addToQueue, txs}, _from, {queue}) do
    queue = queue ++ txs
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
    op
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
