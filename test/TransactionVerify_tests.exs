defmodule BITCOIN.BlockChain.TransactionVerify_tests do
  import MockChain
  alias BITCOIN.BlockChain.{Transaction, TxOutput, TxInput}

  use ExUnit.Case, async: true

  setup do
    {:ok, mockLedger()}
  end

  test "Transaction vlaidation for incorrect input", %{su: su} do
    inputs = [TxInput.createTxInput("suTx.hash", 0), TxInput.createTxInput(suTx.hash, 0)]

    outputs = [
      TxOutput.createTxOutput(mu.address, 20),
      TxOutput.createTxOutput(lu.address, 10),
      TxOutput.createTxOutput(su.address, 20)
    ]

    tx1 = Transaction.createTransaction(su, inputs, outputs)
    :ok = GenServer.call(:TransactionQueue, {:addToQueue, tx1})
    assert false
  end
end
