defmodule BITCOIN.Server do
  use GenServer
  alias BITCOIN.UserNode
  alias BITCOIN.BlockChain.{Transaction, TxOutput, TxInput}
  require Logger

  def start_link() do
    GenServer.start_link(__MODULE__, {}, name: :Server)
  end

  def init(_) do
    nodes = []
    transactionCount = 0
    {:ok, {nodes, %{}, transactionCount}}
  end

  def handle_call({:createNodes, count}, _from, {nodes, nodesValidated, transactionCount}) do
    nodes =
      Enum.reduce(1..count, nodes, fn _, acc ->
        nodePid = UserNode.start_link()
        acc ++ [elem(nodePid, 1)]
      end)

    {:reply, :ok, {nodes, nodesValidated, transactionCount}}
  end

  def handle_cast({:broadcastTx, txs}, {nodes, nodesValidated, transactionCount}) do
    Logger.info("Started Broadcating tx")
    GenServer.call(:TransactionQueue, {:addToQueue, txs})
    GenServer.cast(self(), :broadcast_mining_request)
    Logger.info("Ended Broadcating tx")
    {:noreply, {nodes, nodesValidated, transactionCount}}
  end

  def handle_cast(:broadcast_mining_request, {nodes, nodesValidated, transactionCount}) do
    # notify all user to start mining
    Logger.info("Started Broadcating mining req")
    Enum.each(nodes, fn nodePid ->
      GenServer.call(nodePid, :mining_request)
    end)
    Logger.info("Ended Broadcating mining req")

    {:noreply, {nodes, nodesValidated, transactionCount}}
  end

  def handle_cast({:broadCastNewBlock, block, chain}, {nodes, nodesValidated, transactionCount}) do
    Enum.each(nodes, fn nodePid ->
      GenServer.cast(nodePid, {:validate_chain, block, chain})
    end)

    {:noreply, {nodes, nodesValidated, transactionCount}}
  end

  def handle_cast({:validatedBlock, nodePid, block}, {nodes, nodesValidated, transactionCount}) do
    Logger.info("Started validatedBlock")
    nodesValidated = Map.put(nodesValidated, nodePid, true)
    nodesValidated =
      if(map_size(nodesValidated) >= div(length(nodes), 2) || length(nodes) > 20) do
        GenServer.cast(:Chain, {:addBlockAsync, block})
        GenServer.cast(:TransactionQueue, {:removeFromQueue, block})
        Logger.info("Block added")
        GenServer.cast(self(), :broadcast_mining_request)
        # reset the validation
        %{}
      else
        nodesValidated
      end
      Logger.info("Ended validatedBlock")
    {:noreply, {nodes, nodesValidated, transactionCount}}
  end

  def handle_call(:giveRandomInitialMoney, _from, {nodes, nodesValidated, transactionCount}) do
    Logger.info("Started giving random money")
    txs = Enum.reduce(nodes,[], fn nodePid, acc ->
      su = GenServer.call(nodePid, :getWallet)
      suTx =
        Transaction.initialDummyTransaction([
          TxOutput.createTxOutput(su.address, :rand.uniform(100))
        ])
      acc ++ [suTx]
    end)
    :ok = GenServer.call(:TransactionQueue, {:addToChain, txs})
    Logger.info("Ended giving random money")
    {:reply, :ok, {nodes, nodesValidated, transactionCount}}
  end

  def handle_info(:doRandomTransaction, {nodes, nodesValidated, transactionCount}) do
    Logger.info("Started random tx")
    su = Enum.at(nodes, :rand.uniform(length(nodes) - 1))
    recipient = Enum.at(nodes, :rand.uniform(length(nodes) - 1))
    recipeintWallet = GenServer.call(recipient, :getWallet)
    GenServer.cast(su, {:transact, :rand.uniform(100), recipeintWallet.address})
    transactionCount = transactionCount + 1
    if length(nodes) < 500 do
      Process.send_after(self(), :doRandomTransaction, :rand.uniform(2000))
    else
      Process.send_after(self(), :doRandomTransaction, 10000)
    end
    Logger.info("Ended random tx")
    {:noreply, {nodes, nodesValidated, transactionCount}}
  end

  defp getAllBalances(nodes) do
    Logger.info("Started get all balances")
    nodes = Enum.with_index(nodes)
    balances = %{}
    balances = Enum.reduce(nodes, balances, fn {nodePid, index}, acc ->
      balance = GenServer.call(nodePid, :balance)
      Map.put(acc, "node" <> Integer.to_string(index), balance)
    end)
    Logger.info("Ended get all balances")
    balances
  end

  def handle_call(:getAllBalances, _from,  {nodes, nodesValidated, transactionCount}) do
    balances = getAllBalances(nodes)
    {:reply, balances, {nodes, nodesValidated, transactionCount}}
  end

  def handle_call(:stopAllNodes, _from, {nodes, nodesValidated, transactionCount}) do
    Enum.each(nodes, fn nodePid ->
      GenServer.stop(nodePid, :normal)
    end)
    {:reply, :ok,  {nodes, nodesValidated, transactionCount}}
  end

  def handle_call(:getTransactionCount, _from, {nodes, nodesValidated, transactionCount}) do
    {:reply, transactionCount,  {nodes, nodesValidated, transactionCount}}
  end

  # def handle_info({:DOWN, ref, :process, _pid, _reason}, {nodes, nodesValidated}) do
  #   {:noreply,{nodes, nodesValidated}}
  # end
end
