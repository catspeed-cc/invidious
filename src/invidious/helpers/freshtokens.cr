class Invidious::FreshTokens
  
  @@freshpot = ""
  @@freshvdata = ""  
  
  def self.freshpot
    @@freshpot
  end
  
  def self.freshvdata
    @@freshvdata
  end  
  
  def initialize
    
    @@freshpot = "error"
    @@freshvdata = "error"
    
    get_tokens
    
  end
  
  def self.get_tokens

    # get the tokens :)
    tokendata = `${HOME}/.nvm/versions/node/v20.18.0/bin/node submodules/youtube-po-token-generator/examples/one-shot.js`
    
    #LOGGER.info("TOKENDATA1: #{tokendata}")
    @@freshpot = `echo "#{tokendata.strip}" | awk -F"'" '/poToken/{print $2}'`
    #LOGGER.info("TOKENDATA2: #{tokendata}")
    @@freshvdata = `echo "#{tokendata.strip}" | awk -F"'" '/visitorData/{print $2}'`

  end
  
end