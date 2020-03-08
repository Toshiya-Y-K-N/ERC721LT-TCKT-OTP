//based https://github.com/0xcert/ethereum-erc721
//
//Author NZRI_Kaz-Naz_https://github.com/Kaz-Naz,Toshiya Y_https://github.com/Toshiya-Y-K-N
//rinkeby 
//by 

pragma solidity 0.6.2;

import "./nf-token.sol";
import "./nf-token-metadata.sol";
import "./nf-token-enumerable.sol";
import "../ownership/ownable.sol";

/**
 * 
 * @dev This is an example contract implementation of NFToken with metadata extension.
 */
contract MyERC721LT2OPT is
  NFTokenMetadata,
  Ownable
{

  /**
   * @dev Contract constructor. Sets metadata extension `name` and `symbol`.
   */
  constructor()
    public
  {
    nftName = "ToshiyaTicket(ERC721LT2OTP-TKCT-Rin)";//example
    nftSymbol = "TYTCKT0307";
  }
    //Creator data
    string private _creatorData = "NZRI_Kaz-Naz_https://github.com/Kaz-Naz,Toshiya-Y_https://github.com/Toshiya-Y-K-N";
    function getCreatorData() public view onlyOwner returns (string memory) {
        return _creatorData; 
    }
    //Creator data　作者の名前とウェブサイトやメールアドレス、ＳＮＳアカウント、電話番号などを記載する。
    //(有事の際はこのサイトでコントラクトの運用に関してアナウンスする)
    //この作者名と管理サイト名は書き換え不可能である。
    //万一、オーナーが秘密鍵流出などでonlyOwner権限を無くしてもここに記入したサイトのアドレスの指示に従うように誘導すること。


    //Site　招待するウェブサイトアドレス
    string private _creatorSiteAddress1 = "https://we-can-not-[transfer]-this-nft/by-ty-and-kaz-naz";//example
    

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
    
    

    /**
    * oneTimePassCode Section
    */ 
    //secret
    string private _secret = "test";//examle.
    //CreatorNum blocknum
    uint256 private _creatorOneTimeNum = 1111;//example.
    
    //setCreatorOneTimeNum  public onlyOwner
    //手動でワンタイムパスワード（ＯＴＰ）を変えるの数値を入力できる関数。運営者のオーナーのみが関数を実行出来る。
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
    
    //既存の時刻同期式ワンタイムパスワード(TOTP)を取得する。デプロイされたネットワークのブロックナンバーのインクリメントで変わる。
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

  /**
   * @dev write data NFT URI2.
   * @param _tokenId of the NFT .
   * @param _uri String representing RFC 3986 URI.
   */   
  function writeTokenUri2(
    uint256 _tokenId,
    string calldata _uri
  )
    external
    onlyOwner
    validNFToken(_tokenId)
  {
    idToUri2[_tokenId] = _uri;
  }
    
}

    /**
     * 
     * This section enables transfer and approve function 
     * In japan , this section disabled. (if we want to use erc721LT as ticket.)
     */
        /*
        function setTransferPermission(bool _newState) 
            external
            onlyOwner
        {
            //_setTransferPermission(_newState);
        }
        */



