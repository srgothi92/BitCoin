defmodule BITCOIN.Wallet.KeyHandler do
  @type_algorithm :ecdh
  @ecdsa_curve :secp256k1
  @type_signature :ecdsa
  @type_hash :sha256

  def keyPairGenerate do
    {publicKey, privateKey} = :crypto.generate_key(@type_algorithm, @ecdsa_curve)
    {Base.encode16(publicKey), Base.encode16(privateKey)}
  end

  def signMessage(privateKey, message) do
    :crypto.sign(@type_signature, @type_hash, message, [Base.decode16!(privateKey), @ecdsa_curve])
  end

  def verifySignature(publicKey, signature, message) do
    :crypto.verify(@type_signature, @type_hash, message, Base.decode16!(signature), [Base.decode16!(publicKey), @ecdsa_curve])
  end

  def publicKeyHash(publicKey) do
    :crypto.hash(:ripemd160, :crypto.hash(:sha256, publicKey)) |> Base.encode16()
  end
end
