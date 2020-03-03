//based https://github.com/0xcert/ethereum-erc721
//based https://github.com/Kaz-Naz/ERC721LT
//author https://github.com/Toshiya-Y-K-N

pragma solidity 0.6.2;

import "./nf-token.sol";//This sol file modified.(base is 0xcert's file.) 

import "./nf-token-metadata.sol";
import "./nf-token-enumerable.sol";
import "../ownership/ownable.sol";


contract MyERC721LT is
  NFTokenMetadata,
  Ownable
{
    //base32->str function シークレット変換用
    function bytes32ToString(bytes32 x) internal pure returns (string memory) {
           bytes memory bytesString = new bytes(32);
           uint charCount = 0;
           for (uint j = 0; j < 32; j++) {
               byte char = byte(bytes32(uint(x) * 2 ** (8 * j)));
               if (char != 0) {
                   bytesString[charCount] = char;
                   charCount++;
               }
           }
           bytes memory bytesStringTrimmed = new bytes(charCount);
           for (uint j = 0; j < charCount; j++) {
               bytesStringTrimmed[j] = bytesString[j];
           }
           return string(bytesStringTrimmed);
    }

    //secret
    bytes32 private _secret = 0x0000000000000000000000000000000000000000000000000000000000000b00;
    
    //CreatorNum blocknum
    uint256 private _creatorOneTimeNum = 20200300;


    //Creator data　作者の名前とウェブサイトやメールアドレス、ＳＮＳアカウント、電話番号などを記載する
    string private _creatorData = "作者:Toshiya Y(K.N) ; 管理サイト名:github.com/xxxx (有事の際はこのサイトでコントラクトの運用に関してアナウンスします)";
    //Site　招待するウェブサイトアドレス
    string private _creatorSiteAddress1 = "https://test.official.com/";//example
    
    //サイトに入場した回数を記録できるといい。tokenURI部分。tokenUri2
    mapping (uint256 => string) internal idToUri2;//second uri

    /**
    * @dev Write TokenURI2 a NFT from NFTowner (creator can`t rewrite URI2.)
    * @param _tokenId Which NFT  NFToner want to Write URI2.
    */  
    //ユーザーコメントURI2を設定
    //入力する_uri文字列は暗号化すると良い　暗号化ソフトhttps://freesoftlab.com/detail/tkey/download/
    function setTokenUri2(
    uint256 _tokenId,
    string calldata _uri
    )
    external
    onlyOwner
    validNFToken(_tokenId)
    {
    require(msg.sender != address(0), ZERO_ADDRESS);
    require(msg.sender == idToOwner[_tokenId]);
    require( _getOwnerNFTCount(msg.sender) > 0 );
    idToUri2[_tokenId] = _uri;
    }
    
    /**
    * @dev Read TokenURI2 a NFT . (All user watch this uri2.)
    * @param _tokenId <---- we want to read NFT URI2
    */
    function tokenURI2(
    uint256 _tokenId
    )
    external
    view
    validNFToken(_tokenId)
    returns (string memory)
    {
    return idToUri2[_tokenId];
    }


    //setCreatorOneTimeNum  public onlyOwner
    //手動でワンタイムパスワード（ＯＴＰ）を変えるの数値を入力できる関数。運営者のオーナーのみが関数を事項出来る
    //通常のワンタイムパスワードは時刻同期式だが、イーサレアムではブロックナンバーを用いてそれが実装できる。
    //ただし、各テストネット毎にブロックの更新間隔が違ったり、高速化されるなどを考えると、手動でも良いと思った次第である。
    //週に1度など更新出来ればいいし、毎分、毎時で更新する必要もないかもしれない。
    //ブロックナンバーのように常にインクリメントするわけでなく、大きい番号を指定された後、
    //小さい番号を指定したり、同じ番号を二回以上指定されることもある。
    /**
    * @dev setCreatorOneTimeNum(uint256 _newNum) public onlyOwner
    * @param uint256 _newNum  this num is like "blocknum"
    */
    function setCreatorOneTimeNum(uint256 _newNum) public onlyOwner {
        _creatorOneTimeNum  = _newNum ; 
    }
    
    //getOTP()　サイトそのもののOTPを表示させる。これはチケットを持つ人なら見ることができる。全員に同じ値を表示する。
    function getOTP() public view returns (bytes32) {
        require(msg.sender != address(0), ZERO_ADDRESS);
        
        //ファンサイト入場できるトークンを持っているか確認する
        require( _getOwnerNFTCount(msg.sender) > 0 );
        
        //条件通りならばクリエイターのセットしたパスワードをリターンする
        string memory str =  bytes32ToString(_secret) ;
        uint256 inte = _creatorOneTimeNum ;
        return sha256(abi.encodePacked(inte, str));
    }   
    
    //getYourOTP() それぞれの人が持つパスワードを表示させる。これはチケットを持つ人なら見ることができる。ウォレットアドレス毎に異なる値をとる。 
    function getYourOTP() public view returns (bytes32) {
        require(msg.sender != address(0), ZERO_ADDRESS);
        
        //ファンサイト入場できるトークンを持っているか確認する
        require( _getOwnerNFTCount(msg.sender) > 0 );
        
        //条件通りならばクリエイターのセットしたパスワードをリターンする
        string memory str =  bytes32ToString(_secret) ;
        uint256 inte = _creatorOneTimeNum ;
        address adr = msg.sender;
        return sha256(abi.encodePacked(inte, str,adr));
    }
    
    //address setter getter
    function setSiteAddress1(string memory _newAddress) public onlyOwner {
        _creatorSiteAddress1 = _newAddress ; 
    } 
    function getSiteAddress1() public view  returns (string memory) {
        require(msg.sender != address(0), ZERO_ADDRESS);
        require( _getOwnerNFTCount(msg.sender) > 0 );
        return _creatorSiteAddress1; 
    }

    function getCreatorData() public view onlyOwner returns (string memory) {
        return _creatorData; 
    }

    /**
    * @dev Contract constructor. Sets metadata extension `name` and `symbol`.
    */
    constructor()
    public
    {
        nftName = "SingulionLtTicket20200303-goe";
        nftSymbol = "SNTCKTLT0303";
    }
    
    
    /**
    * トランスファー関数の有効無効を決める真偽値　トランスファー関数は
    * @dev Removes a NFT from owner.
    * @param _newState 新しい転送許可の状態、trueでNFT送付可能、falseで転送不能。
    * 初期値はfalse.　通常、転送は許可されない。
    */    
    
    function setTransferPermission(bool _newState) 
    external
    onlyOwner
    {
        _setTransferPermission(_newState);
    }
    
    
    /**
    * 転売確認、秘密鍵流出、秘密鍵紛失時にNFTを強制的にリサイクルするためのburn関数 
    * @dev Removes a NFT from owner.
    * @param _tokenId Which NFT we want to remove.(burn)
    */
    function burn(
    uint256 _tokenId
    )
    external
    onlyOwner
    {
        super._burn(_tokenId);
    }
    
    
    /**
    * 任意の人のウォレットアドレスにNFTを発行する。トランスファー関数を使わない場合、唯一のNFT送付機構でもある。
    * @dev Mints a new NFT.
    * @param _to The address that will own the minted NFT.
    * @param _tokenId of the NFT to be minted by the msg.sender.
    * @param _uri String representing RFC 3986 URI.
    */
    function mint(
    address _to,
    uint256 _tokenId,
    string calldata _uri
    )
    external
    onlyOwner
    {
        super._mint(_to, _tokenId);
        super._setTokenUri(_tokenId, _uri);
    }
    
}





