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
    #  Logger.info("Started validatedBlock")
    nodesValidated = Map.put(nodesValidated, nodePid, true)

    nodesValidated =
      if(map_size(nodesValidated) >= div(length(nodes), 2) || length(nodes) > 50) do
        GenServer.call(:Chain, {:addBlock, block}, 15000)
        GenServer.call(:TransactionQueue, {:removeFromQueue, block}, 15000)
        # Logger.info("Block added")
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
    Logger.info("New Trascation Requested")
    su = Enum.at(nodes, :rand.uniform(length(nodes) - 1))
    recipient = Enum.at(nodes, :rand.uniform(length(nodes) - 1))
    recipeintWallet = GenServer.call(recipient, :getWallet, 15000)

    # Adding some randomness for creating invalid transaction
    rand4 = :rand.uniform(5)

    if(rand4 == 4) do
      txQueue = GenServer.call(:TransactionQueue, :getQueue)
      if(length(txQueue) > 0) do
        txExisting = Enum.at(txQueue, :rand.uniform(length(txQueue)))
        tx =
          case :rand.uniform(5) do
            1 ->
              Logger.info("Some inputs does not exist")
              # Some inputs does not exist
              inputs = [TxInput.createTxInput(txExisting.hash, 1)]

              outputs = [
                TxOutput.createTxOutput("random Hash", 20)
              ]

              Transaction.createTransaction(su, inputs, outputs)

            2 ->
              # Spending more than availbale
              Logger.info("Spending more than availbale")
              outputs = [TxOutput.createTxOutput(recipeintWallet, 500)]
              inputs = [TxInput.createTxInput(txExisting.hash, 0)]
              Transaction.createTransaction(su, inputs, outputs)

            3 ->
              Logger.info("Spending same input twice")
              # Spending same input twice
              outputs = [TxOutput.createTxOutput(recipeintWallet, 2)]

              inputs = [
                TxInput.createTxInput(txExisting.hash, 0),
                TxInput.createTxInput(txExisting.hash, 0)
              ]

              Transaction.createTransaction(su, inputs, outputs)

            4 ->

              Logger.info("Person signing the tranaction is not correct")
              # Person signing the tranaction is not correct
              outputs = [TxOutput.createTxOutput(recipeintWallet, 2)]

              inputs = [
                TxInput.createTxInput(txExisting.hash, 0)
              ]

              Transaction.createTransaction(su, inputs, outputs)

            _ ->
              Logger.info("nil")
              nil
          end

        # Logger.info("Created transaction")
        if(tx! = nil) do
          Logger.info("#{inspect(tx)}")
          GenServer.cast(:Server, {:broadcastTx, [tx]})
        end
      end
    else
      GenServer.cast(su, {:transact, :rand.uniform(100), recipeintWallet.address})
    end

    transactionCount = transactionCount + 1

    if length(nodes) < 50 do
      Process.send_after(self(), :doRandomTransaction, :rand.uniform(2000))
    else
      Process.send_after(self(), :doRandomTransaction, 5000)
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
