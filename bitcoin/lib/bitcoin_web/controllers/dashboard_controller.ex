defmodule BitcoinWeb.DashboardController do
  use BitcoinWeb, :controller

  def dashboard(conn, params) do
    IO.inspect("abcdef")
    render(conn, "dashboard.html")
  end

  def getAllBalance(conn, params) do
    Poison.encode!(GenServer.call(:Server, :getAllBalances))
  end

  def getTransactionCount(conn, params) do
  end

  def getBlockCount(conn, params) do
  end

  def startSimulation(conn, params) do
    BITCOIN.BlockChain.Chain.start_link()
    BITCOIN.BlockChain.TransactionQueue.start_link()
    BITCOIN.Server.start_link()
    GenServer.call(:Server, {:createNodes,10})
    GenServer.call(:Server, :giveRandomInitialMoney)
    Process.send_after(:Server, :doRandomTransaction,1000)
    text(conn, "started")
  end

  def stopSimulation(conn, params) do
    :ok = GenServer.call(:Server, :stopAllNodes)
    Process.exit(:Chain, :normal )
    Process.exit(:TransactionQueue, :normal )
    Process.exit(:Server, :normal )
    text(conn, "stopped")
  end
end
