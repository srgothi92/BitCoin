defmodule BitcoinWeb.DashboardController do
  use BitcoinWeb, :controller

  def dashboard(conn, params) do
    render(conn, "dashboard.html")
  end

  def getAllBalance(conn, params) do
    try do
      result = GenServer.call(:Server, :getAllBalances, 15000)
      result = Poison.encode!(result)
      text(conn, result)
    catch
      :exit, reason ->
        text(conn, "Timed out")
    end
  end

  def getTransactionCount(conn, params) do
    try do
      value = GenServer.call(:Server, :getTransactionCount,15000)

      text(conn, value)
    catch
      :exit, reason ->
        text(conn, "Timed out")
    end
  end

  def getBlockCount(conn, params) do
    try do
      text(conn, GenServer.call(:Chain, :getBlockCount,15000))
    catch
      :exit, reason ->
        text(conn, "Timed out")
    end
  end

  def startSimulation(conn, %{"numofNodes" => numberOfNodes}) do
    BITCOIN.BlockChain.Chain.start_link()
    BITCOIN.BlockChain.TransactionQueue.start_link()
    BITCOIN.Server.start_link()
    GenServer.call(:Server, {:createNodes, String.to_integer(numberOfNodes)})
    GenServer.call(:Server, :giveRandomInitialMoney)
    Process.send_after(:Server, :doRandomTransaction, 1000)
    text(conn, "started")
  end

  def stopSimulation(conn, params) do
    :ok = GenServer.call(:Server, :stopAllNodes)
    GenServer.stop(Process.whereis(:Chain), :normal)
    GenServer.stop(Process.whereis(:TransactionQueue), :normal)
    GenServer.stop(Process.whereis(:Server), :normal)
    text(conn, "stopped")
  end
end
