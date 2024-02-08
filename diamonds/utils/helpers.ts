import { ethers } from "hardhat";

export function getSelectors(_interface: any): Array<string> {
  return Object.keys(_interface.functions).map((item) =>
    _interface.getSighash(item)
  );
}

export function bytesToHex(uint8a: Uint8Array): string {
  const hexes = Array.from({ length: 256 }, (v, i) =>
    i.toString(16).padStart(2, "0")
  );

  let hex = "";
  for (let i = 0; i < uint8a.length; i++) {
    hex += hexes[uint8a[i]];
  }
  return hex;
}
