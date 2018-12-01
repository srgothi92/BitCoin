defmodule MockChain do

  alias BITCOIN.Wallet.{Wallet}
  alias BITCOIN.BlockChain.{Transaction, TransactionQueue, Chain, TxOutput, TxInput}
  alias BITCOIN.UserNode

  def mockLedger do
    # Start a new GenServer
    Chain.start_link()
    # Start a new Transaction queue to store transaction in buffer untill they are added to blocks
    TransactionQueue.start_link()
    su = Wallet.createWallet()
    mu = Wallet.createWallet()
    lu =  Wallet.createWallet()
    suTx = Transaction.initialDummyTransaction([TxOutput.createTxOutput(su.address, 50)])
    TransactionQueue.addToQueue(suTx)
    muTx = Transaction.initialDummyTransaction([TxOutput.createTxOutput(mu.address, 20)])
    TransactionQueue.addToQueue(muTx)
    # first transaction
    inputs = [TxInput.createTxInput(suTx.hash, 0)]
    outputs = [TxOutput.createTxOutput(mu.address, 20), TxOutput.createTxOutput(lu.address, 10), TxOutput.createTxOutput(su.address, 20)]
    tx1 = Transaction.createTransaction(su, inputs, outputs)
    TransactionQueue.addToQueue(tx1)

    # second transaction
    inputs = [TxInput.createTxInput(tx1.hash, 0)]
    outputs = [TxOutput.createTxOutput(lu.address, 5), TxOutput.createTxOutput(su.address, 7), TxOutput.createTxOutput(mu.address, 8)]
    tx2 = Transaction.createTransaction(mu, inputs, outputs)
    TransactionQueue.addToQueue(tx1)
     # third transaction
     inputs = [TxInput.createTxInput(tx1.hash, 1)]
     outputs = [TxOutput.createTxOutput(su.address, 6), TxOutput.createTxOutput(mu.address, 4)]
     tx3 = Transaction.createTransaction(lu, inputs, outputs)
     TransactionQueue.addToQueue(tx3)

     # fourth transaction
     inputs = [TxInput.createTxInput(tx2.hash, 2)]
     outputs = [TxOutput.createTxOutput(su.address, 3), TxOutput.createTxOutput(lu.address, 1), TxOutput.createTxOutput(mu.address, 4)]
     tx4 = Transaction.createTransaction(mu, inputs, outputs)
     TransactionQueue.addToQueue(tx4)
     %{su: su, mu: mu, lu: lu}
  end
end
