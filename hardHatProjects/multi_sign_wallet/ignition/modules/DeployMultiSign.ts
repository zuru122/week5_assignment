// ignition/modules/DeployMultiSign.ts
import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

export default buildModule("DeployMultiSign", (m) => {
  // Define your 3 owners dynamically using module parameters
  const OWNER_1 = m.getParameter("owner1"); // e.g., 0xabc...
  const OWNER_2 = m.getParameter("owner2");
  const OWNER_3 = m.getParameter("owner3");

  if (!OWNER_1 || !OWNER_2 || !OWNER_3) {
    throw new Error(
      "You must provide three owner addresses as parameters: owner1, owner2, owner3",
    );
  }

  // Deploy MultiSignWallet with 3 owners
  const multiSignWallet = m.contract("MultiSignWallet", [
    OWNER_1,
    OWNER_2,
    OWNER_3,
  ]);

  return { multiSignWallet };
});
