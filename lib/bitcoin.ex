defmodule BITCOIN do
  use GenServer
  require Logger

  @moduledoc """
  Documentation for BITCOIN.
  """


  def init() do
    state = init_state()
    {:ok, state}
  end

  def init_state() do
    difficulty = 2
    block = %{"index": "0", "timestamp": "1514528022", "data": "Hello World",
    "prevHash": "000000000000000000000000000", "nonce": Integer.to_string(:rand.uniform(32)), "target": "8"}
    currHash = calculateHash(block,difficulty)
    IO.inspect currHash
  end

  defp calculateHash(block,difficulty) do
    blockAdd = Enum.reduce(block,"", fn ({key, value},acc) -> acc <> value
    end)
    currHash = :crypto.hash(:sha, blockAdd ) |> Base.encode16
    currHash = if(String.slice(currHash, 0, difficulty) != "00") do
      nonceInt = elem(Integer.parse(block.nonce),0) +1
      block = Map.put(block, :nonce, Integer.to_string(nonceInt))
      currHash =calculateHash(block,difficulty)
    else
    currHash
    end
  end



end
