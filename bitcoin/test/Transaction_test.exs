defmodule BITCOIN.BlockChain.Transaction_test do
  use ExUnit.Case
  alias BITCOIN.BlockChain.{Transaction, TxOutput, TxInput}
  alias BITCOIN.Wallet.{Wallet, KeyHandler}

  setup do
    {:ok,
     %{
       jack: Wallet.createWallet(),
       mike: Wallet.createWallet()
     }}
  end

  test "Transaction creation", %{jack: jack, mike: mike} do
    inputs = [TxInput.createTxInput("su is gone", 1)]
    outputs = [TxOutput.createTxOutput(mike.address, 10)]
    transaction = Transaction.createTransaction(jack, inputs, outputs)

    assert transaction.inputs == inputs
    assert transaction.outputs == outputs
    assert transaction.public_key == jack.public_key
    assert byte_size(transaction.hash) == 64

    stringTx = Transaction.serializeTx(transaction)

    assert KeyHandler.verifySignature(jack.public_key, transaction.sign_tx, stringTx)
  end


  end
