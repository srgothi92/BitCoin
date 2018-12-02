defmodule BITCOIN.BlockChain.TransactionVerify do
  alias BITCOIN.BlockChain.{Transaction, TxInput}
  alias BITCOIN.Wallet.{KeyHandler}

  def validateTransactions([] = currentTxs, chain) do
    :ok
  end

  @spec validateTransactions([Transaction], [Transaction]) :: :ok | {:error, atom}
  def validateTransactions(currentTxs, chain) do
    # For now there is only one transaction in a block
    cond do
      currentTxs == [] ->
        {:error, :emptyBlock}

      true ->
        validateTransaction(Enum.at(currentTxs, 0), currentTxs, chain)
    end

    # if(validationOp != :ok) do
    #   validationOp
    # else
    #   validateTransactions(remainingTxs, chain)
    # end
  end

  @spec validateTransaction(Transaction, [Transaction], [Transaction]) :: :ok | {:error, atom}
  def validateTransaction(%Transaction{} = tx, currentTxs, chain) do
    cond do
      # for initial dummy transaction
      tx.inputs == [] ->
        :ok

      !validateInputExists(tx, chain) ->
        {:error, :some_inputs_does_not_exist}

      # Sum of inputs should be greater than sum of outputs
      !validateTotalSum(tx, chain) ->
        {:error, :invalid_input_minus_output_sum}

      # inputs should be unique across a block, multiple spendings are not allowed.
      !validateInputsNotSpent(currentTxs) ->
        {:error, :invalid_inputs_uniqueness}

      # Person authorizing the transaction should be same as wallet address in each input's previous output
      !validateInvalidOwnership(tx, chain) ->
        {:error, :invalid_input_ownership}

      true ->
        :ok
    end
  end

  defp checkInputsDuplicated?([], _) do
    true
  end

  defp checkInputsDuplicated?([currentTx | remainingTxs], inputMap) do
    # Enum.any evaluates to true when any input value repeats so we have negate the value
    bInputDuplicated =
      !Enum.any?(currentTx.inputs, fn input ->
        cond do
          Map.has_key?(inputMap, input.previous_op_tx_hash) && Map.get(inputMap, input.previous_op_tx_hash) == input.index ->
            IO.inspect Map.has_key?(inputMap, input.previous_op_tx_hash)
            true

          true ->
            inputMap = Map.put(inputMap, input.previous_op_tx_hash, input.index)
        end
      end)

    if(bInputDuplicated == true) do
      false
    else
      # validate with rest of the list
      checkInputsDuplicated?(remainingTxs, inputMap)
    end
  end

  defp validateInputsNotSpent(currentTxs) do
    checkInputsDuplicated?(currentTxs, %{})
  end

  defp findPreviousTx(%TxInput{} = input, []) do
    nil
  end

  defp findPreviousTx(%TxInput{} = input, [block | remainingBlocks]) do
    prevTx =
      if(block.transactions != []) do
        Enum.find(block.transactions, fn %Transaction{hash: hash} ->
          hash == input.previous_op_tx_hash
        end)
      else
        nil
      end

    if(prevTx == nil) do
      findPreviousTx(input, remainingBlocks)
    else
      prevTx
    end
  end

  defp findPreviousOutput(%TxInput{} = input, chain) do
    prevTx = findPreviousTx(input, chain)
    Enum.at(prevTx.outputs, input.index)
  end

  defp totalInputSum(%Transaction{} = tx, chain) do
    inputSum =
      tx.inputs
      |> Enum.reduce(0, fn input, acc ->
        previousOutput = findPreviousOutput(input, chain)
        acc + previousOutput.value
      end)

    inputSum
  end

  defp totalOutputSum(%Transaction{} = tx) do
    tx.outputs
    |> Enum.reduce(0, fn output, acc ->
      acc + output.value
    end)
  end

  defp validateInputExists(tx, chain) do
    Enum.any?(tx.inputs, fn input ->
      prevTx = findPreviousTx(input, chain)

      if(prevTx == nil) do
        false
      else
        true
      end
    end)
  end

  defp validateTotalSum(%Transaction{} = tx, chain) do
    inputSum = totalInputSum(tx, chain)
    outputSum = totalOutputSum(tx)
    inputSum >= outputSum
  end

  defp validateInvalidOwnership(%Transaction{} = tx, chain) do
    # validate Signature of Transaction
    address = KeyHandler.publicKeyHash(tx.public_key)
    message = Transaction.serializeTx(tx)
    bSignature = KeyHandler.verifySignature(tx.public_key, tx.sign_tx, message)

    if !bSignature do
      {:error, :invalid_tx_signature}
    end

    !Enum.any?(tx.inputs, fn input ->
      # check owership of each input is same as person authorizing the transaction
      prevTx = findPreviousTx(input, chain)
      prevOutput = Enum.at(prevTx.outputs, input.index)

      if(prevOutput.wallet_address != address) do
        false
      end
    end)
  end
end
