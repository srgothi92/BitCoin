defmodule BITCOIN.UserNode do
  use GenServer
  require Logger
  alias BITCOIN.Wallet.Wallet
  alias BITCOIN.BlockChain.Chain
  alias BITCOIN.Utility

  @moduledoc """
  Initiates wallet for every user and
  takes care of the balance based on the transactions.
  """
  @doc """
  Starts the UserNode.
  """
  def start_link() do
    GenServer.start_link(__MODULE__, {})
  end

  @doc """
  Initiates the wallet for User Node.
  """
  def init(_) do
    wallet = Wallet.createWallet()
    {:ok, {wallet, {}}}
  end

  @doc """
  Returns the wallet address.
  """
  def handle_call(:getAddress, _from, {wallet, mining}) do
    {:reply, wallet.address, {wallet, mining}}
  end

  @doc """
  Transfers amount from a given wallet to receipient
  """
  def handle_call({:send, amount, recipient}, _from, {wallet, mining}) do
    {:reply, Wallet.send(wallet, amount, recipient), {wallet, mining}}
  end

  def handle_cast({:transact, amount, recipient}, {wallet, mining}) do
    Wallet.transact(wallet, amount, recipient)
    {:noreply, {wallet, mining}}
  end

  @doc """
  Returns the balance amount in wallet.
  """
  def handle_call(:balance, _from, {wallet, mining}) do
    {:reply, Wallet.balance(wallet), {wallet, mining}}
  end

  @doc """
  Returns the wallet.
  """
  def getWallet() do
    GenServer.call(__MODULE__, :getWallet)
  end

  @doc """
  Returns the wallet.
  """
  def handle_call(:getWallet, _from, {wallet, mining}) do
    {:reply, wallet, {wallet, mining}}
  end

  defp startMining(blockToMine) do
    chain = GenServer.call(:Chain, :getAllBlocks)
    mining = spawn_monitor(fn -> Utility.mine({blockToMine, chain}) end)
    mining = Tuple.append(mining, blockToMine)
    mining
  end

  def handle_cast(:mining_request, {wallet, mining}) do
    # use the first block in queue for mining
    blockToMine = GenServer.call(:TransactionQueue, :getBlockFromQueue)
    # get Latest block from chain
    if(tuple_size(mining) > 0 && Process.alive?(elem(mining, 1))) do
      Process.exit(elem(mining, 1), :normal)
    end

    if(blockToMine != nil) do
      startMining(blockToMine)
      {:noreply, {wallet, mining}}
    else
      {:noreply, {wallet, mining}}
    end
  end

  def handle_info({:DOWN, ref, :process, _pid, _reason}, {wallet, {pid, mref, block}})
      when ref == mref do
    GenServer.call(:TransactionQueue, {:removeFromQueue, block},15000)
    # mine next block
    # use the first block in queue for mining
    blockToMine = GenServer.call(:TransactionQueue, :getBlockFromQueue)

    mining =
      if(blockToMine != nil) do
        startMining(blockToMine)
      else
        {}
      end

    {:noreply, {wallet, mining}}
  end

  def handle_info({:DOWN, ref, :process, _pid, _reason}, {wallet, mining}) do
    {:noreply, {wallet, mining}}
  end

  def handle_call({:validate_chain, blockreceived, retrievedChain}, _from, state) do
    actualChain = GenServer.call(:Chain, :getAllBlocks)
    [previousBlock | _] = actualChain
    result = Chain.validateBlock(previousBlock, blockreceived, actualChain)

    if(result != :ok) do
      GenServer.call(:TransactionQueue, {:removeFromQueue, blockreceived},15000)
      {:reply, {:error , :invalid_block}, state}
      # Logger.info("Not called Validated Block")
    else
      # Logger.info("Called Validated Block")
      GenServer.cast(:Server, {:validatedBlock, self(), blockreceived})
    end

    {:reply, :ok,  state}
  end

  def handle_call(:stopMining, _from,  {wallet, mining}) do
    if(tuple_size(mining) > 0 && Process.alive?(elem(mining, 1))) do
      Process.exit(elem(mining, 1), :normal)
    end
    {:reply, :ok, {wallet, mining}}
  end
end
