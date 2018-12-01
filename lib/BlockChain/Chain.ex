defmodule BITCOIN.BlockChain.Chain do
  use GenServer

  alias BITCOIN.BlockChain.{Block, Transaction, TransactionVerify}
  alias BITCOIN.Wallet.Wallet

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

  @spec validateBlock(Block.t(), Block.t()) :: :ok | {:error, atom()}
  defp validateBlock(prevBlock, block) do
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
        TransactionVerify.validateTransactions(block.transaction, prevBlock)
    end
  end

  def getLatestBlock() do
    GenServer.call(__MODULE__, :getLatestBlock)
  end

  def addBlock(%Block{} = block) do
    GenServer.call(__MODULE__, {:addBlock, block})
  end

  def getAllBlocks(%Block{}) do
    GenServer.call(__MODULE__, :getAllBlocks)
  end

  def getUnspentOutputsForUser(%Wallet{} = wallet) do
    GenServer.call(__MODULE__, {:getUnspentOutputsForUser, %Wallet{} = wallet})
  end

  def handle_call(:getLatestBlock, _from, {chain}) do
    [prevBlock | _] = chain
    prevBlock
  end

  def handle_call({:addBlock, %Block{} = block}, _from, {chain}) do
    [prevBlock | _] = chain

    case validateBlock(prevBlock, block) do
      {:error, reason} ->
        {:reply, {:error, reason}, chain}

      :ok ->
        {:reply, :ok, {[block, chain]}}
    end
  end

  def handle_call(:getAllBlocks, _from, {chain}) do
    {:reply, chain, {chain}}
  end

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
    Enum.reduce_while(chain, acc, fn %{transactions: transactions}, acc ->
      case transactions do
        %Transaction{} ->
          func.(transactions, acc)

        _ ->
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
end
