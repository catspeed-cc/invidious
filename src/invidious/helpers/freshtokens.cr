class Invidious::FreshTokens
  
  def self.pot
    @@pot
  end
  
  def self.vdata
    @@vdata
  end  
  
  def initialize
    
    @@pot = "error"
    @@vdata = "error"
    
    get_tokens
    
    LOGGER.info("po_token: #{@@pot}")
    LOGGER.info("visitor_data: #{@@vdata}")
    
  end
  
  def self.get_tokens

    # get the tokens :)
    tokenData : String = `${HOME}/.nvm/versions/node/v20.18.0/bin/node submodules/youtube-po-token-generator/examples/one-shot.js`
    
    @@pot : String = `echo "#{@@tokenData}" | awk -F"'" '/visitorData/{print $4}'`
    @@vdata : String = `echo "#{@@tokenData}" | awk -F"'" '/visitorData/{print $2}'`

  end
  
end