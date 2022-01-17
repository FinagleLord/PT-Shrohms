// SPDX-License-Identifier: Unlicense
pragma solidity 0.8.10;

import "ds-test/test.sol";
import "./utils/VM.sol";
import "../Contract.sol";

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract SampleERC20 is ERC20("SS","SS") {

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


    address[] players = [
        address(100),
        address(101),
        address(102),
        address(103),
        address(104),
        address(105),
        address(106),
        address(107),
        address(108),
        address(109),
        address(110),
        address(111),
        address(112),
        address(113),
        address(114),
        address(115),
        address(116),
        address(117),
        address(118),
        address(119)
    ];

    Vm vm = Vm(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);
    PTShrohms pts;

    SampleERC20 serc20;
    SampleERC721 serc721;

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

        serc20 = new SampleERC20();
        serc721 = new SampleERC721();

        payoutToken = new SampleERC20();

        IERC20 _payoutToken = IERC20(address(serc20));
        IERC721 _shrohms = IERC721(address(serc721));
        uint256 _minEpochLength = 0;
        uint256 _chainlinkFee = 2 ether;
        bytes32 _chainlinkHash = 0xAA77729D3466CA35AE8D28B3BBAC7CC36A5031EFDC430821C02BC31A238AF445;
        address _vrfCoordinator = 0xf0d54349aDdcf704F77AE15b96510dEA15cb7952;
        address _link = LINK_ADDRESS;
        uint256 _length = 10;

        mintNFTToPlayers();

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

        

        // transfer/mint payout tokens in (mimicking wut treasury will be doing)

        // call draw()

        // check wut nfts won the raffle, and make sure sum of winnings is = or less than
        // raffle "amount"

        //  make sure user cannot claim twice

        transferLink(address(this),100e18);
        require(IERC20(LINK_ADDRESS).balanceOf(address(this)) == 100e18);

        assertTrue(true);
    }

    /* ---------------------------------------------------------------------- */
    /*                                HELPERS                                 */
    /* ---------------------------------------------------------------------- */


    function transferLink(address to, uint256 amount) public {
        vm.startPrank(LINK_WHALE);
        IERC20(LINK_ADDRESS).transfer(to,amount);
        vm.stopPrank();
    }

    function mintNFTToPlayers() public {
        for (uint256 i; i < players.length; i++) {
            serc721.mint(players[i],i+1);
        }
    }


    function test_story() public {
        
    }

    
    // function test_setAllocation() public {
    //     uint256[] memory _newAllocations = [];
    //     pts.setAllocation(_newAllocations);
    // }
}
