// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./Base64.sol";

contract Expressions is ERC721Enumerable, Ownable {
    using Strings for uint256;
    bool public paused = false;
    mapping(uint256 => Card) public idCardMapping;
    uint256 public stringLimit = 80;

    struct Card {
        string cardID;
        string description;
        string name;
        string firstLine;
        string secondLine;
    }

    constructor() ERC721("Expressions", "Expressions") {
    }

    function mint(string memory name,string memory firstLine,string memory secondLine, address receiverAddress) public payable {
        uint256 supply = totalSupply();
        require(bytes(name).length <= stringLimit, "Name input exceeds limit.");
        require(bytes(firstLine).length <= stringLimit, "FirstLine input exceeds limit.");
        require(bytes(secondLine).length <= stringLimit, "SecondLine input exceeds limit.");

        Card memory card = Card(
            string(abi.encodePacked("Expressions", uint256(supply + 1).toString())),
            string(abi.encodePacked("Expressions NFT for ", name)),
            name,
            firstLine,
            secondLine
        );

        idCardMapping[supply + 1] = card;
        _safeMint(receiverAddress, supply + 1);
    }

    function buildKudosImage(uint256 _tokenId) private view returns (string memory) {
        Card memory card = idCardMapping[_tokenId];
        return 
            Base64.encode(
                bytes(
                    abi.encodePacked(
                    '<svg width="300" height="400" xmlns="http://www.w3.org/2000/svg">',
                    '<defs>',
                    '<linearGradient id="grad1" x1="0%" y1="0%" x2="100%" y2="0%">',
                    '<stop offset="0%" style="stop-color:rgb(0,255,0);stop-opacity:0.5" />',
                    '<stop offset="100%" style="stop-color:rgb(0,255,255);stop-opacity:0.5" />',
                    '</linearGradient>',
                    '<linearGradient id="rainbow" x1="0%" y1="50%" x2="100%" y2="50%">',
                    '<stop stop-color="#FF5B99" offset="0%"/>',
                    '<stop stop-color="#FF5447" offset="20%"/>',
                    '<stop stop-color="#FF7B21" offset="40%"/>',
                    '<stop stop-color="#EAFC37" offset="60%"/>',
                    '<stop stop-color="#4FCB6B" offset="80%"/>',
                    '<stop stop-color="#51F7FE" offset="100%"/>',
                    '</linearGradient>',
                    '</defs>',
                    '<rect id="svg_11" height="400" width="300" y="0" x="0" fill="url(#grad1)"/>',
                    '<text font-size="30" y="30%" x="50%" text-anchor="middle" fill="rgb(128,128,128)">',
                    card.name,
                    "</text>",
                    '<text font-size="18" y="45%" x="5%" fill="rgb(128,128,128)">',
                    card.firstLine,
                    "</text>",
                    '<text font-size="18" y="50%" x="5%" fill="rgb(128,128,128)">',
                    card.secondLine,
                    "</text>",
                    '<text font-size="14" y="90%" x="65%" fill="rgb(128,128,128)">Powered By</text>',
                    '<text font-size="20" y="95%" x="65%" fill="url(#rainbow)">Expressions</text>',
                    '</svg>'
                    )
                )
            );
    }

    function buildMetadata(uint256 _tokenId)
        private
        view
        returns (string memory)
    {
        Card memory currentCard = idCardMapping[_tokenId];

        return
            string(
                abi.encodePacked(
                    "data:application/json;base64,",
                    Base64.encode(
                        bytes(
                            abi.encodePacked(
                                '{"name":"',
                                currentCard.name,
                                '", "description":"',
                                currentCard.description,
                                '", "image": "',
                                "data:image/svg+xml;base64,",
                                buildKudosImage(_tokenId),
                                '", "attributes": ',
                                "[",
                                '{"trait_type": "CardType",',
                                '"value":"',
                                "Kudos",
                                '"}',
                                "]",
                                "}"
                            )
                        )
                    )
                )
            );
    }

    function tokenURI(uint256 _tokenId)
        public
        view
        virtual
        override
        returns (string memory)
    {
        require(
            _exists(_tokenId),
            "ERC721Metadata: URI query for nonexistent token"
        );
        return buildMetadata(_tokenId);
    }
}
