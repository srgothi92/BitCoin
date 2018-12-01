defmodule BITCOIN.BlockChain.Functional_test do
use ExUnit.Case, async: true
import MockChain
alias BITCOIN.Wallet.Wallet
  alias BITCOIN.BlockChain.{Chain, TransactionQueue, TxOutput, Transaction}
  alias BITCOIN.UserNode

  use ExUnit.Case, async: true

  setup do
    {:ok, mockLedger()}
  end

  test "Transaction between two User", %{nodeSu: nodeSu, nodeMu: nodeMu, nodeLu: nodeLu} do
    #b = GenServer.call(:Chain,:getLatestBlock)
    #a= GenServer.call(elem(nodeSu,1), :balance)
    #IO.inspect(b)
    # Chain.start_link()
    # TransactionQueue.start_link()
    # a = Wallet.createWallet()
    # suTx = Transaction.initialDummyTransaction([TxOutput.createTxOutput(a.address, 50)])
    # GenServer.call(__MODULE__, {:addToQueue, suTx})
    #a=  GenServer.call(:Chain,:getLatestBlock)
   # IO.inspect(a)
  end
end
