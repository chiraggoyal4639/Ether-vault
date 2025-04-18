// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {MockV3Aggregator} from "../test/mocks/MockV3Aggregator.sol";
import {HelperConfig} from "../script/HelperConfig.s.sol";

contract PriceConverter {
    HelperConfig helperConfig = new HelperConfig();
    address priceFeedAddress = helperConfig.run();

    function getPrice() internal view returns (uint128) {
        MockV3Aggregator s_priceFeed = MockV3Aggregator(priceFeedAddress);
        (, int128 ETHprice,,,) = s_priceFeed.latestRoundData();
        return uint128(ETHprice);
    }

    function getConversionRate(uint256 _amount) internal view returns (uint128) {
        uint128 price = getPrice();
        uint128 ETHtoUSD = uint128((_amount * price) / 1e26);
        return (ETHtoUSD);
    }

    function USDtoETH(uint256 _amount) public view returns (uint256) {
        uint256 price = getPrice();
        uint256 minETH = (_amount * 1e26) / price;
        return minETH;
    }
}
