// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

/**
 * @title OXYToken
 * @dev The token for compensation on OXY ecosystem
 * Taken from https://github.com/oxychain-earth/smart-contracts/blob/master/contracts/OXYToken.sol
 */
contract OXYToken is Ownable, ERC1155 {
    using SafeMath for uint256;

    // @dev Used to keep the count of projects created
    uint256 public projectsCreated = 0;

    // @dev Used to keep the count of batch of oxy tokens minted
    uint256 public tokenIds = 0;

    // @dev Used to keep the relationship between projects and token ids
    mapping(uint256 => uint256[]) public projectToTokenIds;

    // @dev Used to keep the relationship between token ids and the projects
    mapping(uint256 => uint256) public tokenIdsToProjectIds;

    // @dev Used to keep the relationship between serial numbers and tokens
    mapping(bytes => uint256) public serialNumbersToToken;

    // @dev Used to keep the relationship between tokens and serial numbers
    mapping(uint256 => bytes) public tokenToSerialNumber;

    // @dev Used to keep the relationship between token ids and the amount minted
    mapping(uint256 => uint256) public tokenIdsToAmounts;

    // @dev Emited every time the smart contract owner creates a new project
    event ProjectCreated(uint256 indexed projectId, address indexed owner);

    // @dev Emited every time the smart contract owner creates a new token
    event TokenCreated(
        uint256 indexed projectId,
        uint256 indexed tokenId,
        address indexed owner
    );

    // @dev Emited every time the smart contract owner issues new tokens
    event OxygenIssued(
        uint256 indexed tokenId,
        uint256 indexed amount,
        address indexed owner
    );

    /**
     * @notice Construct a new OXY Token
     * @dev ERC1155 receives as param the metadata address
     */
    constructor()
        ERC1155(
            "https://gateway.pinata.cloud/ipfs/QmTgHC8XooNzaVQEUyCz36sYJjw9HETfs7kPpgPirRTfzm{id}"
        )
    {}

    /**
     * @dev Creates a new project
     * @dev Emits ProjectCreated event each time is called
     */
    function createProject() external onlyOwner returns (uint256) {
        projectsCreated = projectsCreated.add(1);

        emit ProjectCreated(projectsCreated, msg.sender);

        return projectsCreated;
    }

    /**
     * @dev Start a new generation event by assigning a new token id to an existing project
     * @dev Emits TokenCreated event each time is called
     *
     * @param '_projectId' the id of the project where we create the new batch
     *
     * Requirements:
     *
     * - `_projectId` has to be more than 0 - it has to be oriented to an existing project.
     * - `projectsCreated' has to be bigger or equal to '_projectId'  - it has to be oriented to an existing project.
     */
    function createNewTokenBatch(uint256 _projectId)
        external
        onlyOwner
        returns (uint256)
    {
        require(
            _projectId != 0,
            "OXYToken::mint: Project ID has to be different than 0."
        );
        require(
            _projectId <= projectsCreated,
            "OXYToken::mint: Project has not been initialized yet."
        );

        tokenIds = tokenIds.add(1);

        projectToTokenIds[_projectId].push(tokenIds);
        tokenIdsToProjectIds[tokenIds] = _projectId;

        emit TokenCreated(_projectId, tokenIds, msg.sender);

        return tokenIds;
    }

    /**
     * @dev Mint '_amount' of tokens and assign '_serialNumber' to the issuance of '_tokenId'
     * @dev Each '_tokenId' can only be minted once
     *
     * @param _tokenId the id of the token to mint
     * @param _amount the amount of tokens to mint
     * @param _serialNumber the serial number linked to the issuance in the registry
     *
     * Requirements:
     *
     * - '_tokenId' has to be different than 0 - there's no token 0.
     * - `_tokenId` has to be smaller or equal to 'tokenIds' - it needs to be a valid token.
     * - `tokenIdsToAmounts[_tokenId]` must be 0 - the token must not be minted already.
     * - '_serialNumber' must be different than empty - minimum string validation.
     * - '_serialNumber' must be unique - must not have been used before.
     * - '_amount' has to be bigger than 0, must mint at least 1 token.
     */
    function mint(
        uint256 _tokenId,
        uint256 _amount,
        string memory _serialNumber
    ) public onlyOwner {
        require(
            _tokenId != 0,
            "OXYToken::mint: Token ID has to be different than 0."
        );
        require(
            _tokenId <= tokenIds,
            "OXYToken::mint: Token has not been initialized yet."
        );
        require(
            tokenIdsToAmounts[_tokenId] == 0,
            "OXYToken::mint: '_tokenId' has already been minted."
        );
        bytes memory serialNumber = bytes(_serialNumber);
        require(
            serialNumber.length != 0,
            "OXYToken::mint: '_serialNumber' has to be different than empty."
        );
        require(
            serialNumbersToToken[serialNumber] == 0,
            "OXYToken::mint: '_serialNumber' has already been used."
        );
        require(_amount > 0, "OXYToken::mint: Can't mint 0 oxy tokens");

        _mint(msg.sender, _tokenId, _amount, serialNumber);

        emit OxygenIssued(_tokenId, _amount, msg.sender);

        tokenToSerialNumber[_tokenId] = serialNumber;
        serialNumbersToToken[serialNumber] = _tokenId;
        tokenIdsToAmounts[_tokenId] = _amount;
    }

    /**
     * @dev Releases `_amount` tokens of token type `_id` from `_account`
     *
     * @param _account the account to release the OXY tokens from
     * @param _id the id of the project
     * @param _amount the amount of OXY tokens to release
     *
     * Requirements:
     *
     * - `_account` cannot be the zero address.
     * - `_account` must have at least `amount` tokens of token type `id`.
     */
    function release(
        address _account,
        uint256 _id,
        uint256 _amount
    ) public virtual {
        require(
            _account == _msgSender() ||
                isApprovedForAll(_account, _msgSender()),
            "OXYToken::release: Caller is not owner nor approved."
        );

        _burn(_account, _id, _amount);
    }

    /**
     * @dev Releases in batch x `_amounts` of x token type `_ids` from `_account`
     *
     * @param _account the account to release the OXY tokens from
     * @param _ids the ids of the project to release tokens from
     * @param _amounts the amounts of OXY tokens to release from each id
     *
     * Requirements:
     *
     * - `_account` cannot be the zero address.
     * - `_account` must have at least `amount` tokens of token type `id`.
     */
    function releaseBatch(
        address _account,
        uint256[] memory _ids,
        uint256[] memory _amounts
    ) public virtual {
        require(
            _account == _msgSender() ||
                isApprovedForAll(_account, _msgSender()),
            "OXYToken::releaseBatch: Caller is not owner nor approved."
        );

        _burnBatch(_account, _ids, _amounts);
    }

    function getTokensOfProject(uint256 _projectId)
        external
        view
        returns (uint256[] memory _ids)
    {
        return projectToTokenIds[_projectId];
    }
}
