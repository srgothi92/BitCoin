defmodule BITCOIN.UserNode do
  use GenServer

  alias BITCOIN.Wallet.Wallet

   @doc """
  Starts the UserNode.
  """
  def start_link(%Wallet{} = wallet) do
    GenServer.start_link(__MODULE__, wallet, name: wallet.address)
  end

  @doc """
  Initiates the wallet for User Node.
  """
  def init(%Wallet{} = wallet) do
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
end
