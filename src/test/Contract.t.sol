// SPDX-License-Identifier: Unlicense
pragma solidity 0.8.10;

import "ds-test/test.sol";
import "./utils/VM.sol";
import "../Contract.sol";

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract SampleERC20 is ERC20("SS","SS") {
    function mint(address to, uint256 amount) public {
        _mint(to,amount);
    }
}
contract SampleERC721 is ERC721("77","77") {
    function mint(address to, uint256 tokenId) public {
        _safeMint(to,tokenId);
    }
}

// MAINNET:
// LINK Token	    0x514910771AF9Ca656af840dff83E8264EcF986CA
// VRF Coordinator	0xf0d54349aDdcf704F77AE15b96510dEA15cb7952
// Key Hash	        0xAA77729D3466CA35AE8D28B3BBAC7CC36A5031EFDC430821C02BC31A238AF445
// Fee	            2 LINK      

// LINK Whale       0x98C63b7B319dFBDF3d811530F2ab9DfE4983Af9D

contract ContractTest is DSTest {

    address LINK_WHALE = 0x98C63b7B319dFBDF3d811530F2ab9DfE4983Af9D;
    address LINK_ADDRESS = 0x514910771AF9Ca656af840dff83E8264EcF986CA;

    uint256 NUMBER_OF_PLAYERS = 10;

    address[] players;
    //  = [
    //     // address(100),
    //     // address(101),
    //     // address(102),
    //     // address(103),
    //     // address(104),
    //     // address(105),
    //     // address(106),
    //     // address(107),
    //     // address(108),
    //     // address(109),
    //     // address(110),
    //     // address(111),
    //     // address(112),
    //     // address(113),
    //     // address(114),
    //     // address(115),
    //     // address(116),
    //     // address(117),
    //     // address(118),
    //     // address(119)
    // ];

    Vm vm = Vm(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);
    PTShrohms pts;

    SampleERC721 shrohms;
    SampleERC20 payoutToken;

    // function test_me_hard() public {
    //     vm.startPrank(address(0))
    //     pts.callMethod(5);
    //     vm.stopPrank();

    //     vm.warp();

    //     vm.roll();

    //     vm.expectRevert("!AMOUNT");
    //     pts.callMethod(5);
    // }

    function setUp() public {

        payoutToken = new SampleERC20();
        shrohms = new SampleERC721();

        payoutToken = new SampleERC20();

        IERC20 _payoutToken = IERC20(address(payoutToken));
        IERC721 _shrohms = IERC721(address(shrohms));
        uint256 _minEpochLength = 0;
        uint256 _chainlinkFee = 2 ether;
        bytes32 _chainlinkHash = 0xAA77729D3466CA35AE8D28B3BBAC7CC36A5031EFDC430821C02BC31A238AF445;
        address _vrfCoordinator = 0xf0d54349aDdcf704F77AE15b96510dEA15cb7952;
        address _link = LINK_ADDRESS;
        uint256 _length = 10;

        mintOneNFTToEachPlayer();

        // add link to deployed contracts

        pts = new PTShrohms(
            _payoutToken,
            _shrohms,
            _minEpochLength,
            _chainlinkFee,
            _chainlinkHash,
            _vrfCoordinator,
            _link,
            _length
        );
    }

    function testExample() public {
        assertTrue(true);
    }

    function test_drawing() public {

        // 1) user holds an NFT 
        // we setup 10 accounts each holding 1 nft
        // mintOneNFTToEachPlayer();

        // uint256 amount = 100e18;
        // 2) treasury deposits accrued funds and calls draw()
        // we fund the contract with Payout Tokens
        // payoutToken.mint(address(pts),amount);

        // pts.draw();

        

        // 3) treasury updates allocations, IE amount weight for each of the 10 winner
        // ie if there's 10 winners, each key in the array with length 10 is relating to its counterpart

        // uint256[] memory _newAllocations = [
        //     1000,
        //     1000,
        //     1000,
        //     1000,
        //     1000,
        //     1000,
        //     1000,
        //     1000,
        //     1000,
        //     1000
        // ];
        // pts.setAllocation(_newAllocations);
        

        // 4) drawing should decide 10 winners, eached with equal winnings

        // 5) make sure only winners can claim

        // 6) make sure only non claimed winners can claim

        // transferLink(address(this),100e18);
        // require(IERC20(LINK_ADDRESS).balanceOf(address(this)) == 100e18);

        assertTrue(true);
    }

    /* ---------------------------------------------------------------------- */
    /*                                HELPERS                                 */
    /* ---------------------------------------------------------------------- */

    function setPlayerList(uint256 ix) public {
        for (uint256 i; i < ix; i ++) {
            players[i] = address(bytes32(100+i));
        }
    }

    function transferLink(address to, uint256 amount) public {
        vm.startPrank(LINK_WHALE);
        IERC20(LINK_ADDRESS).transfer(to,amount);
        vm.stopPrank();
    }

    function mintOneNFTToEachPlayer() public {
        for (uint256 i; i < players.length; i++) {
            shrohms.mint(players[i],i+1);
            // require(serc721.ownerOf(i+1) == players[i]);
        }
    }

    function test_story() public {
        // 1) user holds an NFT
        // mintOneNFTToAllEachPlayer();

        // 2) 
    }

    
    // function test_setAllocation() public {
    //     uint256[] memory _newAllocations = [];
    //     pts.setAllocation(_newAllocations);
    // }
}
