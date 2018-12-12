defmodule BITCOIN.BlockChain.TransactionQueue do
  use GenServer
  require Logger
  alias BITCOIN.BlockChain.{Transaction}
  alias BITCOIN.Utility

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
  def handle_call({:addToChain, txs}, _from, {queue}) do
    # FIXME: For now adding the block to the chain as soon as transaction is regitered
    # In Part 2, we will let node validate the transaction and do the voting.
    block = Utility.createDummyBlock(txs)
    previousBlock = GenServer.call(:Chain, :getLatestBlock)
    block = %{block | previous_block: previousBlock.hash}
    block = %{block | index: previousBlock.index + 1}
    block = Utility.computeHash(block)
    op = GenServer.call(:Chain, {:addBlock, block})
    Logger.info("New Block added #{inspect(op)}")
    {:reply, op, {[]}}
  end

  def handle_call({:addToQueue, txs}, _from, {queue}) do
    block = Utility.createDummyBlock(txs)
    # add new block to the end of the queue
    queue = queue ++ [block]
    # Logger.info("Added Transaction block to the queue #{inspect(queue)}")
    {:reply, :ok, {queue}}
  end

  def handle_call({:removeFromQueue, blockToRemove}, _from, {queue}) do
    queue = Enum.reject(queue, fn block ->
      blockToRemove.timestamp == block.timestamp
    end)
    # Logger.info("Remove block from the queue #{inspect(queue)}")
    {:reply, :ok, {queue}}
  end

  def handle_call(:getBlockFromQueue, _from, {queue}) do
    if(length(queue) > 0) do
      [blockToMine | _] = queue
      {:reply, blockToMine, {queue}}
    else
      {:reply, nil, {queue}}
    end
  end

  # def handle_info({:DOWN, ref, :process, _pid, _reason},{queue}) do
  #   Logger.info("Chain Stopped")
  #   {:noreply, {queue}}
  # end
end
