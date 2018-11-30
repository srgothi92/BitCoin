defmodule BITCOIN.BlockChain.TransactionVerify do
  alias BITCOIN.BlockChain.{Transaction, TxInput}
  alias BITCOIN.Wallet.{KeyHandler}

  @spec validateTransactions([Transaction], [Transaction]) :: :ok | {:error, atom}
  def validateTransactions(currentTxs, previousBlockTxs) do
    Enum.all?(currentTxs, fn tx ->
      validateTransaction(tx, currentTxs, previousBlockTxs)
    end)
  end

  @spec validateTransaction(Transaction, [Transaction], [Transaction]) :: :ok | {:error, atom}
  def validateTransaction(%Transaction{} = tx, currentTxs, previousBlockTxs) do
    cond do
      # Sum of inputs should be greater than sum of outputs
      !validateTotalSum(tx, previousBlockTxs) ->
        {:error , :invalid_input_minus_output_sum}
      # inputs should be unique across a block, multiple spendings are not allowed.
      !validateInputsNotSpent(tx, currentTxs) ->
        {:error , :invalid_inputs_uniqueness}
      # Person authorizing the transaction should be same as wallet address in each input's previous output
      !validateInvalidOwnership(tx, previousBlockTxs) ->
        {:error , :invalid_input_ownership}
      true ->
        :ok
    end
  end

  defp checkInputsDuplicated?([], _) do
    true
  end

  defp checkInputsDuplicated?([ currentTxs | remainingTxs], inputMap) do
    # Enum.any evaluates to true when any input value repeats so we have negate the value
    bInputDuplicated = !Enum.any?(currentTxs.inputs, fn input, acc ->
      if(Map.has_key?(acc, input.hash)) do
        true
      end
      if(Map.get(acc, input.index)) do
        true
      end
      inputMap = Map.put(inputMap, input.hash, input.index)
      false
    end)
    if(bInputDuplicated) do
      false
    else
      # validate with rest of the list
      checkInputsDuplicated?(remainingTxs, inputMap)
    end
  end

  defp validateInputsNotSpent(_, currentTxs) do
    checkInputsDuplicated?(currentTxs, %{})
  end

  defp findPreviousTx(%TxInput{} = input, previousBlockTxs) do
    Enum.find(previousBlockTxs, fn prevTx ->
      prevTx.hash == input.hash
    end)
  end

  defp findPreviousOutput(%TxInput{} = input, previousBlockTxs) do
    prevTx = findPreviousTx(input, previousBlockTxs)
    Enum.at(prevTx.outputs, input.index)
  end

  defp totalInputSum(%Transaction{} = tx, previousBlockTxs) do
    tx.inputs |> Enum.reduce(0, fn (input, acc) ->
      acc + findPreviousOutput(input, previousBlockTxs).value
    end)
  end

  defp totalOutputSum(%Transaction{} = tx) do
    tx.outputs |> Enum.reduce(0, fn (output, acc) ->
      acc + output.value
    end)
  end

  defp validateTotalSum(%Transaction{} = tx, previousBlockTxs) do
    totalInputSum(tx, previousBlockTxs) > totalOutputSum(tx)
  end

  defp validateInvalidOwnership(%Transaction{} = tx, previousBlockTxs) do
    # validate Signature of Transaction
    address = KeyHandler.publicKeyHash(tx.public_key)
    message = Transaction.serializeTx(tx)
    bSignature = KeyHandler.verifySignature(tx.public_key, tx.sign_tx, message)
    if bSignature do
      :ok
    else
      {:error, :invalid_tx_signature}
    end
    !Enum.reduce(tx.inputs,fn input ->
      # check owership of each input is same as person authorizing the transaction
      prevTx = findPreviousTx(input, previousBlockTxs)
      prevOutput = Enum.at(prevTx.outputs, input.index)
      if(prevOutput.wallet_address != address) do
        {:error, :invalid_input_owner}
      end

    end)
  end
end
