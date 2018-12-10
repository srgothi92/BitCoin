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
    {:ok, {nodes, %{}}}
  end

  def handle_call({:createNodes, count}, _from, {nodes, nodesValidated}) do
    nodes =
      Enum.reduce(1..count, nodes, fn _, acc ->
        nodePid = UserNode.start_link()
        acc ++ [elem(nodePid, 1)]
      end)

    {:reply, :ok, {nodes, nodesValidated}}
  end

  def handle_cast({:broadcastTx, txs}, {nodes, nodesValidated}) do
    GenServer.call(:TransactionQueue, {:addToQueue, txs})
    GenServer.cast(self(), :broadcast_mining_request)
    {:noreply, {nodes, nodesValidated}}
  end

  def handle_cast(:broadcast_mining_request, {nodes, nodesValidated}) do
    # notify all user to start mining

    Enum.each(nodes, fn nodePid ->
      GenServer.call(nodePid, :mining_request)
    end)

    {:noreply, {nodes, nodesValidated}}
  end

  def handle_cast({:broadCastNewBlock, block, chain}, {nodes, nodesValidated}) do
    Enum.each(nodes, fn nodePid ->
      GenServer.cast(nodePid, {:validate_chain, block, chain})
    end)

    {:noreply, {nodes, nodesValidated}}
  end

  def handle_cast({:validatedBlock, nodePid, block}, {nodes, nodesValidated}) do
    nodesValidated = Map.put(nodesValidated, nodePid, true)
    nodesValidated =
      if(map_size(nodesValidated) >= div(length(nodes), 2)) do
        GenServer.call(:Chain, {:addBlock, block})
        GenServer.call(:TransactionQueue, {:removeFromQueue, block})
        Logger.info("Block added")
        GenServer.cast(self(), :broadcast_mining_request)
        # reset the validation
        %{}
      else
        nodesValidated
      end

    {:noreply, {nodes, nodesValidated}}
  end

  def handle_call(:giveRandomInitialMoney, _from, {nodes, nodesValidated}) do
    Enum.each(nodes, fn nodePid ->
      su = GenServer.call(nodePid, :getWallet)

      suTx =
        Transaction.initialDummyTransaction([
          TxOutput.createTxOutput(su.address, :rand.uniform(100))
        ])

      :ok = GenServer.call(:TransactionQueue, {:addToChain, [suTx]})
    end)

    {:reply, :ok, {nodes, nodesValidated}}
  end

  def handle_info(:doRandomTransaction, {nodes, nodesValidated}) do
    su = Enum.at(nodes, :rand.uniform(length(nodes) - 1))
    recipient = Enum.at(nodes, :rand.uniform(length(nodes) - 1))
    recipeintWallet = GenServer.call(recipient, :getWallet)
    GenServer.cast(su, {:transact, :rand.uniform(100), recipeintWallet.address})
    Process.send_after(self(), :doRandomTransaction, :rand.uniform(2000))
    {:noreply, {nodes, nodesValidated}}
  end

  defp getAllBalances(nodes) do
    nodes = Enum.with_index(nodes)
    balances = %{}
    balances = Enum.reduce(nodes, balances, fn {nodePid, index}, acc ->
      Map.put(acc, "node" <> Integer.to_string(index), GenServer.call(nodePid, :balance))
    end)
    balances
  end

  def handle_call(:getAllBalances, _from,  {nodes, nodesValidated}) do
    balances = getAllBalances(nodes)
    {:reply, balances, {nodes, nodesValidated}}
  end

  def handle_call(:stopAllNodes, _from, {nodes, nodesValidated}) do
    Enum.each(nodes, fn nodePid ->
      Process.exit(nodePid, :normal)
    end)
    {:reply, :ok,  {nodes, nodesValidated}}
  end

  def handle_info({:DOWN, ref, :process, _pid, _reason}, {nodes, nodesValidated}) do
    {:noreply,{nodes, nodesValidated}}
  end
end
