defmodule BITCOIN.BlockChain.Functional_test do
  import MockChain

  alias BITCOIN.BlockChain.{Block, TxInput, TxOutput, Transaction}

  use ExUnit.Case, async: true

  setup do
    {:ok, mockLedger()}
  end

  test "Check index of new block before adding it to chain" do
    newBlock = Block.createBlock(0, "0", [])
    result = GenServer.call(:Chain, {:addBlock, newBlock})
    assert result == {:error, :invalid_index}
  end

  test "Check previous hash of new block has correct previous block hash before adding it to chain" do
    newBlock = Block.createBlock(7, "Abc", [])
    result = GenServer.call(:Chain, {:addBlock, newBlock})
    assert result == {:error, :invalid_prvious_hash}
  end

  test "Check if the hash of the block is correct" do
    previousBlock = GenServer.call(:Chain, :getLatestBlock)
    newBlock = Block.createBlock(7, previousBlock.hash, [])
    newBlock = %{newBlock | hash: ""}
    result = GenServer.call(:Chain, {:addBlock, newBlock})
    assert result == {:error, :invalid_block_hash}
  end

  test "Check if the proofOFWork is correct" do
    previousBlock = GenServer.call(:Chain, :getLatestBlock)
    newBlock = Block.createBlock(7, previousBlock.hash, [])
    blockHash = Block.hash(newBlock)
    newBlock = %{newBlock | hash: blockHash}
    result = GenServer.call(:Chain, {:addBlock, newBlock})
    assert result == {:error, :invalid_proof_of_work}
  end

  test "Transaction vlaidation for empty transaction" do
    result = GenServer.call(:TransactionQueue, {:addToChain, []})
    assert result == {:error, :empty_transaction}
  end

  test "Transaction vlaidation for incorrect input", %{su: su, mu: mu, lu: lu} do
    inputs = [TxInput.createTxInput("suTx.hash", 0)]

    outputs = [
      TxOutput.createTxOutput(mu.address, 20),
      TxOutput.createTxOutput(lu.address, 10),
      TxOutput.createTxOutput(su.address, 20)
    ]

    tx1 = Transaction.createTransaction(su, inputs, outputs)
    result = GenServer.call(:TransactionQueue, {:addToChain, [tx1]})
    assert result == {:error, :some_inputs_does_not_exist}
  end

  test "Transaction vlaidation for incorrect input - outupt sum", %{tx4: tx4, su: su, mu: mu, lu: lu} do
    inputs = [TxInput.createTxInput(tx4.hash, 0)]

    outputs = [
      TxOutput.createTxOutput(mu.address, 20),
      TxOutput.createTxOutput(lu.address, 10),
      TxOutput.createTxOutput(su.address, 20)
    ]

    tx1 = Transaction.createTransaction(su, inputs, outputs)
    result = GenServer.call(:TransactionQueue, {:addToChain, [tx1]})
    assert result == {:error, :invalid_input_minus_output_sum}
  end

  test "Transaction vlaidation for double spending of same input", %{tx4: tx4, su: su, mu: mu, lu: lu} do
    inputs = [TxInput.createTxInput(tx4.hash, 0), TxInput.createTxInput(tx4.hash, 0)]

    outputs = [
      TxOutput.createTxOutput(mu.address, 2)
    ]

    tx1 = Transaction.createTransaction(su, inputs, outputs)
    result = GenServer.call(:TransactionQueue, {:addToChain, [tx1]})
    assert result == {:error, :invalid_inputs_uniqueness}
  end

  test "Transaction vlaidation for input signature and person autorizing transaction are same", %{tx4: tx4, su: su, mu: mu, lu: lu} do
    inputs = [TxInput.createTxInput(tx4.hash, 0)]

    outputs = [
      TxOutput.createTxOutput(mu.address, 2)
    ]

    tx1 = Transaction.createTransaction(lu, inputs, outputs)
    result = GenServer.call(:TransactionQueue, {:addToChain, [tx1]})
    assert result =={:error, :invalid_input_ownership}
  end

  test "Su balance", %{nodeSu: nodeSu} do
    suBalance = GenServer.call(elem(nodeSu, 1), :balance)
    assert suBalance == 36
  end

  test "Mu Balance", %{nodeMu: nodeMu} do
    muBalance = GenServer.call(elem(nodeMu, 1), :balance)
    assert muBalance == 36
  end

  test "Lu Balance", %{nodeLu: nodeLu} do
    luBalance = GenServer.call(elem(nodeLu, 1), :balance)
    assert luBalance == 6
  end

  test "Su trnasfer 10 to Mu", %{nodeSu: nodeSu, nodeMu: nodeMu} do
    GenServer.call(
      elem(nodeSu, 1),
      {:send, 6, GenServer.call(elem(nodeMu, 1), :getWallet).address}
    )

    suBalance = GenServer.call(elem(nodeSu, 1), :balance)
    muBalance = GenServer.call(elem(nodeMu, 1), :balance)
    assert muBalance == 34
    assert suBalance == 39
  end
end
