import Array "mo:base/Array";
import Blob "mo:base/Blob";
import Buffer "mo:base/Buffer";
import Debug "mo:base/Debug";
import Nat "mo:base/Nat";
import Nat8 "mo:base/Nat8";
import Principal "mo:base/Principal";
import Text "mo:base/Text";

import Hex "Hex";

module EthUtils {
  public let MINTER_ADDRESS : Text = "0xb44b5e756a894775fc32eddf3314bb1b1944dc34";

  public func principalToBytes32(account : Principal) : Text {
    let blob = Principal.toBlob(account);
    let array = Blob.toArray(blob);

    var buffer = Buffer.fromArray<Nat8>(array);

    while (buffer.size() < 31) {
      buffer.add(0);
    };

    return "0x0a" # Hex.encode(Buffer.toArray(buffer));
  };

  public func hexToNat(hex : Text) : Nat {
    var upperHex = Text.toUppercase(hex);

    let hexArray = switch (Text.startsWith(upperHex, #text "0X")) {
      case (true) {
        let cleanHex = Text.stripStart(upperHex, #text "0X");
        switch (cleanHex) {
          case (null) {
            Debug.trap("Failed to strip 0x");
          };
          case (?cleanHex) {
            Hex.decode(cleanHex);
          };
        };
      };
      case (false) {
        Hex.decode(upperHex);
      };
    };

    switch (hexArray) {
      case (#err(_)) {
        return 0;
      };
      case (#ok(array)) {
        var nat : Nat = 0;

        for (byte in array.vals()) {
          nat := nat * 256 + Nat8.toNat(byte);
        };

        return (nat);
      };
    };
  };

  public func hexToEthAddress(hex : Text) : Text {
    var upperHex = Text.toUppercase(hex);

    let hexArray = switch (Text.startsWith(upperHex, #text "0X")) {
      case (true) {
        let cleanHex = Text.stripStart(upperHex, #text "0X");
        switch (cleanHex) {
          case (null) {
            Debug.trap("Failed to strip 0x");
          };
          case (?cleanHex) {
            Hex.decode(cleanHex);
          };
        };
      };
      case (false) {
        Hex.decode(upperHex);
      };
    };

    switch (hexArray) {
      case (#err(_)) {
        return Debug.trap("Failed to decode hex");
      };
      case (#ok(array)) {
        if (array.size() != 32) {
          Debug.trap("Invalid address length");
        };

        var addressArray = Array.take(array, -20);

        return "0x" # Hex.encode(addressArray);
      };
    };
  };
};
