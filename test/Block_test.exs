defmodule BITCOIN.BlockChain.Block_test do
  use ExUnit.Case
  alias BITCOIN.BlockChain.{Block,Chain}

  test "generate a block" do
    previousHash = "su is stupid"
    transactions = []
    newBlock = Block.createBlock(previousHash, transactions)
    hashvalue = Block.hash(newBlock)
    IO.inspect(hashvalue)
    assert hashvalue = "700CE5027808231EC3CB3CD2D0F2F63A998500D40BB1E7569588B70"


  end




end
