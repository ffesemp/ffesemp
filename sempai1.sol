// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract SmartHome is Ownable {
    IERC20 public sempaiToken;
    uint256 public totalSupply;
    mapping(address => uint256) public energyConsumption;
    mapping(address => mapping(bytes32 => Device)) public userDevices;

    event EnergyConsumed(address indexed user, uint256 amount);
    event DeviceAdded(address indexed user, bytes32 deviceId, string deviceName);
    event DeviceStatusChanged(address indexed user, bytes32 deviceId, uint256 status);

    struct Device {
        string deviceName;
        uint256 status;
    }

    constructor(address _sempaiToken) {
        sempaiToken = IERC20(_sempaiToken);
        totalSupply = 1000000000 * 10 ** 18; // 1 milyar Sempai Token
    }

    function consumeEnergy(uint256 amount) external {
        require(amount > 0, "Amount must be greater than 0");
        require(energyConsumption[msg.sender] + amount <= totalSupply, "Exceeded total supply");

        energyConsumption[msg.sender] += amount;
        sempaiToken.transferFrom(msg.sender, address(this), amount);

        emit EnergyConsumed(msg.sender, amount);
    }

    function getEnergyConsumed(address user) external view returns (uint256) {
        return energyConsumption[user];
    }

    function addDevice(bytes32 deviceId, string memory deviceName, uint256 initialStatus) external {
        require(userDevices[msg.sender][deviceId].status == 0, "Device already exists");

        Device memory newDevice = Device(deviceName, initialStatus);
        userDevices[msg.sender][deviceId] = newDevice;

        emit DeviceAdded(msg.sender, deviceId, deviceName);
    }

    function updateDeviceStatus(bytes32 deviceId, uint256 newStatus) external {
        require(userDevices[msg.sender][deviceId].status != 0, "Device does not exist");

        userDevices[msg.sender][deviceId].status = newStatus;
        emit DeviceStatusChanged(msg.sender, deviceId, newStatus);
    }

    function getDeviceStatus(bytes32 deviceId) external view returns (uint256) {
        return userDevices[msg.sender][deviceId].status;
    }
}
