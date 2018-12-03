defmodule BITCOIN.BlockChain.Transaction do
  alias BITCOIN.Wallet.{Wallet, KeyHandler}
  alias BITCOIN.BlockChain.{TxInput, TxOutput}
  @moduledoc """
  Creates transactions and calculates their hash valuess.
  """

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

  @doc """
  Creates a transaction with given values.
  """
  def initialDummyTransaction(outputs) do
    tx = %__MODULE__{
      inputs: [],
      outputs: outputs,
      public_key: "",
      sign_tx: ""
    }
    %{tx | hash: hash(tx)}
  end

  @doc """
  Creates a transaction for a specified wallet with the given input and output
  """
  def createTransaction(%Wallet{} = wallet, inputs, outputs) do
    tx = %__MODULE__{
      hash: wallet.address,
      inputs: inputs,
      outputs: outputs,
      public_key: wallet.public_key
    }
    sign =  tx |> serializeTx() |> Wallet.sign(wallet)
    signedTx = %{tx | sign_tx: sign}
    %{signedTx | hash: hash(signedTx)}
  end

  @doc """
  Converts the transaction into string.
  """
  def serializeTx(%__MODULE__{} = tx) do
    inputSerialized = Enum.reduce(tx.inputs, "", fn input, acc ->
      acc <> input.previous_op_tx_hash <> Integer.to_string(input.index)
    end)
    outputSerialized = Enum.reduce(tx.outputs, "", fn output, acc ->
      acc <> output.wallet_address <> Integer.to_string(output.value)
    end)
    inputSerialized <> outputSerialized <> tx.public_key
  end

  @doc """
  Calculates the hash of a given transaction.
  """
  def hash(tx) do
    KeyHandler.hash(serializeTx(tx) <> tx.sign_tx)
  end
end