/* =========コメント=========


//nf-token.sol was modified. 
//以下のようにトランスファー関数部分に追加分を加えた。
//具体的には3つあるトランスファー関数にrequire(_transferPermission == true);を追記した。これでfalseのときはＮＦＴ送付を阻止できる。
    
    
  // can we transfer NFT ?   true is OK , false is NG .this varriable is changed by contract owner.
  bool private _transferPermission = false ; 
  
  //TransferPermission setter getter
  function getTransferPermission()public view  returns (bool) {
    return _transferPermission; 
  }
  function _setTransferPermission( bool _newState) internal {
    _transferPermission = _newState;
  }


  function safeTransferFrom(
    address _from,
    address _to,
    uint256 _tokenId,
    bytes calldata _data
  )
    external
    override
  {
    require(_transferPermission == true);//<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
    _safeTransferFrom(_from, _to, _tokenId, _data);
  }


  function safeTransferFrom(
    address _from,
    address _to,
    uint256 _tokenId
  )
    external
    override
  {
    require(_transferPermission == true);//<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
    _safeTransferFrom(_from, _to, _tokenId, "");
  }


  function transferFrom(
    address _from,
    address _to,
    uint256 _tokenId
  )
    external
    override
    canTransfer(_tokenId)
    validNFToken(_tokenId)
  {
    require(_transferPermission == true);//<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
    address tokenOwner = idToOwner[_tokenId];
    require(tokenOwner == _from, NOT_OWNER);
    require(_to != address(0), ZERO_ADDRESS);

    _transfer(_to, _tokenId);
  }
*/
