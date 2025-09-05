# Cryptographic wallets

A cryptographic wallet consists of a private key, which can be used to both find transaction outputs and spend them.  The key itself is one or more large random numbers (usually 256bits in size).  Most wallets will also create a `seed phrase`, which is a series of words which can be used to restore the private key if the wallet is lost.  Users must never store the seed phrase where it is accessible via a device, or share it with any other user.

When storing small amounts of currency (<$1K), users may use a software wallet on a mobile device.  Such users must not use a browser extension, due to the increased attack surface.  Instead use a mobile app, where the key is encrypted by the device.  The seed phrase must be stored externally, preferably written down and kept in a safe deposit box.

For large amounts of currency (<$1M), users must use hardware wallets, such as a Ledger device.  These keep the private key encrypted inside the device, and are resistent to tampering.  Ideally, teams will have a set of `N` devices, with transaction outputs spendable by any of the devices (`1` of `N` multisig), so hardware failures do not result in losing funds.  For a small `N = 3`, at least one of the users must keep a backup device or seed phrase in a safe deposit box.  For larger `N > 5`, the risk of leaking the backup device or seed phrase is greater than the risk all devices failing, so no backup should be made.

For even larger amounts of currency (>$1M), please [contact us](./contacts.md) for specific instructions.

## Hardware wallets

Below we will include specific instructions for configuring various hardware wallets.

### Ledger Nano X

Instructions for setting up a Ledger Nano X can be found [here](https://support.ledger.com/article/360018784134-zd).
