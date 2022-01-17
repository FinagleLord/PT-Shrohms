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

}

// mainet info
// LINK Token	0x514910771AF9Ca656af840dff83E8264EcF986CA
// VRF Coordinator	0xf0d54349aDdcf704F77AE15b96510dEA15cb7952
// Key Hash	0xAA77729D3466CA35AE8D28B3BBAC7CC36A5031EFDC430821C02BC31A238AF445
// Fee	2 LINK 

contract ContractTest is DSTest {

    Vm vm = Vm(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);
    PTShrohms pts;

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

        SampleERC20 serc20 = new SampleERC20();
        SampleERC721 serc721 = new SampleERC721();

        IERC20 _payoutToken = IERC20(address(serc20));
        IERC721 _shrohms = IERC721(address(serc721));
        uint256 _minEpochLength = 0;
        uint256 _chainlinkFee = 2 ether;
        bytes32 _chainlinkHash = 0xAA77729D3466CA35AE8D28B3BBAC7CC36A5031EFDC430821C02BC31A238AF445;
        address _vrfCoordinator = 0xf0d54349aDdcf704F77AE15b96510dEA15cb7952;
        address _link = 0x514910771AF9Ca656af840dff83E8264EcF986CA;
        uint256 _length = 0;

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
}
