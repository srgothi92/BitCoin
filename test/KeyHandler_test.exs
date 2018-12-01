defmodule BITCOIN.Wallet.KeyHandler_test do
  use ExUnit.Case
  alias BITCOIN.Wallet.KeyHandler

  test "check public key" do
    {publicKey, privateKey} = KeyHandler.keyPairGenerate
    signedMessage = KeyHandler.signMessage(privateKey, "su is sleepy")
    verifiedMessage = KeyHandler.verifySignature(publicKey,signedMessage,"su is sleepy")
    assert verifiedMessage = true
  end

end
