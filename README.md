# BITCOIN

**The program implements Bitcoin Protocol. It mines bitcoins, implements wallets and performs transactions.**

## Group Info

UFID: 8115-5459 Shaileshbhai Revabhai Gothi


UFID: 8916-9425 Sivani Sri Sruthi Korukonda

## Instructions

To run the code for this project, simply run in your terminal:

```elixir
$ mix compile
```

## Tests

To run the tests for this project, simply run in your terminal:

```elixir
$ mix test
```

## Test Cases implemented

1.BlockTest

Block_test checks whether the generated block is valid or not and also whether the hash size of the block remains the same.
The hash size is verified instead of the hash value because hash value keeps changing as it is based on timestamp and hence is not possible to verify

2.FunctionalTest

Functional_test has multiple test cases. The hash of the block is verified. The proof of work is validated. The transaction validation is done
for empty transaction, incorrect inputs , double spending problem, incorrect value for the difference between input and output values.
The balance of the users are also tested after a transaction is done.

3.KeyHandlerTest

KeyHandler_test verifies whether the encrypted message is valid or not

4.TransactionTest

Transaction_test checks the creation of transaction based on the given input and output.

## Documentation

To generate the documentation, run the following command in your terminal:

```elixir
$ mix docs
```
This will generate a doc/ directory with a documentation in HTML. 
To view the documentation, open the index.html file in the generated directory.



