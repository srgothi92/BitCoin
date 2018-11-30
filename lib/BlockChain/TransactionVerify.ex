defmodule BITCOIN.BlockChain.TransactionVerify do
  alias BITCOIN.BlockChain.Transaction

  @spec validateTransactions([Transaction]) :: boolean
  def validateTransactions(txs) do
    Enum.all?(txs, fn tx ->
      validateTransaction(tx)
    end)
  end

  @spec validateTransaction(Transaction) :: boolean
  def validateTransaction(%Transaction{} = tx) do

  end
end
