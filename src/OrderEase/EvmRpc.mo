import EvmRpcCanister "canister:evm_rpc";

import Debug "mo:base/Debug";
import Cycles "mo:base/ExperimentalCycles";
import Nat64 "mo:base/Nat64";

module EvmRpc {
  public type Block = EvmRpcCanister.Block;
  public type TransactionReceipt = EvmRpcCanister.TransactionReceipt;
  /// Retrieve the latest block on the Ethereum blockchain.
  public func getLatestEthereumBlock() : async Block {

    // Select RPC providers
    let source : EvmRpcCanister.RpcSource = #EthSepolia(?[#PublicNode]);

    // Call `eth_getBlockByNumber` RPC method (unused cycles will be refunded)
    Cycles.add(1000000000);
    let result = await EvmRpcCanister.eth_getBlockByNumber(source, null, #Latest);

    switch result {
      // Consistent, successful results
      case (#Consistent(#Ok block)) {
        block;
      };
      // Consistent error message
      case (#Consistent(#Err error)) {
        Debug.trap("Error: " # debug_show error);
      };
      // Inconsistent results between RPC providers
      case (#Inconsistent(results)) {
        Debug.trap("Inconsistent results");
      };
    };
  };

  public func getTransactionReceipt(txHash : Text) : async ?EvmRpcCanister.TransactionReceipt {
    // Select RPC providers
    let source : EvmRpcCanister.RpcSource = #EthSepolia(?[#PublicNode]);

    // Call `eth_getTransactionReceipt` RPC method (unused cycles will be refunded)
    Cycles.add(1000000000);
    let result = await EvmRpcCanister.eth_getTransactionReceipt(source, null, txHash);

    switch result {
      // Consistent, successful results
      case (#Consistent(#Ok receipt)) {
        receipt;
      };
      // Consistent error message
      case (#Consistent(#Err error)) {
        Debug.trap("Error: " # debug_show error);
      };
      // Inconsistent results between RPC providers
      case (#Inconsistent(results)) {
        Debug.trap("Inconsistent results");
      };
    };
  };
};
