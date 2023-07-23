//SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract PetPark {
    enum AnimalType {
        None,
        Fish,
        Cat,
        Dog,
        Rabbit,
        Parrot
    }

    enum Gender {
        Male,
        Female
    }

    struct Info {
        uint256 age;
        Gender gender;
    }

    address owner;
    mapping(AnimalType => uint256) public animals;
    mapping(address => AnimalType) public borrowData;
    mapping(address => Info) public users;

    event Added(AnimalType animalType, uint256 count);
    event Borrowed(AnimalType animalType);
    event Returned(AnimalType animalType);

    modifier onlyOwner() {
        require(msg.sender == owner, "You are not owner");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function animalCounts(AnimalType animalType) external returns (uint256) {
        return animals[animalType];
    }

    function add(AnimalType animalType, uint256 count) external onlyOwner {
        require(animalType != AnimalType.None, "Invalid animal");
        animals[animalType] += count;
        emit Added(animalType, count);
    }

    function borrow(uint256 age, Gender gender, AnimalType animalType) public {
        require(age > 0, "Age must be larger than zero");
        require(animalType != AnimalType.None, "Invalid animal type");
        require(animals[animalType] > 0, "Selected animal not available");

        if (users[msg.sender].age == 0) {
            users[msg.sender].age = age;
            users[msg.sender].gender = gender;
        } else {
            require(users[msg.sender].age == age, "Invalid Age");
            require(users[msg.sender].gender == gender, "Invalid Gender");
            require(
                borrowData[msg.sender] == AnimalType.None,
                "Already adopted a pet"
            );
        }

        if (gender == Gender.Male) {
            require(
                (animalType == AnimalType.Fish) ||
                    (animalType == AnimalType.Dog),
                "Invalid animal for men"
            );
        } else {
            if (age < 40) {
                require(
                    animalType != AnimalType.Cat,
                    "Invalid animal for women under 40"
                );
            }
        }

        animals[animalType] -= 1;
        borrowData[msg.sender] = animalType;
        emit Borrowed(animalType);
    }

    function giveBackAnimal() public {
        require(borrowData[msg.sender] != AnimalType.None, "No borrowed pets");

        AnimalType animalType = borrowData[msg.sender];
        animals[animalType] += 1;
        borrowData[msg.sender] == AnimalType.None;
        emit Returned(animalType);
    }
}
