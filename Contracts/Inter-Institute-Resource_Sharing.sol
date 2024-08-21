// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ResourceSharing {

    struct Resource {
        string name;
        string description;
        address owner;
        bool isAvailable;
    }

    struct Request {
        address requester;
        uint256 resourceId;
        bool isFulfilled;
    }

    mapping(uint256 => Resource) public resources;
    mapping(uint256 => Request) public requests;

    uint256 public resourceCount;
    uint256 public requestCount;

    event ResourceRegistered(uint256 resourceId, string name, address owner);
    event ResourceRequested(uint256 requestId, uint256 resourceId, address requester);
    event ResourceShared(uint256 requestId, uint256 resourceId, address owner, address requester);

    function registerResource(string memory _name, string memory _description) public {
        resourceCount++;
        resources[resourceCount] = Resource(_name, _description, msg.sender, true);

        emit ResourceRegistered(resourceCount, _name, msg.sender);
    }

    function requestResource(uint256 _resourceId) public {
        require(_resourceId > 0 && _resourceId <= resourceCount, "Resource does not exist");
        require(resources[_resourceId].isAvailable, "Resource not available");

        requestCount++;
        requests[requestCount] = Request(msg.sender, _resourceId, false);

        emit ResourceRequested(requestCount, _resourceId, msg.sender);
    }

    function fulfillRequest(uint256 _requestId) public {
        require(_requestId > 0 && _requestId <= requestCount, "Request does not exist");
        Request storage req = requests[_requestId];
        Resource storage res = resources[req.resourceId];

        require(msg.sender == res.owner, "Only the owner can fulfill the request");
        require(req.isFulfilled == false, "Request already fulfilled");
        require(res.isAvailable, "Resource is not available");

        req.isFulfilled = true;
        res.isAvailable = false;

        emit ResourceShared(_requestId, req.resourceId, res.owner, req.requester);
    }

    function returnResource(uint256 _resourceId) public {
        require(_resourceId > 0 && _resourceId <= resourceCount, "Resource does not exist");
        Resource storage res = resources[_resourceId];

        require(msg.sender != res.owner, "Owner cannot return the resource");
        require(res.isAvailable == false, "Resource is already available");

        res.isAvailable = true;
    }
}