//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.4;
import "hardhat/console.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Blog is Ownable {
  string public name; // blog name

  using Counters for Counters.Counter;
  Counters.Counter private _postIds;

  // Post attrs
  struct Post {
    uint256 id;
    string title;
    string content;
    bool published;
  }

  mapping(uint256 => Post) private idToPost;
  mapping(string => Post) private hashToPost;

  event CreatePost(uint256 id, string title, string hashCode);
  event UpdatePost(uint256 id, string title, string hashCode, bool published);

  /**
   * @dev Sets the values for {name} and owner is the msg.sender.
   *
   * Those values are immutable: they can only be set once during
   * construction.
   */
  constructor(string memory _name) {
    console.log("Deploying Blog with name:", _name);
    name = _name;
  }

  /**
   * @dev return new blog name
   */
  function updatePostName(string memory _name) public onlyOwner {
    name = _name;
  }

  /**
   * @dev fetch post by the conent hash
   */
  function fetchPost(string memory _hash) public view returns (Post memory) {
    return hashToPost[_hash];
  }

  /**
   * @dev create a new post
   */
  function createPost(string memory title, string memory hashCode)
    public
    onlyOwner
  {
    _postIds.increment();
    uint256 postId = _postIds.current();
    Post storage post = idToPost[postId];
    post.id = postId;
    post.title = title;
    post.published = true;
    post.content = hashCode;
    hashToPost[hashCode] = post;
    console.log("Created post with:", title, hashCode);
    emit CreatePost(postId, title, hashCode);
  }

  /**
   * @dev update an existing post
   */
  function updatePost(
    uint256 postId,
    string memory title,
    string memory hashCode,
    bool published
  ) public onlyOwner {
    Post storage post = idToPost[postId];
    post.title = title;
    post.published = published;
    post.content = hashCode;
    hashToPost[hashCode] = post;
    idToPost[postId] = post;

    console.log("Updated Post Blog with name:", post.id, title, hashCode);
    emit UpdatePost(post.id, title, hashCode, published);
  }

  /**
   * @dev fetch all post
   */
  function fetchPosts() public view returns (Post[] memory) {
    uint256 itemCount = _postIds.current(); // get total of posts
    uint256 currentIndex = 0;

    Post[] memory posts = new Post[](itemCount); // contain all of posts
    for (uint256 index = 0; index < itemCount; index++) {
      uint256 currentId = index + 1;
      Post storage currentItem = idToPost[currentId];
      posts[currentIndex] = currentItem;
      currentIndex += 1;
    }

    return posts;
  }
}
