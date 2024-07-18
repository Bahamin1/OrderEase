import CkETHCanister "canister:cketh";

import Principal "mo:base/Principal";
import Result "mo:base/Result";

module ckEthMinter {
  public let MINTER = "jzenf-aiaaa-aaaar-qaa7q-cai";

  public type WithdrawalArg = { recipient : Text; amount : Nat };

  public type WithdrawalError = {
    #TemporarilyUnavailable : Text;
    #InsufficientAllowance : { allowance : Nat };
    #AmountTooLow : { min_withdrawal_amount : Nat };
    #RecipientAddressBlocked : { address : Text };
    #InsufficientFunds : { balance : Nat };
  };
  public type RetrieveEthRequest = { block_index : Nat };

  public type RetrieveResult = Result.Result<RetrieveEthRequest, WithdrawalError>;

  public let minter = actor (MINTER) : actor {
    withdraw_eth : shared WithdrawalArg -> async {
      #ok : RetrieveEthRequest;
      #err : WithdrawalError;
    };
  };

  public func withdrawEth(amount : Nat, recipient : Text) : async RetrieveResult {
    return await minter.withdraw_eth({ recipient; amount });
  };
};
