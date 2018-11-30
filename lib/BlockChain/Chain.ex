defmodule BITCOIN.BlockChain.Chain do
  use GenServer

  alias BITCOIN.BlockChain.{Block, TransactionVerify}

  def start_link() do
    GenServer.start_link(__MODULE__, {}, name: :Chain)
  end

  def init(_) do
    chain = [Block.initialBlock()]
    {:ok, {chain}}
  end

  def validateProofOfWork(hash) do
    target = Application.get_env(:bitcoin, :target)
    String.slice(hash, 0, target) == String.duplicate("0", target)
  end

  @spec validateChain(Block.t(),Block.t(), [Block.t()] ) :: :ok |  {:error, atom()}
  defp validateChain(prevBlock, block, chain) do
    cond do
    # check index values
    prevBlock.index != block.index-1 ->
      {:error, :invalid_index}
    # check hash values
    block.previous_block != prevBlock.hash ->
      {:error, :invalid_prvious_hash}
    # Compute the hash and validate with block hash
    block.hash != Block.hash(block) ->
      {:error, :invalid_block_hash}
    # Validate the hash for target number of zeros
    !validateProofOfWork(block.hash) ->
      {:error, :invalid_proof_of_work}
    true ->
      TransactionVerify.validateTransactions(block.transaction)
    end
  end

  def handle_call({:addBlock, %Block{} =  block}, _from, {chain}) do
    [prevBlock | _] = chain
    case validateChain(prevBlock, block, chain) do
      {:error, reason} ->
        {:reply, {:error, reason}, chain}
      :ok ->
        {:reply, :ok, [block, chain]}
    end
  end
end
