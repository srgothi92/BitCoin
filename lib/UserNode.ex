defmodule BITCOIN.UserNode do
  use GenServer

  alias BITCOIN.Wallet.Wallet
  @moduledoc """
  Initiates wallet for every user and
  takes care of the balance based on the transactions.
  """
  @doc """
  Starts the UserNode.
  """
  def start_link() do
    GenServer.start_link(__MODULE__,{})
  end

  @doc """
  Initiates the wallet for User Node.
  """
  def init(_) do
    wallet = Wallet.createWallet()
    {:ok, wallet}
  end

  @doc """
  Returns the wallet address.
  """
  def handle_call({:getAddress}, _from, wallet) do
    {:reply, wallet.address, wallet}
  end

  @doc """
  Transfers amount from a given wallet to receipient
  """
  def handle_call({:send, amount, recipient}, _from, wallet) do
    {:reply, Wallet.send(wallet, amount, recipient), wallet}
  end

  @doc """
  Returns the balance amount in wallet.
  """
  def handle_call(:balance, _from, wallet) do
    {:reply, Wallet.balance(wallet), wallet}
  end

  @doc """
  Returns the wallet.
  """
  def getWallet() do
    GenServer.call(__MODULE__, :getWallet)
  end

  @doc """
  Returns the wallet.
  """
  def handle_call(:getWallet,_from, wallet) do
    {:reply, wallet, wallet}
  end
end
