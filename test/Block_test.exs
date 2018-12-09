defmodule BITCOIN.BlockChain.Block_test do
  use ExUnit.Case
  alias BITCOIN.BlockChain.{Block,Chain}

  test "generate a block" do
    previousHash = "su is stupid"
    transactions = []
    newBlock = Block.createBlock(0, previousHash, transactions)
    hashvalue = Block.hash(newBlock)
    assert hashvalue = "700CE5027808231EC3CB3CD2D0F2F63A998500D40BB1E7569588B70"
  end

  test "verify Block hash size" do
    previousHash = "su is stupid"
    transactions = []
    newBlock = Block.createBlock(0, previousHash, transactions)
    hashValue = Block.hash(newBlock)
    assert byte_size(hashValue) == 64
  end




end
