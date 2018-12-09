defmodule MockChain do

  alias BITCOIN.Wallet.{Wallet}
  alias BITCOIN.BlockChain.{Transaction, TransactionQueue, Chain, TxOutput, TxInput}
  alias BITCOIN.UserNode

  def mockLedger do
    # Start a new GenServer
    Chain.start_link()
    # Start a new Transaction queue to store transaction in buffer untill they are added to blocks
    TransactionQueue.start_link()
    nodeSu = UserNode.start_link()
    nodeMu = UserNode.start_link()
    nodeLu = UserNode.start_link()
    su = GenServer.call(elem(nodeSu,1), :getWallet)
    mu = GenServer.call(elem(nodeMu,1), :getWallet)
    lu = GenServer.call(elem(nodeLu,1), :getWallet)
    suTx = Transaction.initialDummyTransaction([TxOutput.createTxOutput(su.address, 50)])
    :ok = GenServer.call(:TransactionQueue, {:addToChain, [suTx]})
    muTx = Transaction.initialDummyTransaction([TxOutput.createTxOutput(mu.address, 20)])
    :ok = GenServer.call(:TransactionQueue, {:addToChain, [muTx]})
    # first transaction
    inputs = [TxInput.createTxInput(suTx.hash, 0)]
    outputs = [TxOutput.createTxOutput(mu.address, 20), TxOutput.createTxOutput(lu.address, 10), TxOutput.createTxOutput(su.address, 20)]
    tx1 = Transaction.createTransaction(su, inputs, outputs)
    :ok = GenServer.call(:TransactionQueue, {:addToChain, [tx1]})
    # second transaction
    inputs = [TxInput.createTxInput(tx1.hash, 0)]
    outputs = [TxOutput.createTxOutput(lu.address, 5), TxOutput.createTxOutput(su.address, 7), TxOutput.createTxOutput(mu.address, 8)]
    tx2 = Transaction.createTransaction(mu, inputs, outputs)
    :ok = GenServer.call(:TransactionQueue, {:addToChain, [tx2]})
     # third transaction
     inputs = [TxInput.createTxInput(tx1.hash, 1)]
     outputs = [TxOutput.createTxOutput(su.address, 6), TxOutput.createTxOutput(mu.address, 4)]
     tx3 = Transaction.createTransaction(lu, inputs, outputs)
     :ok = GenServer.call(:TransactionQueue, {:addToChain, [tx3]})

     # fourth transaction
     inputs = [TxInput.createTxInput(tx2.hash, 2)]
     outputs = [TxOutput.createTxOutput(su.address, 3), TxOutput.createTxOutput(lu.address, 1), TxOutput.createTxOutput(mu.address, 4)]
     tx4 = Transaction.createTransaction(mu, inputs, outputs)
     :ok = GenServer.call(:TransactionQueue, {:addToChain, [tx4]})
     %{nodeSu: nodeSu, nodeMu: nodeMu, nodeLu: nodeLu, su: su, mu: mu, lu: lu, tx4: tx4}
  end
end
