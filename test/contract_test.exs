defmodule ContractTest do
  alias UltraDark.{Blockchain, Blockchain.Block, Transaction, Contract, ChainState}
  use ExUnit.Case, async: true

  test "can call method from contract with enough gamma" do
    chain = Blockchain.initialize
    block =
      List.first(chain)
      |> Block.initialize()

    contract_bin = Contract.compile("test/fixtures/test_contract.js")
    contract_address = Contract.generate_contract_address("random_pubkey", contract_bin)

    transaction =
      %Transaction{
        data: contract_bin,
        txtype: "CONTRACT"
      }
    transaction = %{transaction | id: Transaction.calculate_hash(transaction)}

    mined_block =
      %{block | transactions: [transaction]}
      |> Block.mine()

    ChainState.create_new(contract_address, transaction.id, mined_block)
    Blockchain.add_block(chain, mined_block)

    interacting_transaction = %Transaction{ max_gamma: 100_000 }

    assert {:ok, _result, _gamma} =
      contract_address
      |> UltraDark.Contract.run_contract({"main", []}, interacting_transaction)
  end

  # test "can call method from contract that exceeds gamma" do
  #   contract_params = %{
  #     block_hash: "This is a block hash",
  #     block_index: 1,
  #     block_nonce: 123_131,
  #     transaction_id: "Some transaction ID here",
  #     max_gamma: 10_000
  #   }
  #
  #   error =
  #     "test/fixtures/test_contract.js"
  #     |> UltraDark.Contract.run_contract({"reallyExpensiveFunction", []}, contract_params)
  #
  #   assert {:error, "Out of Gamma"} = error
  # end
  #
  # test "can call method from contract with exact gamma" do
  #   contract_params = %{
  #     block_hash: "This is a block hash",
  #     block_index: 1,
  #     block_nonce: 123_131,
  #     transaction_id: "Some transaction ID here",
  #     max_gamma: 7506
  #   }
  #
  #   assert {:ok, _result, _gamma} =
  #     "test/fixtures/test_contract.js"
  #     |> UltraDark.Contract.run_contract({"main", []}, contract_params)
  # end
end
