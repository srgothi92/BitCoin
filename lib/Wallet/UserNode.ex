defmodule BITCOIN.Wallet.UserNode do
import BITCOIN.Wallet.KeyHandler
use GenServer
  def start_link() do
    GenServer.start_link(__MODULE__,{})
  end

  def init() do
    state = init_state()
    {:ok, state}
  end

  defp init_state() do
    {publicKey, privateKey} = keyPairGenerate()
    {publicKey, privateKey}
  end

end
