//author:Toshiya Y(K.N) ; https://github.com/Toshiya-Y-K-N
pragma solidity 0.6.2;

import "./nf-token.sol";//This sol file modified.(base file is 0xcert's file.) 

import "./nf-token-metadata.sol";
import "./nf-token-enumerable.sol";
import "../ownership/ownable.sol";


contract MyERC721LT is
  NFTokenMetadata,
  Ownable
{
    //Creator data　作者の名前とウェブサイトやメールアドレス、ＳＮＳアカウント、電話番号などを記載する。
    //(有事の際はこのサイトでコントラクトの運用に関してアナウンスする)
    //この作者名と管理サイト名は書き換え不可能である。
    //万一、オーナーが秘密鍵流出などでonlyOwner権限を無くしてもここに記入したサイトのアドレスの指示に従うように誘導すること。
    string private _creatorData = "作者:Toshiya Y(K.N) ; 管理サイト:https://github.com/Toshiya-Y-K-N";
    //Site　招待するウェブサイトアドレス
    string private _creatorSiteAddress1 = "https://test.official.com/";//example
    
    //get creator data
    function getCreatorData() public view onlyOwner returns (string memory) {
        return _creatorData; 
    }
    //address setter getter
    //サイトへのアドレスを示す。
    function setSiteAddress1(string memory _newAddress) public onlyOwner {
        _creatorSiteAddress1 = _newAddress ; 
    } 
    function getSiteAddress1() public view  returns (string memory) {
        require(msg.sender != address(0), ZERO_ADDRESS);
        require( _getOwnerNFTCount(msg.sender) > 0 );
        return _creatorSiteAddress1; 
    }
    
    
    
    
    //サイトに入場した回数をチケットNFTに記録できるといい。tokenUri2を新しく設定
    mapping (uint256 => string) internal idToUri2;//second uri
    /**
    * @dev Write TokenURI2 a NFT from NFTowner (creator can`t rewrite URI2.)
    * @param _tokenId Which NFT  <-----NFT owner want to Write URI2.
    */  
    //URI2を設定 運営者がウェブサイトに訪問したことを確認した場合などにデータを書き込み、継ぎ足していく。
    //入力する_uri文字列は暗号化すると良い
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

    /**
    * oneTimePassCode Section
    */ 
    //secret
    string private _secret = "toshiyaTestTicket03o3";//examle.
    //CreatorNum blocknum
    uint256 private _creatorOneTimeNum = 20200303;//example.
    
    //setCreatorOneTimeNum  public onlyOwner
    //手動でワンタイムパスワード（ＯＴＰ）を変えるの数値を入力できる関数。運営者のオーナーのみが関数を実行出来る。
    //通常のワンタイムパスワードは時刻同期式だが、イーサリアムではブロックナンバーを用いてそれが実装できる。
    //ただし、各テストネット毎にブロックの更新間隔が違ったり、高速化されるなどを考えると、”手動でも良い”と思う。
    //週に1度程度更新出来れば良く、毎分、毎時で更新する必要もないかもしれない。
    /**
    * @dev setCreatorOneTimeNum(uint256 _newNum) public onlyOwner
    */
    function setCreatorOneTimeNum(uint256 _newNum) public onlyOwner {
        _creatorOneTimeNum  = _newNum ; 
    }
    
    //getOTP()　サイトそのもののOTPを表示させる。
    //これはチケットを持つ人なら見ることができる。
    //全員に同じ値を表示する。
    function getOTP() public view returns (bytes32) {
        require(msg.sender != address(0), ZERO_ADDRESS);
        
        //ファンサイト入場できるトークンを持っているか確認する
        require( _getOwnerNFTCount(msg.sender) > 0 );
        
        //条件通りならばクリエイターのセットしたパスワードをリターンする
        string memory str = _secret ;
        uint256 inte = _creatorOneTimeNum ;
        string memory str2 = "str";
        
        return sha256(abi.encodePacked(inte, str ,str2));
    }   
    
    //getYourOTP() それぞれの人が持つパスワードを表示させる。
    //これはチケットを持つ人なら見ることができる。
    //ウォレットアドレス毎に異なる値をとる。 
    function getYourOTP() public view returns (bytes32) {
        require(msg.sender != address(0), ZERO_ADDRESS);
        
        //ファンサイト入場できるトークンを持っているか確認する
        require( _getOwnerNFTCount(msg.sender) > 0 );
        
        //条件通りならばクリエイターのセットしたパスワードをリターンする
        string memory str =  _secret ;
        uint256 inte = _creatorOneTimeNum ;
        address adr = msg.sender;
        
        return sha256(abi.encodePacked(inte, str,adr));
    }
    
    //既存の時刻同期式ワンタイムパスワード(TOTP)を取得する。
    //これはチケットを持つ人なら見ることができる。ウォレットアドレス毎に異なる値をとる。 
    function getYourTOTP() public view returns (bytes32) {
        require(msg.sender != address(0), ZERO_ADDRESS);
        require( _getOwnerNFTCount(msg.sender) > 0 );
        
        string memory str =  _secret ;
        uint256 inte = block.number ;
        address adr = msg.sender;
        
        return sha256(abi.encodePacked(inte, str,adr));
    } 

    /**
    * コンストラクタ
    * @dev Contract constructor. Sets metadata extension `name` and `symbol`.
    */
    constructor()
    public
    {
        nftName = "SingulionLtTicket20200303-goe";
        nftSymbol = "SNTCKTLT0303";
    }
    
////////トークン発行時に永久に転送許可しない場合は以下のsetTransferPermission()を削除してコンパイルしデプロイすること/////////

    //@@トランスファーが許可されるケース@@
    //例１．認証されたユーザー同士のウォレットでトークンの譲渡をすることは制限しない場合、トランスファー許可できる。
    //例２．チケットを使うサービス、例えば上映会やライブ等の開催後にチケットの有効期限が切れた後、
    //それを骨董品のように認証されたユーザー同士のウォレットで譲渡したい場合。（コンサートの数年後にこっそりファンに告知してとtrue化するなど）

    //見かけ上、ERC&21LTにはトランスファー関数があるものの、その実行はオーナー含め全員出来ない。
    //実行するにはオーナーが_setTransferPermissionをtrueしなければいけない。
    //以下にその実行するためのtrue値をセットする関数を記述する。    
    /**
    * トランスファー関数の有効無効を決める真偽値　トランスファー関数は初期設定では無効。
    * @dev Removes a NFT from owner.
    * @param _newState 新しい転送許可の状態、trueでNFT送付可能、falseで転送不能。
    * _setTransferPermissionの初期値はfalse.　通常、転送は許可されない。
    */    
    
    function setTransferPermission(bool _newState) 
    external
    onlyOwner
    {
        _setTransferPermission(_newState);
    }
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    
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
    * 任意の人のウォレットアドレスにNFTを発行する。トランスファー関数を使わない場合、唯一のNFT送付機構。
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

//based https://github.com/0xcert/ethereum-erc721
//based https://github.com/Kaz-Naz/ERC721LT
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
