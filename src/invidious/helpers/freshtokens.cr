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
    
  end
  
  def self.get_tokens

    # get the tokens :)
    tokenData = `${HOME}/.nvm/versions/node/v20.18.0/bin/node submodules/youtube-po-token-generator/examples/one-shot.js`
    
    @@pot = `echo "#{tokenData}" | awk -F"'" '/poToken/{print $4}'`
    @@vdata = `echo "#{tokenData}" | awk -F"'" '/visitorData/{print $2}'`

  end
  
end