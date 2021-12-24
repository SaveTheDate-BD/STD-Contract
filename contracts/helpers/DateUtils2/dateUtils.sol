// // SPDX-License-Identifier: MIT
// pragma solidity ^0.8.0;
// library DateUtils {
//     function convertYMDtoDateString(uint16 _year,
//                                    uint8 _month,
//                                    uint8 _day)
//                                    internal pure
//                                    returns (string) {

//      strings.slice memory sHyphen = "-".toSlice();
//      strings.slice memory sZero = "0".toSlice();
//      strings.slice[] memory sYMD = YMDuintToBytes(_year, _month, _day);

//      for (uint8 i = 1; i < 3; i++) {

//        if (sYMD[i].len() == 1) {
//          sYMD[i] = sZero.concat(sYMD[i]).toSlice();
//        }
//      }

//      return sHyphen.join(sYMD);
//    }
// }
