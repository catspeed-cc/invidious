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
    
      LOGGER.info("get_instance_tokens: #{CONFIG.freshtokens_instanceid}: needs new tokens")
      po_token, visitor_data = generate_tokens_timeout
      
      # update redis with instance's tokens (1 minute expiry for now)
      REDIS_DB.set("invidious:inv_instance_#{instance_id}:po_token", po_token, 90)
      REDIS_DB.set("invidious:inv_instance_#{instance_id}:visitor_data", visitor_data, 90)
      
      LOGGER.info("get_instance_tokens: #{CONFIG.freshtokens_instanceid}: stored instance's tokens")

    else    
      LOGGER.info("get_instance_tokens: #{CONFIG.freshtokens_instanceid}: already has tokens")
    end
    
    LOGGER.info("get_instance_tokens: #{CONFIG.freshtokens_instanceid}: pot: #{po_token}")
    LOGGER.info("get_instance_tokens: #{CONFIG.freshtokens_instanceid}: vdata: #{visitor_data}")
    
    return {po_token, visitor_data}
  
  end
  
  def get_user_tokens(useremail : String)
  
    po_token = ""
    visitor_data = ""
  
    po_token = REDIS_DB.get("invidious:#{useremail}:po_token")
    visitor_data = REDIS_DB.get("invidious:#{useremail}:visitor_data")
    
    # check if tokens empty, generate new ones, store in redis
    if (po_token.nil? || visitor_data.nil?)
    
      LOGGER.info("get_user_tokens: #{CONFIG.freshtokens_instanceid}: user: #{useremail} needs new tokens")
      po_token, visitor_data = generate_tokens
      
      # update redis with user's tokens (1 hour expiry for now)
      REDIS_DB.set("invidious:#{useremail}:po_token", po_token, 300)
      REDIS_DB.set("invidious:#{useremail}:visitor_data", visitor_data, 300)
      
      LOGGER.info("get_user_tokens: #{CONFIG.freshtokens_instanceid}: user: #{useremail} stored user's tokens")

    else    
      LOGGER.info("get_user_tokens: #{CONFIG.freshtokens_instanceid}: user: #{useremail} already has tokens")
    end
    
    LOGGER.info("get_user_tokens: #{CONFIG.freshtokens_instanceid}: user: #{useremail} pot: #{po_token}")
    LOGGER.info("get_user_tokens: #{CONFIG.freshtokens_instanceid}: user: #{useremail} vdata: #{visitor_data}")
    
    return {po_token, visitor_data}
  
  end
  
  def get_vid_tokens(video_id : String)
  
    po_token = ""
    visitor_data = ""
  
    po_token = REDIS_DB.get("invidious:VID_#{video_id}:po_token")
    visitor_data = REDIS_DB.get("invidious:VID_#{video_id}:visitor_data")
    
    # check if tokens empty, generate new ones, store in redis
    if (po_token.nil? || visitor_data.nil?)
    
      LOGGER.info("get_user_tokens: #{CONFIG.freshtokens_instanceid}: user: VID_#{video_id} needs new tokens")
      po_token, visitor_data = generate_tokens_timeout
      
      # update redis with user's tokens (1 hour expiry for now)
      REDIS_DB.set("invidious:VID_#{video_id}:po_token", po_token, 86400)
      REDIS_DB.set("invidious:VID_#{video_id}:visitor_data", visitor_data, 86400)
      
      LOGGER.info("get_user_tokens: #{CONFIG.freshtokens_instanceid}: user: VID_#{video_id} stored user's tokens")

    else    
      LOGGER.info("get_user_tokens: #{CONFIG.freshtokens_instanceid}: user: VID_#{video_id} already has tokens")
    end
    
    LOGGER.info("get_user_tokens: #{CONFIG.freshtokens_instanceid}: user: VID_#{video_id} pot: #{po_token}")
    LOGGER.info("get_user_tokens: #{CONFIG.freshtokens_instanceid}: user: VID_#{video_id} vdata: #{visitor_data}")
    
    return {po_token, visitor_data}
  
  end
  
  def get_anon_tokens
  
    po_token = ""
    visitor_data = ""
  
    po_token = REDIS_DB.get("invidious:ANON-#{CONFIG.freshtokens_instanceid}:po_token")
    visitor_data = REDIS_DB.get("invidious:ANON-#{CONFIG.freshtokens_instanceid}:visitor_data")
    
    # check if tokens empty, generate new ones, store in redis
    if (po_token.nil? || visitor_data.nil?)
    
      LOGGER.info("get_user_tokens: #{CONFIG.freshtokens_instanceid}: user: ANON-#{CONFIG.freshtokens_instanceid} needs new tokens")
      po_token, visitor_data = generate_tokens_timeout
      
      # update redis with user's tokens (1 hour expiry for now)
      REDIS_DB.set("invidious:ANON-#{CONFIG.freshtokens_instanceid}:po_token", po_token, 600)
      REDIS_DB.set("invidious:ANON-#{CONFIG.freshtokens_instanceid}:visitor_data", visitor_data, 600)
      
      LOGGER.info("get_user_tokens: #{CONFIG.freshtokens_instanceid}: user: ANON-#{CONFIG.freshtokens_instanceid} stored user's tokens")

    else    
      LOGGER.info("get_user_tokens: #{CONFIG.freshtokens_instanceid}: user: ANON-#{CONFIG.freshtokens_instanceid} already has tokens")
    end
    
    LOGGER.info("get_user_tokens: user: #{CONFIG.freshtokens_instanceid}: ANON-#{CONFIG.freshtokens_instanceid} pot: #{po_token}")
    LOGGER.info("get_user_tokens: user: #{CONFIG.freshtokens_instanceid}: ANON-#{CONFIG.freshtokens_instanceid} vdata: #{visitor_data}")
    
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
    tokendata = `/usr/bin/timeout -k 12 -s KILL 10 ${HOME}/.nvm/versions/node/v20.18.0/bin/node submodules/youtube-po-token-generator/examples/one-shot.js`
    
    freshpot = `echo "#{tokendata.strip}" | awk -F"'" '/poToken/{print $2}'`
    freshvdata = `echo "#{tokendata.strip}" | awk -F"'" '/visitorData/{print $2}'`
    
    freshpot = freshpot.strip
    freshvdata = freshvdata.strip
    
    return {freshpot, freshvdata}

  end
  
end