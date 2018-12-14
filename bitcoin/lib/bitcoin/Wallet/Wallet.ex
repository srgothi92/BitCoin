defmodule BITCOIN.Wallet.Wallet do
  require Logger
  alias BITCOIN.Wallet.KeyHandler
  alias BITCOIN.BlockChain.{TxOutput, Transaction, TxInput}

  @moduledoc """
  Manages the wallet for different user nodes.
  """
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

  @doc """
  Creates a wallet.
  """
  def createWallet do
    {publicKey, privateKey} = KeyHandler.keyPairGenerate()

    %__MODULE__{
      address: KeyHandler.publicKeyHash(publicKey),
      public_key: publicKey,
      private_key: privateKey
    }
  end

  @doc """
  Signs the transaction for authenticity.
  """
  # sign the transaction
  def sign(msg, %__MODULE__{private_key: pvKey}) do
    KeyHandler.signMessage(pvKey, msg)
  end

  @doc """
  Verifies the signature on transaction
  """
  # Verify the signature on trnsaction
  def verify(%__MODULE__{public_key: pubKey}, signedMsg, message) do
    KeyHandler.verifySignature(pubKey, signedMsg, message)
  end

  @doc """
  Calculates the balance for a given wallet.
  """
  # finds the balance for particular Wallet from block chain
  def balance(%__MODULE__{} = wallet) do
    unspentOutputs = GenServer.call(:Chain, {:getUnspentOutputsForUser, wallet})
    sumUnspentOutputs(unspentOutputs)
  end

  defp sumUnspentOutputs(unspentOutputs) do
    Enum.reduce(unspentOutputs, 0, fn {_, _, value}, acc -> acc + value end)
  end

  defp getUnspentOutputFromChain(wallet) do
    GenServer.call(:Chain, {:getUnspentOutputsForUser, wallet})
  end

  defp createTransaction(wallet, amount, recepient) do
    result =
      wallet
      |> getUnspentOutputFromChain
      |> Enum.sort(fn {_, _, value1}, {_, _, value2} -> value1 <= value2 end)
      |> chooseOutputs(amount, [])

    tx =
      case result do
        {:ok, txInputs} ->
          txOutputs = [TxOutput.createTxOutput(recepient, amount)]
          txOutputs = txOutputs ++ calculateChangeOutputs(wallet, amount, txInputs)
          txInputs = converToInputFormat(txInputs)
          tx = Transaction.createTransaction(wallet, txInputs, txOutputs)
          tx

        {:error, _} ->
          nil
      end
  end

  @doc """
  Creates a transaction to send provided amount to the receipient
  """
  # Creates a transaction to send provided amount to the receipient
  def send(%__MODULE__{} = wallet, amount, recepient) do
    tx = createTransaction(wallet, amount, recepient)

    if(tx != nil) do
      GenServer.call(:TransactionQueue, {:addToChain, [tx]})
    end
  end

  def transact(%__MODULE__{} = wallet, amount, recepient) do
    # Logger.info("Requested a transaction worth amount #{inspect(amount)}")
    tx = createTransaction(wallet, amount, recepient)

    if(tx != nil) do
      # Logger.info("Created transaction")
      GenServer.cast(:Server, {:broadcastTx, [tx]})
    else
      # Logger.info("Transaction not created, :not_enough_coins")
    end
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
