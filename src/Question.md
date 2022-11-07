1. safeTransferFrom and transferFrom. What are the differences between these two functions?

`safeTransferFrom` is used to check if the address that's receiving the token is an ERC721 receiver or not. This is in order to ensure that the NFT does not get locked up in an address from which it can never be recovered

`transferFrom` does not implement the check prior to setting the value of its mapping to the new address
