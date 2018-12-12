defmodule BITCOIN.BlockChain.Chain do
  use GenServer

  alias BITCOIN.BlockChain.{Block, Transaction, TransactionVerify}
  alias BITCOIN.Wallet.Wallet
  @moduledoc """
  Validates proof of work and is responsible for managing the chain.
  """
  @doc """
  Starts the GenServer.
  """
  def start_link() do
    GenServer.start_link(__MODULE__, {}, name: :Chain)
  end

  @doc """
  Initiates the state of the GenServer.
  """
  def init(_) do
    chain = [Block.initialBlock()]
    {:ok, {chain}}
  end

  @doc """
  Validates the proof of work
  """
  def validateProofOfWork(hash) do
    target = Application.get_env(:bitcoin, :target)
    String.slice(hash, 0, target) == String.duplicate("0", target)
  end

  @spec validateBlock(Block.t(), Block.t(), []) :: :ok | {:error, atom()}
  def validateBlock(prevBlock, block, chain) do
    cond do
      # check index values
      prevBlock.index != block.index - 1 ->
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
        TransactionVerify.validateTransactions(block.transactions, chain)
    end
  end

  @doc """
  Returns the latest block in the chain.
  """
  def getLatestBlock() do
    GenServer.call(__MODULE__, :getLatestBlock)
  end

  @doc """
  Adds the block to the chain.
  """
  def addBlock(%Block{} = block) do
    GenServer.call(__MODULE__, {:addBlock, block})
  end

  @doc """
  Returns all the blocks present in the chain.
  """
  def getAllBlocks(%Block{}) do
    GenServer.call(__MODULE__, :getAllBlocks)
  end

  @doc """
  Returns the amount remaining with a user.
  """
  def getUnspentOutputsForUser(%Wallet{} = wallet) do
    GenServer.call(__MODULE__, {:getUnspentOutputsForUser, %Wallet{} = wallet})
  end

  @doc """
  Returns the latest block in the chain.
  """
  def handle_call(:getLatestBlock, _from, {chain}) do
    [prevBlock | _] = chain
    {:reply, prevBlock, {chain}}
  end

  @doc """
  Checks whether the block is correct or not
  Returns an error if the chain is not valid
  Returns the chain containing the added block if it is valid.
  """
  def handle_call({:addBlock, %Block{} = block}, _from, {chain}) do
    [prevBlock | _] = chain

    case validateBlock(prevBlock, block, chain) do
      {:error, reason} ->
        {:reply, {:error, reason}, {chain}}

      :ok ->
        {:reply, :ok, {[block] ++ chain}}
    end
  end

  @doc """
  Returns the chain containing all the blocks.
  """
  def handle_call(:getAllBlocks, _from, {chain}) do
    {:reply, chain, {chain}}
  end

  @doc """
  Returns the amount remaining with a user.
  """
  def handle_call({:getUnspentOutputsForUser, %Wallet{} = wallet}, _from, {chain}) do
    mapInputs = createAllInputMap(chain)
    # remove all the outputs which have been consumed as input at some point of time
    userOutputs =
      Enum.reject(getUserOutputs(wallet, chain), fn {txHash, outputIndex, _} ->
        MapSet.member?(mapInputs, [txHash, outputIndex])
      end)

    {:reply, userOutputs, {chain}}
  end

  # returns all the inputs in complete block chain as map set
  defp createAllInputMap(chain) do
    txIteratorTask(chain, MapSet.new(), fn %Transaction{inputs: inputs}, set ->
      {:cont,
       Enum.reduce(inputs, set, fn input, acc ->
         MapSet.put(acc, [input.previous_op_tx_hash, input.index])
       end)}
    end)
  end

  # It will iterate through all the transactions in complete chain and perform taks provided in func
  # on all transactions and returning the accumulated output
  defp txIteratorTask(chain, acc, func) do
    Enum.reduce_while(chain, acc, fn block, acc ->
      if(block.transactions == []) do
        {:cont, acc}
      else
        acc = Enum.reduce_while(block.transactions, acc, fn tx, acc ->
          func.(tx, acc)
        end)
        {:cont, acc}
      end
    end)
  end

  # gets user outputs in the format of [txHash, index] i.e input format to compare inputs and outputs
  defp getUserOutputs(%Wallet{address: address}, chain) do
    txIteratorTask(chain, [], fn %Transaction{} = tx, acc ->
      acc = acc ++ userOutputsInTx(tx, address)
      {:cont, acc}
    end)
  end

  defp userOutputsInTx(%Transaction{hash: hash, outputs: outputs}, address) do
    indexed_outputs = Enum.with_index(outputs)

    Enum.reduce(indexed_outputs, [], fn {output, index}, acc ->
      if output.wallet_address == address do
        [{hash, index, output.value} | acc]
      else
        acc
      end
    end)
  end

  def handle_call(:getBlockCount, _from, {chain}) do
    {:reply, length(chain), {chain}}
  end

  # def handle_info({:DOWN, ref, :process, _pid, _reason}, {chain}) do
  #   {:noreply, {chain}}
  # end
end
