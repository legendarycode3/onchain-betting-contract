// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import {Test, console} from "forge-std/Test.sol";
import {OnchainBetting} from "../src/OnchainBetting.sol";


contract OnchainBettingTest is Test {

    /*//////////////////////////////////////////////////////////////
                            STATE VARIABLES 
    //////////////////////////////////////////////////////////////*/
    OnchainBetting public  onchainbetting;

    /// @notice Generating deterministic addresses
    address public player1 = makeAddr("player1");
    address public player2 = makeAddr("player2");
    address public arbiter = makeAddr("arbiter");
    address public hacker = makeAddr("hacker");

    uint256 public constant BET_AMOUNT = 10 ether;



    /*//////////////////////////////////////////////////////////////
                            EVENTS
    //////////////////////////////////////////////////////////////*/
    event Staked(address indexed player, uint256 amount);
    event BetResolved(address indexed winner, uint256 payout);
    event Refunded(address indexed player, uint256 amount);
    error Bet__AlreadyResolved();

    
    
    /*//////////////////////////////////////////////////////////////
                            FUNCTIONS 
    //////////////////////////////////////////////////////////////*/
    // Custom errors matched from the contract
    error Invalid__AddressProvided();
    error Players__AddressesCannotBeSame();
    error NotAuthorized__OnlyParticipantsAllowed();
    error Incorrect__StakeBetAmount(uint256 sent, uint256 required);
    error Player__AlreadyStaked();
    error Bets__NotFullyStaked();
    error Only__ArbiterAllowed();
    error NoStake__ToRefund();



    /*//////////////////////////////////////////////////////////////
                            FUNCTIONS 
    //////////////////////////////////////////////////////////////*/
    function setUp() public {
        
        // Gives players enough ETH to place their bets
        vm.deal(player1, 50 ether);
        vm.deal(player2, 50 ether);
        vm.deal(hacker, 50 ether);

        // Deploy contract
        onchainbetting = new OnchainBetting(
            player1, 
            player2, 
            BET_AMOUNT, 
            arbiter
        );
    }



    /*//////////////////////////////////////////////////////////////
                               CONSTRUCTOR TEST
    //////////////////////////////////////////////////////////////*/
    function testConstructorSetsValuesCorrectly() public view  {
        assertEq(onchainbetting.i_player1(), player1);
        assertEq(onchainbetting.i_player2(), player2);
        assertEq(onchainbetting.i_arbiter(), arbiter);
        assertEq(onchainbetting.i_betAmount(), BET_AMOUNT);

        assertEq(
            uint256(onchainbetting.s_betStatus()),
            uint256(OnchainBetting.BetStatus.Pending)
        );
    }


    function testConstructorRevertsOnZeroAddress() public {
        vm.expectRevert(Invalid__AddressProvided.selector);

        new OnchainBetting(address(0), player2, BET_AMOUNT, arbiter);
    }


    function testConstructorRevertsIfPlayersSame() public {
        vm.expectRevert(Players__AddressesCannotBeSame.selector);
        
        new OnchainBetting(player1, player1, BET_AMOUNT, arbiter);
    }
    


    /*//////////////////////////////////////////////////////////////
                               STAKING(BET) TEST
    //////////////////////////////////////////////////////////////*/
     function testStakingLocksBetStatus() public {
        vm.prank(player1);
        onchainbetting.stakeBetToken{value: BET_AMOUNT}();

        vm.prank(player2);
        onchainbetting.stakeBetToken{value: BET_AMOUNT}();

        assertEq(uint256(
            onchainbetting.s_betStatus()), 
            uint256(OnchainBetting.BetStatus.Locked)
        );
    }


    function testStakingRevertsIfNotParticipant() public {
        vm.prank(hacker);

        vm.expectRevert(NotAuthorized__OnlyParticipantsAllowed.selector);

        onchainbetting.stakeBetToken{value: BET_AMOUNT}();
    }


    function testStakingRevertsIfIncorrectAmount() public {
        vm.prank(player1);
        vm.expectRevert(abi.encodeWithSelector(Incorrect__StakeBetAmount.selector, 5 ether, BET_AMOUNT));
        onchainbetting.stakeBetToken{value: 5 ether}();
    }


    function testStakingRevertsIfAlreadyStaked() public {
        vm.prank(player1);
        onchainbetting.stakeBetToken{value: BET_AMOUNT}();

        vm.prank(player1);
        vm.expectRevert(Player__AlreadyStaked.selector);

        onchainbetting.stakeBetToken{value: BET_AMOUNT}();
    }


    function testPlayer1CanStake() public {
        vm.prank(player1);

        onchainbetting.stakeBetToken{value: BET_AMOUNT}();

        assertEq(onchainbetting.s_playerHasStaked(player1), true);

        assertEq(onchainbetting.s_totalPot(), BET_AMOUNT);
    }


    function testPlayer2CanStake() public {
        vm.prank(player2);

        onchainbetting.stakeBetToken{value: BET_AMOUNT}();

        assertEq(true, onchainbetting.s_playerHasStaked(player2));
    }


    function testEmitStakeEvent() public {
        vm.expectEmit(true, false, false, true);

        emit Staked(player1, BET_AMOUNT);

        vm.prank(player1);
        onchainbetting.stakeBetToken{value: BET_AMOUNT}();
    }


    function testRevertIfWrongStakeAmount() public {
        vm.prank(player1);

        vm.expectRevert(
            abi.encodeWithSelector(
                OnchainBetting.Incorrect__StakeBetAmount.selector,
                0.5 ether,
                BET_AMOUNT
            )
        );

        onchainbetting.stakeBetToken{value: 0.5 ether}();
    }


    function testRevertIfPlayerStakesTwice() public {
        vm.prank(player1);
        onchainbetting.stakeBetToken{value: BET_AMOUNT}();

        vm.expectRevert(
            OnchainBetting.Player__AlreadyStaked.selector
        );

        vm.prank(player1);
        onchainbetting.stakeBetToken{value: BET_AMOUNT}();
    }


    function testNonParticipantCannotStake() public {
        vm.prank(hacker);

        vm.expectRevert(
            OnchainBetting.NotAuthorized__OnlyParticipantsAllowed.selector
        );

        onchainbetting.stakeBetToken{value: BET_AMOUNT}();
    }


    function testBetLocksAfterBothPlayersStake() public {
        vm.prank(player1);
        onchainbetting.stakeBetToken{value: BET_AMOUNT}();

        vm.prank(player2);
        onchainbetting.stakeBetToken{value: BET_AMOUNT}();

        assertEq(
            uint256(onchainbetting.s_betStatus()),
            uint256(OnchainBetting.BetStatus.Locked)
        );

        assertEq(onchainbetting.s_totalPot(), 20 ether);
    }



    /*//////////////////////////////////////////////////////////////
                               RESOLVE-BET & PAYOUT TEST
    //////////////////////////////////////////////////////////////*/
      function testArbiterCanResolveAndPayout() public {
        vm.prank(player1);
        onchainbetting.stakeBetToken{value: BET_AMOUNT}();

        vm.prank(player2);
        onchainbetting.stakeBetToken{value: BET_AMOUNT}();

        uint256 preBalance = player1.balance;

        vm.prank(arbiter);
        onchainbetting.resolveBetAndPayout(payable(player1));

        assertEq(player1.balance, preBalance + (BET_AMOUNT * 2));
        assertEq(uint256(onchainbetting.s_betStatus()), uint256(OnchainBetting.BetStatus.Claimed));
    }


    function testResolveRevertsIfCalledByNonArbiter() public {
        vm.prank(player1);
        vm.expectRevert(Only__ArbiterAllowed.selector);
        onchainbetting.resolveBetAndPayout(payable(player1));
    }


    function testResolveRevertsIfNotFullyStaked() public {
        vm.prank(player1);
        onchainbetting.stakeBetToken{value: BET_AMOUNT}();

        vm.prank(arbiter);
        vm.expectRevert(Bets__NotFullyStaked.selector);
        onchainbetting.resolveBetAndPayout(payable(player1));
    }


    function testResolveRevertsWhenNotLocked() public {
        vm.prank(arbiter);

        vm.expectRevert(
            OnchainBetting.Bets__NotFullyStaked.selector
        );

        onchainbetting.resolveBetAndPayout(payable(player1));
    }



    /*//////////////////////////////////////////////////////////////
                               REFUND TEST
    //////////////////////////////////////////////////////////////*/
    function testParticipantsCanRefundBeforeLock() public {
        vm.prank(player1);
        onchainbetting.stakeBetToken{value: BET_AMOUNT}();

        uint256 preBalance = player1.balance;

        vm.prank(player1);
        onchainbetting.refund();

        assertEq(player1.balance, preBalance + BET_AMOUNT);
        assertEq(uint256(onchainbetting.s_betStatus()), uint256(OnchainBetting.BetStatus.Canceled));
    }


    function testRefundRevertsIfNoStake() public {
        vm.prank(player1);
        vm.expectRevert(NoStake__ToRefund.selector);
        onchainbetting.refund();
    }



    function testPlayerCanRefund() public {
        vm.prank(player1);
        onchainbetting.stakeBetToken{value: BET_AMOUNT}();

        uint256 balanceBeforeRefund = player1.balance;

        vm.expectEmit(true, false, false, true);
        emit Refunded(player1, BET_AMOUNT);

        vm.prank(player1);
        onchainbetting.refund();

        assertEq(
            player1.balance,
            balanceBeforeRefund + BET_AMOUNT
        );

        assertEq(
            uint256(onchainbetting.s_betStatus()),
            uint256(OnchainBetting.BetStatus.Canceled)
        );
    }


    function testNonParticipantCannotRefund() public {
        vm.prank(hacker);

        vm.expectRevert(
            OnchainBetting.NotAuthorized__OnlyParticipantsAllowed.selector
        );

        onchainbetting.refund();
    }



    /*//////////////////////////////////////////////////////////////
                        BALANCE ACCOUNTING TEST
    //////////////////////////////////////////////////////////////*/

    function testTotalPotUpdatesCorrectly() public {
        vm.prank(player1);
        onchainbetting.stakeBetToken{value: 10 ether}();

        assertEq(onchainbetting.s_totalPot(), 10 ether);

        vm.prank(player2);
        onchainbetting.stakeBetToken{value: 10 ether}();

        assertEq(onchainbetting.s_totalPot(), 20 ether);
    }



}
