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
    mapping(uint256 => mapping(bytes32 => bool)) public familyInvites; // familyID => hashed invite => valid

    constructor() public {
        owner = msg.sender;
    }

    event FamilyAdded(
        uint256 indexed id,
        string name,
        address indexed personAccount
    );
    event FamilyNameSet(address indexed account, string name);
    event PersonAdded(
        uint256 indexed id,
        address indexed account,
        string name,
        string avatar
    );
    event PersonNameSet(address indexed account, string name);
    event PersonAvatarSet(address indexed account, string avatar);
    event JoinedFamily(uint256 indexed familyID, address indexed account);
    event LeftFamily(uint256 indexed familyID, address indexed account);
    event InviteAdded(
        uint256 indexed familyID,
        address indexed account,
        bytes32 invite
    );
    event InviteRedeemed(
        uint256 indexed familyID,
        address indexed account,
        bytes32 invite
    );

    uint256 public constant RoleNone = 0;
    uint256 public constant RoleResponsibleAdult = 1;
    uint256 public constant RoleAdult = 2;
    uint256 public constant RoleChild = 3;

    /// @dev Start a new family. The msg.sender must already be registered as a person.
    /// @param familyName name of the family
    /// @return ID of the newly created family
    function startFamily(string memory familyName) public returns (uint256) {
        require(
            bytes(familyName).length > 0,
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

        emit JoinedFamily(family.id, msg.sender);

        return family.id;
    }

    /// @dev Update a family's name
    /// @param familyID family ID
    /// @param familyName new family name
    function setFamilyName(uint256 familyID, string memory familyName) public {
        require(
            bytes(familyName).length > 0,
            "name cannot be the empty string"
        );
        uint256 personID = getPersonIDByAccount(msg.sender);

        require(
            familyRoles[familyID][personID] == RoleResponsibleAdult,
            "not a responsible adult"
        );

        families[familyID].name = familyName;

        emit FamilyNameSet(msg.sender, familyName);
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
            bytes(personName).length > 0,
            "name cannot be the empty string"
        );
        require(bytes(avatar).length > 0, "avatar cannot be the empty string");
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

    /// @dev Update a person's name
    /// @param personName the person's new name
    function setPersonName(string memory personName) public {
        require(
            bytes(personName).length > 0,
            "name cannot be the empty string"
        );
        uint256 personID = getPersonIDByAccount(msg.sender);

        people[personID].name = personName;

        emit PersonNameSet(msg.sender, personName);
    }

    /// @dev Update a person's avatar
    /// @param avatar the person's avatar
    function setPersonAvatar(string memory avatar) public {
        require(bytes(avatar).length > 0, "name cannot be the empty string");
        uint256 personID = getPersonIDByAccount(msg.sender);

        people[personID].avatar = avatar;

        emit PersonAvatarSet(msg.sender, avatar);
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
        address personAccount,
        uint256 offset,
        uint256 limit
    ) public view returns (Family[] memory) {
        // note: this will not scale to production, but we're taking a shortcut for a hackathon
        uint256 personID = getPersonIDByAccount(personAccount);

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
    /// @param familyID family ID
    /// @param nonce random nonce generated off-chain
    /// @param role the role of the person
    /// @return hashed invite
    function generateInvite(
        uint256 familyID,
        string memory nonce,
        uint256 role
    ) public pure returns (bytes32) {
        return (keccak256(abi.encodePacked(familyID, nonce, role)));
    }

    /// @dev Adds an invite
    /// @param familyID family ID
    /// @param invite the hashed invite
    function addInvite(uint256 familyID, bytes32 invite) public {
        uint256 personID = getPersonIDByAccount(msg.sender);

        require(
            familyMembers[familyID][personID],
            "not a member of that family"
        );
        require(
            familyRoles[familyID][personID] == RoleResponsibleAdult,
            "not a responsible adult"
        );

        familyInvites[familyID][invite] = true;

        emit InviteAdded(familyID, msg.sender, invite);
    }

    /// @dev Join a family by invitation
    /// @param familyID family ID
    /// @param nonce random nonce generated off-chain
    /// @param role the role of the person
    function joinFamily(
        uint256 familyID,
        string memory nonce,
        uint256 role
    ) public {
        // note: this can be front-run in production, but we're taking a shortcut for a hackathon
        uint256 personID = getPersonIDByAccount(msg.sender);

        // validate invite
        bytes32 invite = generateInvite(familyID, nonce, role);
        require(familyInvites[familyID][invite], "invalid invite");

        // mark invite as used
        familyInvites[familyID][invite] = false;
        emit InviteRedeemed(familyID, msg.sender, invite);

        // add them to the family
        familyMembers[familyID][personID] = true;
        familyMembersCount[familyID]++;
        familyRoles[familyID][personID] = RoleResponsibleAdult;

        emit JoinedFamily(familyID, msg.sender);
    }

    /// @dev Join a family by invitation, and add the person
    /// @param familyID family ID
    /// @param nonce random nonce generated off-chain
    /// @param role the role of the person
    /// @param personName the person's name
    /// @param avatar the person's avatar
    /// @return ID of the newly created person
    function joinFirstFamily(
        uint256 familyID,
        string memory nonce,
        uint256 role,
        string memory personName,
        string memory avatar
    ) public returns (uint256) {
        // note: this can be front-run in production, but we're taking a shortcut for a hackathon
        uint256 personID = addPerson(personName, avatar);
        joinFamily(familyID, nonce, role);

        return personID;
    }

    /// @dev Remove a family member
    /// @param familyID family ID
    /// @param personID person ID to remove
    function removeFamilyMember(uint256 familyID, uint256 personID) public {
        uint256 senderPersonID = getPersonIDByAccount(msg.sender);

        require(
            familyMembers[familyID][personID],
            "not a member of that family"
        );
        require(
            familyRoles[familyID][personID] == RoleResponsibleAdult ||
                senderPersonID == personID,
            "not a responsible adult"
        );

        familyMembers[familyID][personID] = false;
        familyMembersCount[familyID]--;

        emit LeftFamily(familyID, msg.sender);
    }
}
