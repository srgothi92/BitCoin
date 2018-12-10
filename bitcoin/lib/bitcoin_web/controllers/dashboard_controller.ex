defmodule BitcoinWeb.DashboardController do
  use BitcoinWeb, :controller

  def dashboard(conn, params) do
    IO.inspect("abcdef")
    render(conn, "dashboard.html")
  end

  def getAllBalance(conn, params) do
    result = GenServer.call(:Server, :getAllBalances)
    result = Poison.encode!(result)
    text(conn,result)
  end


  def getTransactionCount(conn, params) do
  end

  def getBlockCount(conn, params) do
  end

  def startSimulation(conn, %{"numofNodes"  => numberOfNodes}) do
    BITCOIN.BlockChain.Chain.start_link()
    BITCOIN.BlockChain.TransactionQueue.start_link()
    BITCOIN.Server.start_link()
    GenServer.call(:Server, {:createNodes,String.to_integer(numberOfNodes)})
    GenServer.call(:Server, :giveRandomInitialMoney)
    Process.send_after(:Server, :doRandomTransaction,1000)
    text(conn, "started")
  end

  def stopSimulation(conn, params) do
    :ok = GenServer.call(:Server, :stopAllNodes)
    Process.exit(Process.whereis(:Chain), :normal )
    Process.exit(Process.whereis(:TransactionQueue), :normal )
    Process.exit(Process.whereis(:Server), :normal )
    text(conn, "stopped")
  end
end
