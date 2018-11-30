defmodule BITCOIN.BlockChain.Transaction do
  alias BITCOIN.Wallet.{Wallet}
  alias BITCOIN.BlockChain.{TxInput, TxOutput}
  defstruct [
    :sign_tx,
    # public key of user who authorized this transaction
    :public_key,
    # Hash Value of Transaction
    :hash,
    # A list of 1 or more transaction inputs or sources for coins
    :inputs,
    # A list of 1 or more transaction outputs or destinations for coins
    :outputs
  ]

  @type t :: %__MODULE__{
          sign_tx: String.t(),
          public_key: String.t(),
          hash: String.t(),
          inputs: list(TxInput.t()),
          outputs: list(TxOutput.t())
        }

  def createTransaction(%Wallet{} = wallet, inputs, outputs) do
    tx = %__MODULE__{
      hash: wallet.t(),
      inputs: inputs,
      outputs: outputs
    }
    sign =  tx |> serializeTx() |> Wallet.sign(wallet)
    signedTx = %{tx | sign_tx: sign}
    %{signedTx | hash: computeHash(signedTx)}
  end

  def serializeTx(%__MODULE__{} = tx) do
    inputSerialized = Enum.reduce(tx.inputs, "", fn input, acc ->
      acc <> input.previous_op_tx_hash <> Integer.to_string(input.index)
    end)
    outputSerialized = Enum.reduce(tx.outputs, "", fn output, acc ->
      acc <> output.wallet_address <> Integer.to_string(output.value)
    end)
    inputSerialized <> outputSerialized <> tx.public_key
  end

  defp computeHash(tx) do
    serializeTx(tx) <> tx.sign_tx
  end
end
