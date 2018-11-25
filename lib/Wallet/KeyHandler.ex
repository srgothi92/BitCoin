defmodule BITCOIN.Wallet.KeyHandler do
  @type_algorithm :ecdh
  @ecdsa_curve :secp256k1
  @type_signature :ecdsa
  @type_hash :sha256

  def keyPairGenerate do
    :crypto.generate_key(@type_algorithm, @ecdsa_curve)
  end

  def signMessage(privateKey, message) do
    :crypto.sign(@type_signature, @type_hash, message, [privateKey, @ecdsa_curve])
  end

  def verifySignature(publicKey, signature, message) do
    :crypto.verify(@type_signature, @type_hash, message, signature, [publicKey, @ecdsa_curve])
  end
end
