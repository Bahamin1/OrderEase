import CkETHCanister "canister:cketh";

import Principal "mo:base/Principal";

module ckEth {
  public type ICRCAccount = CkETHCanister.Account;
  public type TransferArgs = CkETHCanister.TransferArg;
  public type ApproveArgs = CkETHCanister.ApproveArgs;

  public type TransferResult = CkETHCanister.TransferResult;
  public type ApproveResult = CkETHCanister.ApproveResult;

  public func balanceOf(principal : Principal) : async (Nat) {
    let owner : ICRCAccount = { owner = principal; subaccount = null };

    return await CkETHCanister.icrc1_balance_of(owner);
  };

  public func transfer(principal : Principal, amount : Nat) : async CkETHCanister.TransferResult {
    let to : ICRCAccount = { owner = principal; subaccount = null };

    let transferArgs : TransferArgs = {
      to = to;
      amount = amount;
      fee = null;
      memo = null;
      from_subaccount = null;
      created_at_time = null;
    };

    await CkETHCanister.icrc1_transfer(transferArgs);
  };

  public func approve(principal : Principal, amount : Nat) : async CkETHCanister.ApproveResult {
    let spender : ICRCAccount = { owner = principal; subaccount = null };

    let approveArgs : ApproveArgs = {
      spender = spender;
      amount = amount;
      created_at_time = null;
      expected_allowance = null;
      expires_at = null;
      fee = null;
      memo = null;
      from_subaccount = null;
    };

    await CkETHCanister.icrc2_approve(approveArgs);
  };
};
