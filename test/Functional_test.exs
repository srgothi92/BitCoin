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

  test "Su balance", %{nodeSu: nodeSu, nodeMu: nodeMu, nodeLu: nodeLu} do
    suBalance =  GenServer.call(elem(nodeSu,1),:balance)
    assert suBalance == 36
  end

  test "Mu Balance", %{nodeSu: nodeSu, nodeMu: nodeMu, nodeLu: nodeLu} do
    muBalance =  GenServer.call(elem(nodeMu,1),:balance)
    assert muBalance == 28
  end

  test "Lu Balance", %{nodeSu: nodeSu, nodeMu: nodeMu, nodeLu: nodeLu} do
    luBalance =  GenServer.call(elem(nodeLu,1),:balance)
    assert luBalance == 6
  end

  test "Su trnasfer 10 to Mu", %{nodeSu: nodeSu, nodeMu: nodeMu}do
    GenServer.call(elem(nodeSu,1),{:send, 6,  GenServer.call(elem(nodeMu,1), :getWallet).address})
    suBalance =  GenServer.call(elem(nodeSu,1),:balance)
    muBalance =  GenServer.call(elem(nodeMu,1),:balance)
    assert muBalance == 34
    assert suBalance == 30
  end
end
