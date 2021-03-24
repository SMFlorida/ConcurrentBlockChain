module SingleThreadedBlockChain where

import Data.ByteString.UTF8 (fromString, toString)
import qualified Crypto.Hash.SHA256     as SHA256
import qualified Data.ByteString.Base16 as Base16

data Block = Block { contents :: String
             , hash :: String
             , previousHash :: String
             , timeStamp :: String
             , nonce :: Maybe Int
             } deriving (Show)

genesisBlock :: String -> Block
genesisBlock time = Block contents hash previousHash time Nothing
                 where 
                     contents = "The Times 03/Jan/2009 Chancellor on brink of second bailout for banks"
                     hash = ""
                     previousHash = "000000000000000000000000000000000"

newBlockChain :: String -> Block
newBlockChain time = mineBlock (genesisBlock time) 0


hashBlock :: Block -> String
hashBlock (Block contents hash prevHash timeStamp _) = toString $ Base16.encode digest
    where ctx = SHA256.updates SHA256.init $ fmap fromString [contents, prevHash, timeStamp]
          digest = SHA256.finalize ctx 

mineBlock :: Block -> Int -> Block
mineBlock b@(Block c _ p t _) n = case head pow of
                                    '0' -> Block c blockHash p t (Just n)
                                    _   -> mineBlock b (n + 1)
    where blockHash = hashBlock b
          ctx = SHA256.updates SHA256.init (fmap fromString [blockHash, show n, p])
          pow = toString . Base16.encode $ SHA256.finalize ctx -- proof of work

getHash :: Block -> String
getHash (Block _ _ p _ _) = p

addBlock :: String -> String -> String -> Block
addBlock p newContent time = mineBlock (Block newContent "" p time Nothing) 0

makeBlockChain :: String -> [String] -> Int -> String -> [Block]
makeBlockChain p [] _ _= [];
makeBlockChain p story 0 time = [firstBlock] ++ makeBlockChain pHash story 1 time
                             where
                                 firstBlock = newBlockChain time
                                 pHash = getHash firstBlock
makeBlockChain p (s:story) n time = [newBlock] ++ (makeBlockChain pHash story (n+1) time)
                                 where  
                                    newBlock = addBlock p s time
                                    pHash = getHash newBlock
                    

