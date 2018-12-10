defmodule BITCOIN.Wallet.KeyHandler do
  @type_algorithm :ecdh
  @ecdsa_curve :secp256k1
  @type_signature :ecdsa
  @type_hash :sha256
  @moduledoc """
  Handles the encryption of messages.
  """
  @doc """
  Generates public and private key.
  """
  def keyPairGenerate do
    {publicKey, privateKey} = :crypto.generate_key(@type_algorithm, @ecdsa_curve)
    {Base.encode16(publicKey), Base.encode16(privateKey)}
  end

  @doc """
  Signs the message by encoding with private key
  """
  def signMessage(privateKey, message) do
    signedMessage = :crypto.sign(@type_signature, @type_hash, message, [Base.decode16!(privateKey), @ecdsa_curve])
    Base.encode16(signedMessage)
  end

  @doc """
  Verifies whether the signed message is valid by decrypting with public key.
  """
  def verifySignature(publicKey, signature, message) do
    :crypto.verify(@type_signature, @type_hash,message,Base.decode16!(signature),[Base.decode16!(publicKey),@ecdsa_curve])
  end

  @doc """
  Calculates the hash of public key
  """
  def publicKeyHash(publicKey) do
    :crypto.hash(:ripemd160, :crypto.hash(:sha256, publicKey)) |> Base.encode16()
  end

  @doc """
  Calculates the hash of the message
  """
  def hash(message) do
    :crypto.hash(:sha256,message)
    |> Base.encode16()
  end
end
