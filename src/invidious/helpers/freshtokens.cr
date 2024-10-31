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
      po_token, visitor_data = generate_tokens_timeout(7, 10)
      
      # update redis with instance's tokens (1 minute expiry for now)
      REDIS_DB.set("invidious:inv_instance_#{instance_id}:po_token", po_token, 300)
      REDIS_DB.set("invidious:inv_instance_#{instance_id}:visitor_data", visitor_data, 300)
      
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
  
    po_token = REDIS_DB.get("invidious:USER-#{useremail}:po_token")
    visitor_data = REDIS_DB.get("invidious:USER-#{useremail}:visitor_data")
    
    # check if tokens empty, generate new ones, store in redis
    if ((po_token.nil? || visitor_data.nil?) || (po_token.empty? || visitor_data.empty?))
    
      LOGGER.info("get_user_tokens: #{CONFIG.freshtokens_instanceid}: user: USER-#{useremail} needs new tokens")
      po_token, visitor_data = generate_tokens_timeout(10, 12)
      
      # update redis with user's tokens (1 hour expiry for now)
      REDIS_DB.set("invidious:USER-#{useremail}:po_token", po_token, 300)
      REDIS_DB.set("invidious:USER-#{useremail}:visitor_data", visitor_data, 300)
      
      LOGGER.info("get_user_tokens: #{CONFIG.freshtokens_instanceid}: user: USER-#{useremail} stored user's tokens")

    else    
      LOGGER.info("get_user_tokens: #{CONFIG.freshtokens_instanceid}: user: USER-#{useremail} already has tokens")
    end
    
    LOGGER.info("get_user_tokens: #{CONFIG.freshtokens_instanceid}: user: USER-#{useremail} pot: #{po_token}")
    LOGGER.info("get_user_tokens: #{CONFIG.freshtokens_instanceid}: user: USER-#{useremail} vdata: #{visitor_data}")
    
    return {po_token, visitor_data}
  
  end
  
  def get_vid_tokens(video_id : String)
  
    po_token = ""
    visitor_data = ""
    
    video_uid = "ANON-#{CONFIG.freshtokens_instanceid}-#{rnd}"
  
    po_token = REDIS_DB.get("invidious:#{video_uid}:po_token")
    visitor_data = REDIS_DB.get("invidious:#{video_uid}:visitor_data")
    
    # check if tokens empty, generate new ones, store in redis
    if ((po_token.nil? || visitor_data.nil?) || (po_token.empty? || visitor_data.empty?))
    
      LOGGER.info("get_user_tokens: #{CONFIG.freshtokens_instanceid}: user: {video_uid} needs new tokens")
      po_token, visitor_data = generate_tokens_timeout(7, 10)
      
      # update redis with user's tokens (1 hour expiry for now)
      REDIS_DB.set("invidious:VID_#{video_uid}:po_token", po_token, 3600)
      REDIS_DB.set("invidious:VID_#{video_uid}:visitor_data", visitor_data, 3600)
      
      LOGGER.info("get_user_tokens: #{CONFIG.freshtokens_instanceid}: user: VID_#{video_uid} stored user's tokens")

    else    
      LOGGER.info("get_user_tokens: #{CONFIG.freshtokens_instanceid}: user: VID_#{video_uid} already has tokens")
    end
    
    LOGGER.info("get_user_tokens: #{CONFIG.freshtokens_instanceid}: user: VID_#{video_uid} pot: #{po_token}")
    LOGGER.info("get_user_tokens: #{CONFIG.freshtokens_instanceid}: user: VID_#{video_uid} vdata: #{visitor_data}")
    
    return {po_token, visitor_data}
  
  end
  
  def get_anon_tokens
  
    po_token = ""
    visitor_data = ""
    
    rnd = rand(35)
    redis_instanceid = "ANON-#{CONFIG.freshtokens_instanceid}-#{rnd}"
  
    # locking redis key while fetching new tokens if not locked already
    # this is a way to prevent double requests from same redis_instanceid  
    #LOGGER.info("get_anon_tokens: #{CONFIG.freshtokens_instanceid}: user: #{redis_instanceid} get_anon_tokens init")
  
    # get tokens (initial)
    po_token = REDIS_DB.get("invidious:#{redis_instanceid}:po_token")
    visitor_data = REDIS_DB.get("invidious:#{redis_instanceid}:visitor_data")  

    # first we check if redis is locked and wait
  
    while ( (po_token == "LOCK" || visitor_data == "LOCK") )
    
      LOGGER.info("get_anon_tokens: #{CONFIG.freshtokens_instanceid}: user: #{redis_instanceid} waiting on redis key lock")    
    
      # wait. we want to return tokens when they are generated by other process
      sleep 1.seconds
      
      # refresh tokens from redis
      po_token = REDIS_DB.get("invidious:#{redis_instanceid}:po_token")
      visitor_data = REDIS_DB.get("invidious:#{redis_instanceid}:visitor_data")
    
    end

    LOGGER.info("get_anon_tokens: #{CONFIG.freshtokens_instanceid}: user: #{redis_instanceid} redis key unlocked") 

    # next we want to generate the tokens if we are no longer waiting on lock
    # then update redis, and return tokens to user    
    
    ### replace while with if (recursive loop here bad) only get tokens once ###
                  ### KEEP DATABASE LOCK LOOP ABOVE ###    
    
    # get tokens (initial)
    po_token = REDIS_DB.get("invidious:#{redis_instanceid}:po_token")
    visitor_data = REDIS_DB.get("invidious:#{redis_instanceid}:visitor_data") 
  
    if ( (po_token != "LOCK" && visitor_data != "LOCK") && ((po_token.nil? || visitor_data.nil?) || (po_token.empty? || visitor_data.empty?)) )
    
      # if po_token and visitor_data are not locked and are empty/unset
    
      LOGGER.info("get_anon_tokens: #{CONFIG.freshtokens_instanceid}: user: #{redis_instanceid} needs new tokens")    
      LOGGER.info("get_anon_tokens: #{CONFIG.freshtokens_instanceid}: user: #{redis_instanceid} locking user key")    
    
      # lock redis key for 60 seconds (wait for processes to finish and do not open another process)
      REDIS_DB.set("invidious:#{redis_instanceid}:po_token", "LOCK", 60)
      REDIS_DB.set("invidious:#{redis_instanceid}:visitor_data", "LOCK", 60)    
    
      # generate tokens (should take 5 seconds max ... softkillsecs, hardkillsecs )
      # will make token server setup w/ reverse proxy and dedicated token generators
      po_token, visitor_data = generate_tokens_timeout(7, 10)
      
      # update redis with user's tokens (1 hour expiry for now)
      REDIS_DB.set("invidious:#{redis_instanceid}:po_token", po_token, 600)
      REDIS_DB.set("invidious:#{redis_instanceid}:visitor_data", visitor_data, 600)
    
      LOGGER.info("get_anon_tokens: #{CONFIG.freshtokens_instanceid}: user: #{redis_instanceid} unlocking user key")
      LOGGER.info("get_anon_tokens: #{CONFIG.freshtokens_instanceid}: user: #{redis_instanceid} stored user's tokens")  
    
    end
    
    # much better to log tokens here instad of inside loop.
    # now we see tokens whether they were pulled from DB or fresh generated.    
    LOGGER.info("get_anon_tokens: #{CONFIG.freshtokens_instanceid}: user: #{redis_instanceid} pot: #{po_token}")
    LOGGER.info("get_anon_tokens: #{CONFIG.freshtokens_instanceid}: user: #{redis_instanceid} vdata: #{visitor_data}")
    
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

  def generate_tokens_timeout(softkillsecs : Int32 = 10, hardkillsecs : Int32 = 12)

    # get the tokens :)
    tokendata = `/usr/bin/timeout -k #{hardkillsecs} -s KILL #{softkillsecs} ${HOME}/.nvm/versions/node/v20.18.0/bin/node submodules/youtube-po-token-generator/examples/one-shot.js`
    
    freshpot = `echo "#{tokendata.strip}" | awk -F"'" '/poToken/{print $2}'`
    freshvdata = `echo "#{tokendata.strip}" | awk -F"'" '/visitorData/{print $2}'`
    
    freshpot = freshpot.strip
    freshvdata = freshvdata.strip
    
    return {freshpot, freshvdata}

  end
  
end