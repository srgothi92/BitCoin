defmodule BitcoinWeb.DashboardController do
  use BitcoinWeb, :controller

  def dashboard(conn, params) do
    render(conn, "dashboard.html")
  end

  def getAllBalance(conn, params) do
    result = GenServer.call(:Server, :getAllBalances)
    result = Poison.encode!(result)
    text(conn,result)
  end


  def getTransactionCount(conn, params) do
    text(conn,GenServer.call(:Server, :getTransactionCount))
  end

  def getBlockCount(conn, params) do
    text(conn,GenServer.call(:Chain, :getBlockCount))
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
    GenServer.stop(Process.whereis(:Chain), :normal )
    GenServer.stop(Process.whereis(:TransactionQueue), :normal )
    GenServer.stop(Process.whereis(:Server), :normal )
    text(conn, "stopped")
  end
end
