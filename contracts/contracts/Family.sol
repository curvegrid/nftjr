// SPDX-License-Identifier: MIT

pragma solidity ^0.6.0;

pragma experimental ABIEncoderV2;

contract Families {
    address public owner;

    struct Family {
        uint256 id;
        string name;
    }

    Family[] public families;
    mapping(string => uint256) public nameToFamily; // familyName => familyID

    struct Person {
        uint256 id;
        address account;
        string name;
        string avatar;
        uint256 role; // only sometimes filled in
    }

    Person[] public people;
    mapping(address => uint256) public accountToPerson; // account => personID

    // note: this is not the way to do this for production, but we're taking a shortcut for a hackathon
    mapping(uint256 => mapping(uint256 => bool)) public familyMembers; // familyID => personID => valid
    mapping(uint256 => uint256) public familyMembersCount; // familyID => person count
    mapping(uint256 => mapping(uint256 => uint256)) public familyRoles; // familyID => personID => role

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

	uint256 public constant RoleNone = 0;
    uint256 public constant RoleResponsibleAdult = 1;
    uint256 public constant RoleAdult = 2;
    uint256 public constant RoleChild = 3;

    /// @dev Start a new family. The msg.sender must already be registered as a person.
    /// @param familyName name of the family
    /// @return ID of the newly created family
    function startFamily(string memory familyName) public returns (uint256) {
        require(
            !stringsEqual(familyName, ""),
            "name cannot be the empty string"
        );

        Family memory family = Family({id: families.length, name: familyName});

        families.push(family);
        nameToFamily[familyName] = family.id;

        emit FamilyAdded(family.id, familyName, msg.sender);

        // add this person to the family
        uint256 personID = getPersonIDByAccount(msg.sender);

        familyMembers[family.id][personID] = true;
        familyMembersCount[family.id]++;
        familyRoles[family.id][personID] = RoleResponsibleAdult;

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
            id < people.length &&
                people.length > 0 &&
                people[id].account == account,
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
        require(
            people.length == 0 ||
                people[accountToPerson[msg.sender]].account != msg.sender,
            "account is already registered to a person"
        );

        Person memory person =
            Person({
                id: people.length,
                account: msg.sender,
                name: personName,
                avatar: avatar,
				role: RoleNone
            });

        people.push(person);
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

    /// @dev Retrieve families
    /// @param offset offset to return from
    /// @param limit maximum number to return
    /// @return families
    function getFamilies(uint256 offset, uint256 limit)
        public
        view
        returns (Family[] memory)
    {
        // note: this will not scale to production, but we're taking a shortcut for a hackathon
        if (offset > families.length) {
            limit = 0;
        } else if (offset + limit > families.length) {
            limit = families.length - offset;
        }

        Family[] memory selectFamilies = new Family[](limit);

        for (uint256 i = offset; i - offset < limit; i++) {
            selectFamilies[i - offset] = families[i];
        }
    }

    /// @dev Retrieve people
    /// @param offset offset to return from
    /// @param limit maximum number to return
    /// @return people
    function getPeople(uint256 offset, uint256 limit)
        public
        view
        returns (Person[] memory)
    {
        // note: this will not scale to production, but we're taking a shortcut for a hackathon
        if (offset > people.length) {
            limit = 0;
        } else if (offset + limit > people.length) {
            limit = people.length - offset;
        }

        Person[] memory selectPeople = new Person[](limit);

        for (uint256 i = offset; i - offset < limit; i++) {
            selectPeople[i - offset] = people[i];
        }
    }

    /// @dev Retrieve family members
    /// @param offset offset to return from
    /// @param limit maximum number to return
    /// @return people
    function getFamilyMembers(
        uint256 familyID,
        uint256 offset,
        uint256 limit
    ) public view returns (Person[] memory) {
        // note: this will not scale to production, but we're taking a shortcut for a hackathon
        require(familyID < families.length, "invalid family ID");

        // count forward by 'offset' matching people
        uint256 start = 0;
        uint256 count = 0;
        for (uint256 i = 0; count < offset && i < people.length; i++) {
            if (familyMembers[familyID][i]) {
                start = i + 1;
                count++;
            }
        }

        // count the number of matching people
        count = 0;
        for (uint256 i = start; count < limit && i < people.length; i++) {
            if (familyMembers[familyID][i]) {
                count++;
            }
        }

        Person[] memory selectPeople = new Person[](count);

        uint256 j = 0;
        for (uint256 i = start; j < count && i < people.length; i++) {
            if (familyMembers[familyID][i]) {
                selectPeople[j] = people[i];
                selectPeople[j].role = familyRoles[familyID][i];
                j++;
            }
        }

        return selectPeople;
    }

    /// @dev Retrieve the families a person is a part of
    /// @param offset offset to return from
    /// @param limit maximum number to return
    /// @return families
    function getFamilyMemberships(
        uint256 personID,
        uint256 offset,
        uint256 limit
    ) public view returns (Family[] memory) {
        // note: this will not scale to production, but we're taking a shortcut for a hackathon
        require(personID < people.length, "invalid person ID");

        // count forward by 'offset' matching families
        uint256 start = 0;
        uint256 count = 0;
        for (uint256 i = 0; count < offset && i < families.length; i++) {
            if (familyMembers[i][personID]) {
                start = i + 1;
                count++;
            }
        }

        // count the number of matching families
        count = 0;
        for (uint256 i = start; count < limit && i < families.length; i++) {
            if (familyMembers[i][personID]) {
                count++;
            }
        }

        Family[] memory selectFamilies = new Family[](count);

        uint256 j = 0;
        for (uint256 i = start; j < count && i < families.length; i++) {
            if (familyMembers[i][personID]) {
                selectFamilies[j] = families[i];
                j++;
            }
        }

        return selectFamilies;
    }

    /// @dev Generates an invite
    /// @param nonce random nonce generated off-chain
    /// @param role the role of the person
    /// @return hashed invite
    function generateInvite(
        uint256 familyID,
        address personAccount,
        string memory nonce,
        uint256 role
    ) public view returns (bytes32) {
        // note: this can be front-run in production, but we're taking a shortcut for a hackathon
        uint256 personID = getPersonIDByAccount(personAccount);

        require(
            familyMembers[familyID][personID],
            "account is not part of that family"
        );

        return (
            keccak256(abi.encodePacked(familyID, personAccount, nonce, role))
        );
    }

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
