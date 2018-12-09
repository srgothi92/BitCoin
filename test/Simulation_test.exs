defmodule BITCOIN.BlockChain.Simulation_test do
  use ExUnit.Case,  async: true
  alias BITCOIN.Wallet.{Wallet}
  alias BITCOIN.BlockChain.{TransactionQueue, Chain}
  alias BITCOIN.Server
  test "check nothing" do
    Chain.start_link()
    # Start a new Transaction queue to store transaction in buffer untill they are added to blocks
    TransactionQueue.start_link()
    server = Server.start_link()
    :ok = GenServer.call(:Server, {:createNodes,10})
    :ok = GenServer.call(:Server, :giveRandomInitialMoney)
    Process.send_after(:Server, :doRandomTransaction, :rand.uniform(2000))
    balance = GenServer.call(:Server, :getAllBalances)
    IO.inspect balance
    assert false
  end
end
