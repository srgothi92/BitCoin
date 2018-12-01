defmodule BITCOIN.Wallet.Wallet do
  alias BITCOIN.Wallet.KeyHandler
  alias BITCOIN.BlockChain.{Chain, TxOutput, Transaction, TxInput, TransactionQueue}

  @type t :: %__MODULE__{
          address: String.t(),
          public_key: String.t(),
          private_key: String.t()
        }

  defstruct [
    :address,
    :public_key,
    :private_key
  ]

  def createWallet do
    {publicKey, privateKey} = KeyHandler.keyPairGenerate

    %__MODULE__ {
      address: KeyHandler.publicKeyHash(publicKey),
      public_key: publicKey,
      private_key: privateKey
    }
  end

  # sign the transaction
  def sign(msg, %__MODULE__{private_key: pvKey}) do
    KeyHandler.signMessage(pvKey, msg)
  end

  # Verify the signature on trnsaction
  def verify(%__MODULE__{public_key: pubKey}, signedMsg, message) do
    KeyHandler.verifySignature(pubKey, signedMsg, message)
  end

  # finds the balance for particular Wallet from block chain
  def balance(%__MODULE__{} = wallet) do
    unspentOutputs = Chain.getUnspentOutputsForUser(wallet)
    sumUnspentOutputs(unspentOutputs)
  end

  defp sumUnspentOutputs(unspentOutputs) do
    Enum.reduce(unspentOutputs, 0, fn {_, _, value}, acc -> acc + value end)
  end

  # Creates a transaction to send provided amount to the receipient
  def send(%__MODULE__{} = wallet, amount, recepient) do
    {:ok, txInputs} = wallet
    |>Chain.getUnspentOutputsForUser()
    |> Enum.sort(fn {_, _, value1}, {_, _, value2} -> value1 <= value2 end)
    |> chooseOutputs(amount, [])
    txInputs = converToInputFormat(txInputs)
    txOutputs = [TxOutput.createTxOutput(recepient, amount)]
    txOutputs = [ txOutputs | calculateChangeOutputs(wallet, amount, txInputs) ]
    tx = Transaction.createTransaction(wallet, txInputs, txOutputs)
    TransactionQueue.addToQueue(tx)
  end

  defp calculateChangeOutputs(%__MODULE__{} = wallet, amount, txInputs) do
    totalSumNewInput = sumUnspentOutputs(txInputs)

    if totalSumNewInput > amount do
      [TxOutput.createTxOutput(wallet.address, totalSumNewInput - amount)]
    else
      []
    end
  end

  defp converToInputFormat(txInputs) do
    Enum.map(txInputs, fn {txHash, index, _} ->
      TxInput.createTxInput(txHash, index)
    end)
  end

  defp chooseOutputs(_, value, outputs) when value <= 0 do
        {:ok, outputs}
  end

  defp chooseOutputs([], _, _) do
     {:error, :not_enough_coins}
  end

  defp chooseOutputs([{_, _, v} = output | remaining], value, selectedOutputs) do
    # iterate through rest of the outputs till we have enough outputs to match target value
    chooseOutputs(remaining, value - v, [output | selectedOutputs])
  end
end
