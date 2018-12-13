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
    GenServer.call(:TransactionQueue, {:addToQueue, txs})
    GenServer.cast(self(), :broadcast_mining_request)
    {:noreply, {nodes, nodesValidated, transactionCount}}
  end

  def handle_cast(:broadcast_mining_request, {nodes, nodesValidated, transactionCount}) do
    # notify all user to start mining
    Enum.each(nodes, fn nodePid ->
      GenServer.cast(nodePid, :mining_request)
    end)
    {:noreply, {nodes, nodesValidated, transactionCount}}
  end

  def handle_cast({:broadCastNewBlock, block, chain}, {nodes, nodesValidated, transactionCount}) do
    # do not broadcast already broadcasted block
    temp =
      Enum.reduce_while(nodes, 0, fn nodePid, acc ->
        result = GenServer.call(nodePid, {:validate_chain, block, chain})
        if result == :ok && length(nodes) < 50 do
          {:cont, acc}
        else
          {:halt, acc}
        end
      end)
    {:noreply, {nodes, nodesValidated, transactionCount}}
  end

  def handle_cast({:validatedBlock, nodePid, block}, {nodes, nodesValidated, transactionCount}) do
    # Logger.info("Started validatedBlock")
    nodesValidated = Map.put(nodesValidated, nodePid, true)

    nodesValidated =
      if(map_size(nodesValidated) >= div(length(nodes), 2) || length(nodes) > 50) do
        GenServer.cast(:Chain, {:addBlockAsync, block})
        GenServer.cast(:TransactionQueue, {:removeFromQueue, block})
        # Logger.info("Block added")
        if(length(nodes) > 50) do
          Process.send_after(self(), :doRandomTransaction, 100)
        end
        GenServer.cast(self(), :broadcast_mining_request)
        # reset the validation
        %{}
      else
        nodesValidated
      end

    # Logger.info("Ended validatedBlock")
    {:noreply, {nodes, nodesValidated, transactionCount}}
  end

  def handle_call(:giveRandomInitialMoney, _from, {nodes, nodesValidated, transactionCount}) do
    txs =
      Enum.reduce(nodes, [], fn nodePid, acc ->
        su = GenServer.call(nodePid, :getWallet)

        suTx =
          Transaction.initialDummyTransaction([
            TxOutput.createTxOutput(su.address, :rand.uniform(100))
          ])

        acc ++ [suTx]
      end)

    :ok = GenServer.call(:TransactionQueue, {:addToChain, txs})
    {:reply, :ok, {nodes, nodesValidated, transactionCount}}
  end

  def handle_info(:doRandomTransaction, {nodes, nodesValidated, transactionCount}) do
    su = Enum.at(nodes, :rand.uniform(length(nodes) - 1))
    recipient = Enum.at(nodes, :rand.uniform(length(nodes) - 1))
    recipeintWallet = GenServer.call(recipient, :getWallet)
    GenServer.cast(su, {:transact, :rand.uniform(100), recipeintWallet.address})
    transactionCount = transactionCount + 1

    if length(nodes) < 50 do
      Process.send_after(self(), :doRandomTransaction, :rand.uniform(2000))
    end
    {:noreply, {nodes, nodesValidated, transactionCount}}
  end

  defp getAllBalances(nodes) do
    nodes = Enum.with_index(nodes)
    balances = %{}

    balances =
      Enum.reduce(nodes, balances, fn {nodePid, index}, acc ->
        balance = GenServer.call(nodePid, :balance)
        Map.put(acc, "node" <> Integer.to_string(index), balance)
      end)
    balances
  end

  def handle_call(:getAllBalances, _from, {nodes, nodesValidated, transactionCount}) do
    balances = getAllBalances(nodes)
    {:reply, balances, {nodes, nodesValidated, transactionCount}}
  end

  def handle_call(:stopAllNodes, _from, {nodes, nodesValidated, transactionCount}) do
    Enum.each(nodes, fn nodePid ->
      GenServer.stop(nodePid, :normal)
    end)

    {:reply, :ok, {nodes, nodesValidated, transactionCount}}
  end

  def handle_call(:getTransactionCount, _from, {nodes, nodesValidated, transactionCount}) do
    {:reply, transactionCount, {nodes, nodesValidated, transactionCount}}
  end

  # def handle_info({:DOWN, ref, :process, _pid, _reason}, {nodes, nodesValidated}) do
  #   {:noreply,{nodes, nodesValidated}}
  # end
end
