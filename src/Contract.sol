// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@chainlink/contracts/src/v0.8/VRFConsumerBase.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

abstract contract ReentrancyGuard {
    uint256 private locked = 1;

    modifier nonReentrant() {
        require(locked == 1, "REENTRANCY");

        locked = 2;

        _;

        locked = 1;
    }
}

contract Colony {
    // max approve PTShrohms contract to handle funds
    constructor(IERC20 token) {
        token.approve(msg.sender, type(uint256).max);
    }
}

contract PTShrohms is VRFConsumerBase, ReentrancyGuard {

    /* -------------------------------------------------------------------------- */
    /*                                DEPENDENCIES                                */
    /* -------------------------------------------------------------------------- */

    using SafeERC20 for IERC20;

    /* -------------------------------------------------------------------------- */
    /*                                  CONSTANTS                                 */
    /* -------------------------------------------------------------------------- */

    string constant UNAUTHORIZED = "UNAUTHORIZED";

    uint256 constant shrohmSupply = 1500; // todo make sure

    /* -------------------------------------------------------------------------- */
    /*                             STRUCTURED STORAGE                             */
    /* -------------------------------------------------------------------------- */

    struct Raffle {
        bytes32 requestId;                      // chainlink request id
        uint256 randomness;                     // chainlink provided randomness
        uint256 amount;                         // total raffle payout token distrobution
        uint256 length;                         // amount of winners
        mapping(uint256 => bool) hasClaimed;    // has an acocunt claimed their winnings
    }

    /// @notice Returns an array containing every raffle that's occured
    Raffle[] public raffles;

    /// @notice Maps drawing ids to their underlying colony
    mapping(uint256 => Colony) public drawToColony;


    /* -------------------------------------------------------------------------- */
    /*                                  CONSTANTS                                 */
    /* -------------------------------------------------------------------------- */

    uint256 public constant DIVISOR_BIPS = 10000;

    /* -------------------------------------------------------------------------- */
    /*                                   STORAGE                                  */
    /* -------------------------------------------------------------------------- */

    uint256 public length;

    /// @notice Returns minimum amount of time that must pass before another drawing
    uint256 public minEpochLength;

    /// @notice Returns last timestamp that a withdraw occured, crosschecked against "minEpochTime"
    /// to determine if enough time has passed before another draw can occur
    uint256 public lastWithdrawTime;

    /// @notice Returns amount of chainlink currently required per chainlink VRF request
    uint256 public chainlinkFee;

    /// @notice Returns keyhash used for Chainlink VRF
    bytes32 public chainlinkHash;

    /// @notice Returns account that has the power to modify epoch length, and chainlink params
    address public manager;

    /// @notice ERC721 tokens that can redeem winnings from raffles
    IERC721 public shrohms;

    /// @notice Token that Shrohm holders will receive as payment from raffles
    IERC20 public payoutToken;

    /// @notice Current allocation used to determine payout % for winners. In bips.
    /// @dev sum must not exceed 10_000 || 100%
    uint256[] public raffleAllocations;

    /* -------------------------------------------------------------------------- */
    /*                                   EVENTS                                   */
    /* -------------------------------------------------------------------------- */

    event Draw(address indexed caller);

    /* -------------------------------------------------------------------------- */
    /*                                  MODIFIERS                                 */
    /* -------------------------------------------------------------------------- */

    modifier onlyManager() {
        require(msg.sender == manager, UNAUTHORIZED);
        _;
    }

    modifier onlyWhenReady() {
        // make sure min amount of time has occured before allowing draw
        require(block.timestamp >= lastWithdrawTime + minEpochLength, UNAUTHORIZED);
        _;
    }

    /* -------------------------------------------------------------------------- */
    /*                                CONSTRUCTION                                */
    /* -------------------------------------------------------------------------- */

    constructor(
        IERC20 _payoutToken,
        IERC721 _shrohms,
        uint256 _minEpochLength,
        uint256 _chainlinkFee,
        bytes32 _chainlinkHash,
        address _vrfCoordinator,
        address _link,
        uint256 _length
    ) VRFConsumerBase(_vrfCoordinator, _link) {
        payoutToken = _payoutToken;
        shrohms = _shrohms;
        minEpochLength = _minEpochLength;
        // setup chainlink related state
        chainlinkFee = _chainlinkFee;
        chainlinkHash = _chainlinkHash;
        // set to now to check against later
        lastWithdrawTime = block.timestamp;
        length = _length;
    }

    /* -------------------------------------------------------------------------- */
    /*                               MANAGEMENT ONLY                              */
    /* -------------------------------------------------------------------------- */

    /// @notice set manager if manager
    /// @param _newManager address that manager will be set to
    function setManager(address _newManager) external onlyManager {
        manager = _newManager;
    }

    /// @notice set allocation for raffle payouts
    /// @param _newAllocations new raffle allocations
    function setAllocation(uint256[] memory _newAllocations) external onlyManager {
        // store total first, starts at 0
        uint256 total;

        // fetch sum of _newAllocations
        for (uint256 i; i < _newAllocations.length; i++) {
            total += _newAllocations[i];
        }

        // make sure sum of _newAllocations is equal to our representation of 100%
        require(total == DIVISOR_BIPS, "!INPUT");

        // update raffle allocations
        raffleAllocations = _newAllocations;
    }

    /// @notice set minimum amount of time that must elapse before another draw can occur
    function setMinEpochLength(uint256 _newLength) external onlyManager {
        minEpochLength = _newLength;
    }

    /// @notice set minimum amount of time that must pass before a draw can occur
    function setEpochLength(uint256 _minEpochLength) external onlyManager {
        minEpochLength = _minEpochLength;
    }

    /// @notice set chainlink fee
    function setChainlinkFee(uint256 _chainlinkFee) external onlyManager {
        chainlinkFee = _chainlinkFee;
    }

    /// @notice set chainlink hash
    function setChainlinkHash(bytes32 _chainlinkHash) external onlyManager {
        chainlinkHash = _chainlinkHash;
    }

    /// @notice pull unclaimed winnings from an old colony
    function refund(uint256 drawId) external onlyManager {
        payoutToken.safeTransferFrom(address(drawToColony[drawId]), manager, payoutToken.balanceOf(address(this)));
    }

    /* -------------------------------------------------------------------------- */
    /*                                   PUBLIC                                   */
    /* -------------------------------------------------------------------------- */

    /// @notice draw for winners if ready, callable by anyone
    function draw() external onlyWhenReady {
        requestRandomness(chainlinkHash, chainlinkFee);
        // create a colony where winning shrooms can collect their winnings
        Colony colony = new Colony(payoutToken);

        // fetch draw id, since arrays start at 0, raffles.length will suffice
        uint256 drawId = raffles.length;

        // map drawing to newly created colony
        drawToColony[drawId] = colony;

        // push and payout tokens to the new colony
        payoutToken.safeTransfer(address(colony), payoutToken.balanceOf(address(this)));

        // emit Draw event
        emit Draw(msg.sender);
    }

    /// @notice allows user to claim winnings from colonies
    function claim(
        uint256[] memory tokenIds,
        uint256 drawId
    ) external nonReentrant returns (uint256 totalWinnings) {
        // fetch raffle storage
        Raffle storage raffle = raffles[drawId];

        // while i < tokenIdslength, check token ids for winnings
        for (uint256 i; i < tokenIds.length; i++) {

            // make sure sender, owns the token they're trying to claim for
            require(shrohms.ownerOf(tokenIds[i]) == msg.sender, "!OWNER");

            // determine if token is winner, and relevant winnings
            (bool winner, uint256 winnings) = checkForWinner(tokenIds[i], drawId);

            // make sure the token is a winner
            require(winner, "!WINNER");

            // make sure the token hasn't already been claimed for this raffle
            require(!raffle.hasClaimed[tokenIds[i]], "!CLAIMED");

            // set the token as claimed
            raffle.hasClaimed[tokenIds[i]] = true;

            // increase total winnings, by winnings
            totalWinnings += raffle.amount * winnings / DIVISOR_BIPS;
        }

        // push users payout
        payoutToken.safeTransferFrom(address(drawToColony[drawId]), msg.sender, totalWinnings);
    }

    /* -------------------------------------------------------------------------- */
    /*                                  INTERNAL                                  */
    /* -------------------------------------------------------------------------- */

    /// @notice calculates up to 10 winners, from a single chainlink randomness seed
    function calculateWinners(
        uint256 randomness, 
        uint256 length
    ) internal pure returns (uint256[10] memory winners) {
        // make sure length doesn't not surpass max winners
        require(length <= 10, "!LENGTH");
        // update randomness for each winning slot
        for (uint256 i; i < length; i++) {
            winners[i] = uint256(keccak256(abi.encode(randomness))) % shrohmSupply + 1;
            randomness = uint256(keccak256(abi.encode(randomness))) % shrohmSupply + 1;
        }
    }

    /// @notice returns whether a token won, as well as their winning share
    function checkForWinner(
        uint256 tokenId,
        uint256 drawId
    ) internal view returns (bool winner, uint256 amount) {
        // Determine winners from chainlink seed
        uint256[10] memory winners = calculateWinners(raffles[drawId].randomness, raffles[drawId].length);
        // return if "tokenId" is a winner
        for (uint256 i; i < winners.length; i++) {
            if (winners[i] == tokenId) return (true, raffleAllocations[i]);
        }
    }

    /// @notice Chainlink callback hook
    function fulfillRandomness(
        bytes32 requestId,
        uint256 randomness
    ) internal virtual override {
        Raffle storage raffle = raffles[raffles.length];
        raffle.requestId = requestId;
        raffle.randomness = randomness;
    }
}
