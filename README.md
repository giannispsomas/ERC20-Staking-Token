## Staking ERC-20 Contract

**This project is an ERC-20 token contract implementation, with added burning, minting, as well as staking and unstaking functionalities**

Functionalities include:

-   Staking and unstaking mechanisms
-   Burning mechanism that acts like penalty if a user decides to stake their tokens, but they withdraw them within 30 days, instead of more.
-   Minting mechanism that gifts the user with a 20 percent bonus token amount if they decide to stake their tokens for more than 30 days.
-   Used the Foundry framework for writing the deploy script, as well as the testing script.