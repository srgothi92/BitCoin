defmodule BITCOIN.UserNode do
  use GenServer

  alias BITCOIN.Wallet.Wallet

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

  def handle_call({:getAddress}, _from, wallet) do
    {:reply, wallet.address, wallet}
  end

  def handle_call({:send, amount, recipient}, _from, wallet) do
    {:reply, wallet.send(wallet, amount, recipient), wallet}
  end

  def handle_call({:balance}, _from, wallet) do
    {:reply, wallet.balance(wallet), wallet}
  end


  def getWallet() do
    GenServer.call(__MODULE__, :getWallet)
  end

  def handle_call(:getWallet,_from, wallet) do
    {:reply, wallet, wallet}
  end
end
