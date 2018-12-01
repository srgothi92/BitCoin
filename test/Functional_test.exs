defmodule BITCOIN.BlockChain.Functional_test do
use ExUnit.Case, async: true
import MockChain
  alias BITCOIN.BlockChain.{Chain, TransactionQueue}
  alias BITCOIN.UserNode

  use ExUnit.Case, async: true

  setup do
    {:ok, mockLedger()}
  end

  test "Transaction between two User", %{nodeSu: nodeSu, nodeMu: nodeMu, nodeLu: nodeLu} do
    a = GenServer.call(elem(nodeSu,1), :balance)
    IO.inspect(a)
  end
end
