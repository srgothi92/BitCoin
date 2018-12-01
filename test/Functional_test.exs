defmodule BITCOIN.BlockChain.Functional_test do
use ExUnit.Case, async: true
import MockChain
  alias BITCOIN.BlockChain.{Chain, TransactionQueue}
  alias BITCOIN.UserNode

  use ExUnit.Case, async: true

  setup do
    {:ok, mockLedger()}
  end

  test "Transaction between two User", %{su: su, mu: mu, lu: lu} do
  end
end
