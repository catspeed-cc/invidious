class Invidious::FreshTokens

  def self.get_tokens

    # get the tokens :)
    tokendata = `${HOME}/.nvm/versions/node/v20.18.0/bin/node submodules/youtube-po-token-generator/examples/one-shot.js`
    
    freshpot = `echo "#{tokendata.strip}" | awk -F"'" '/poToken/{print $2}'`
    freshvdata = `echo "#{tokendata.strip}" | awk -F"'" '/visitorData/{print $2}'`
    
    freshpot = freshpot.strip
    freshvdata = freshvdata.strip
    
    return {freshpot, freshvdata}

  end
  
end