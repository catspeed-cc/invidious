module FreshTokens
  extend self
  
  @@po_token : String | Nil
  @@visitor_data : String | Nil
  
  def get_instance_tokens
  
    po_token = ""
    visitor_data = ""
    instance_id = CONFIG.freshtokens_instanceid
  
    po_token = REDIS_DB.get("invidious:inv_instance_#{instance_id}:po_token")
    visitor_data = REDIS_DB.get("invidious:inv_instance_#{instance_id}:visitor_data")
    
    # check if tokens empty, generate new ones, store in redis
    if (po_token.nil? || visitor_data.nil?)
    
      LOGGER.info("get_instance_tokens: instance #{instance_id} needs new tokens")
      po_token, visitor_data = generate_tokens_timeout
      
      # update redis with instance's tokens (1 minute expiry for now)
      REDIS_DB.set("invidious:inv_instance_#{instance_id}:po_token", po_token, 60)
      REDIS_DB.set("invidious:inv_instance_#{instance_id}:visitor_data", visitor_data, 60)
      
      LOGGER.info("get_instance_tokens: instance #{instance_id}: stored instance's tokens")

    else    
      LOGGER.info("get_instance_tokens: instance #{instance_id}: already has tokens")
    end
    
    LOGGER.info("get_instance_tokens: instance #{instance_id}: pot: #{po_token}")
    LOGGER.info("get_instance_tokens: instance #{instance_id}: vdata: #{visitor_data}")
    
    return {po_token, visitor_data}
  
  end
  
  def get_user_tokens(useremail : String)
  
    po_token = ""
    visitor_data = ""
  
    po_token = REDIS_DB.get("invidious:#{useremail}:po_token")
    visitor_data = REDIS_DB.get("invidious:#{useremail}:visitor_data")
    
    # check if tokens empty, generate new ones, store in redis
    if (po_token.nil? || visitor_data.nil?)
    
      LOGGER.info("get_user_tokens: user: #{useremail} needs new tokens")
      po_token, visitor_data = generate_tokens
      
      # update redis with user's tokens (1 hour expiry for now)
      REDIS_DB.set("invidious:#{useremail}:po_token", po_token, 1800)
      REDIS_DB.set("invidious:#{useremail}:visitor_data", visitor_data, 1800)
      
      LOGGER.info("get_user_tokens: user: #{useremail} stored user's tokens")

    else    
      LOGGER.info("get_user_tokens: user: #{useremail} already has tokens")
    end
    
    LOGGER.info("get_user_tokens: user: #{useremail} pot: #{po_token}")
    LOGGER.info("get_user_tokens: user: #{useremail} vdata: #{visitor_data}")
    
    return {po_token, visitor_data}
  
  end
  
  def get_anonymous_tokens
  
    po_token, visitor_data = generate_tokens
    
    LOGGER.info("get_user_tokens: anonymous: anonymous user needs new tokens")
    LOGGER.info("get_user_tokens: anonymous: pot: #{po_token}")
    LOGGER.info("get_user_tokens: anonymous: vdata: #{visitor_data}")
  
    return {po_token, visitor_data}  
  
  end

  def generate_tokens

    # get the tokens :)
    tokendata = `${HOME}/.nvm/versions/node/v20.18.0/bin/node submodules/youtube-po-token-generator/examples/one-shot.js`
    
    freshpot = `echo "#{tokendata.strip}" | awk -F"'" '/poToken/{print $2}'`
    freshvdata = `echo "#{tokendata.strip}" | awk -F"'" '/visitorData/{print $2}'`
    
    freshpot = freshpot.strip
    freshvdata = freshvdata.strip
    
    return {freshpot, freshvdata}

  end

  def generate_tokens_timeout

    # get the tokens :)
    tokendata = `/usr/bin/timeout -k 15 -s KILL 10 ${HOME}/.nvm/versions/node/v20.18.0/bin/node submodules/youtube-po-token-generator/examples/one-shot.js`
    
    freshpot = `echo "#{tokendata.strip}" | awk -F"'" '/poToken/{print $2}'`
    freshvdata = `echo "#{tokendata.strip}" | awk -F"'" '/visitorData/{print $2}'`
    
    freshpot = freshpot.strip
    freshvdata = freshvdata.strip
    
    return {freshpot, freshvdata}

  end
  
end