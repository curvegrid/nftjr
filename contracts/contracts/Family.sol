// SPDX-License-Identifier: MIT

pragma solidity ^0.6.0;

contract Families {
    address public owner;

    struct Family {
        uint256 id;
        string name;
        bool valid;
    }

    Family[] public families;
    mapping(string => uint256) public nameToFamily; // familyName => familyID

    struct Person {
        uint256 id;
        address account;
        string name;
        string avatar;
        bool valid;
    }

    Person[] public people;
    mapping(string => uint256) public nameToPerson; // personName => personID
    mapping(address => uint256) public accountToPerson; // account => personID

    // note: this is not the way to do this for production, but we're taking a shortcut for a hackathon
    mapping(uint256 => uint256) public familyMembers; // familyID => personID
    mapping(uint256 => uint256) public personFamilies; // personID => familyID

    constructor() public {
        owner = msg.sender;
    }

    event FamilyAdded(
        uint256 indexed id,
        string name,
        address indexed personAccount
    );
    event PersonAdded(
        uint256 indexed id,
        address indexed account,
        string name,
        string avatar
    );
    event JoinedFamily(uint256 indexed familyID, uint256 indexed personID);

    /// @dev Start a new family. The msg.sender must already be registered as a person.
    /// @param familyName name of the family
    /// @return ID of the newly created family
    function startFamily(string memory familyName) public returns (uint256) {
        require(
            !stringsEqual(familyName, ""),
            "name cannot be the empty string"
        );
        require(
            !families[nameToFamily[familyName]].valid,
            "name already taken"
        );

        Family memory family =
            Family({id: families.length, name: familyName, valid: true});

        families.push(family);
        nameToFamily[familyName] = family.id;

        emit FamilyAdded(family.id, familyName, msg.sender);

        // add this person to the family
        uint256 personID = getPersonIDByAccount(msg.sender);

        familyMembers[family.id] = personID;
        personFamilies[personID] = family.id;

        emit JoinedFamily(family.id, personID);

        return family.id;
    }

    /// @dev Retrieve a person ID by their account
    /// @param account account address of the person
    /// @return person ID
    function getPersonIDByAccount(address account)
        public
        view
        returns (uint256)
    {
        uint256 id = accountToPerson[account];
        require(
            people[id].valid && people[id].account == account,
            "account is not registered to a person"
        );
        return id;
    }

    /// @dev Add a person
    /// @param personName the person's name
    /// @param avatar the person's avatar
    /// @return person ID
    function addPerson(string memory personName, string memory avatar)
        internal
        returns (uint256)
    {
        require(
            !stringsEqual(personName, ""),
            "name cannot be the empty string"
        );
        require(!people[nameToPerson[personName]].valid, "name already taken");
        require(
            !people[accountToPerson[msg.sender]].valid,
            "account is already registered to a person"
        );

        Person memory person =
            Person({
                id: people.length,
                account: msg.sender,
                name: personName,
                avatar: avatar,
                valid: true
            });

        people.push(person);
        nameToPerson[personName] = person.id;
        accountToPerson[msg.sender] = person.id;

        emit PersonAdded(person.id, person.account, personName, avatar);
    }

    /// @dev Start a new family. The msg.sender will also be registered as a person.
    /// @param familyName name of the family
    /// @param personName the person's name
    /// @param avatar the person's avatar
    /// @return IDs of the newly created family and person
    function startFirstFamily(
        string memory familyName,
        string memory personName,
        string memory avatar
    ) public returns (uint256, uint256) {
        uint256 personID = addPerson(personName, avatar);
        uint256 familyID = startFamily(familyName);

        return (familyID, personID);
    }

    /// @dev Retrieve a person ID by their account
    /// @param account account address of the person
    /// @return person ID
    function getPersonIDByAccount(address account)
        public
        view
        returns (uint256)
    {
        uint256 id = accountToPerson[account];
        require(
            people[id].valid && people[id].account == account,
            "account is not registered to a person"
        );
        return id;
    }

    // note: this will not scale to production, but we're taking a shortcut for a hackathon

    /// @dev Check if two strings are equal
    /// @param a first string
    /// @param b second string
    function stringsEqual(string memory a, string memory b)
        public
        pure
        returns (bool)
    {
        return (keccak256(abi.encodePacked((a))) ==
            keccak256(abi.encodePacked((b))));
    }
}
