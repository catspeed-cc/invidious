module FreshTokens
  extend self
  
  @@po_token : String | Nil
  @@visitor_data : String | Nil
  
  def get_instance_tokens
  
    po_token = ""
    visitor_data = ""
    instance_id = CONFIG.freshtokens_instanceid
  
    po_token = REDIS_DB.get("invidious:INST-#{instance_id}:po_token")
    visitor_data = REDIS_DB.get("invidious:INST-#{instance_id}:visitor_data")
    
    # first we check if redis is locked and wait
  
    while ( (po_token == "LOCK" || visitor_data == "LOCK") )
    
      LOGGER.info("get_instance_tokens: #{CONFIG.freshtokens_instanceid}: user: INST-#{instance_id} waiting on redis key lock")    
    
      # wait. we want to return tokens when they are generated by other process
      sleep 1.seconds
      
      # refresh tokens from redis
      po_token = REDIS_DB.get("invidious:INST-#{instance_id}:po_token")
      visitor_data = REDIS_DB.get("invidious:INST-#{instance_id}:visitor_data")
    
    end

    LOGGER.info("get_instance_tokens: #{CONFIG.freshtokens_instanceid}: user: INST-#{instance_id} redis key unlocked")  
    
    # get tokens (initial)
    po_token = REDIS_DB.get("invidious:INST-#{instance_id}:po_token")
    visitor_data = REDIS_DB.get("invidious:INST-#{instance_id}:visitor_data") 
  
    if ( (po_token != "LOCK" && visitor_data != "LOCK") && ((po_token.nil? || visitor_data.nil?) || (po_token.empty? || visitor_data.empty?)) )
      
      # lock redis key for 60 seconds (wait for processes to finish and do not open another process)
      REDIS_DB.set("invidious:INST-#{instance_id}:po_token", "LOCK", 60)
      REDIS_DB.set("invidious:INST-#{instance_id}:visitor_data", "LOCK", 60)        
    
      LOGGER.info("get_instance_tokens: #{CONFIG.freshtokens_instanceid}: needs new tokens")
      po_token, visitor_data = generate_tokens
      
      # update redis with instance's tokens (1 minute expiry for now)
      REDIS_DB.set("invidious:INST-#{instance_id}:po_token", po_token.strip, 900)
      REDIS_DB.set("invidious:INST-#{instance_id}:visitor_data", visitor_data.strip, 900)
      
      LOGGER.info("get_instance_tokens: #{CONFIG.freshtokens_instanceid}: user: INST-#{instance_id} unlocking user key")
      LOGGER.info("get_instance_tokens: #{CONFIG.freshtokens_instanceid}: user: INST-#{instance_id} stored instance's tokens")

    else    
      LOGGER.info("get_instance_tokens: #{CONFIG.freshtokens_instanceid}: user: INST-#{instance_id} already has tokens")
    end
    
    LOGGER.info("get_instance_tokens: #{CONFIG.freshtokens_instanceid}: user: INST-#{instance_id} pot: #{po_token}")
    LOGGER.info("get_instance_tokens: #{CONFIG.freshtokens_instanceid}: user: INST-#{instance_id} vdata: #{visitor_data}")
    
    return {po_token.strip, visitor_data.strip}
  
  end
  
  
  
  
  def get_user_tokens(useremail : String)
  
    po_token = ""
    visitor_data = ""
  
    po_token = REDIS_DB.get("invidious:#{useremail}:po_token")
    visitor_data = REDIS_DB.get("invidious:#{useremail}:visitor_data")
    
    # first we check if redis is locked and wait
  
    while ( (po_token == "LOCK" || visitor_data == "LOCK") )
    
      LOGGER.info("get_user_tokens: #{CONFIG.freshtokens_instanceid}: user: #{useremail} waiting on redis key lock")    
    
      # wait. we want to return tokens when they are generated by other process
      sleep 500.milliseconds
      
      # refresh tokens from redis
      po_token = REDIS_DB.get("invidious:#{useremail}:po_token")
      visitor_data = REDIS_DB.get("invidious:#{useremail}:visitor_data")
    
    end

    LOGGER.info("get_user_tokens: #{CONFIG.freshtokens_instanceid}: user: #{useremail} redis key unlocked")     
    
    # check if tokens empty, generate new ones, store in redis
    if ((po_token.nil? || visitor_data.nil?) || (po_token.empty? || visitor_data.empty?))
    
      LOGGER.info("get_user_tokens: #{CONFIG.freshtokens_instanceid}: user: #{useremail} needs new tokens")    
      LOGGER.info("get_user_tokens: #{CONFIG.freshtokens_instanceid}: user: #{useremail} locking user key")    
    
      # lock redis key for 60 seconds (wait for processes to finish and do not open another process)
      REDIS_DB.set("invidious:#{useremail}:po_token", "LOCK", 60)
      REDIS_DB.set("invidious:#{useremail}:visitor_data", "LOCK", 60) 
      
      po_token, visitor_data = generate_tokens
      
      # update redis with user's tokens (1 hour expiry for now)
      REDIS_DB.set("invidious:#{useremail}:po_token", po_token.strip, 300)
      REDIS_DB.set("invidious:#{useremail}:visitor_data", visitor_data.strip, 300)
      
      LOGGER.info("get_user_tokens: #{CONFIG.freshtokens_instanceid}: user: #{useremail} stored user's tokens")

    else    
      LOGGER.info("get_user_tokens: #{CONFIG.freshtokens_instanceid}: user: #{useremail} already has tokens")
    end
    
    LOGGER.info("get_user_tokens: #{CONFIG.freshtokens_instanceid}: user: #{useremail} pot: #{po_token}")
    LOGGER.info("get_user_tokens: #{CONFIG.freshtokens_instanceid}: user: #{useremail} vdata: #{visitor_data}")
    
    return {po_token.strip, visitor_data.strip}
  
  end
  
  def get_anon_tokens
  
    po_token = ""
    visitor_data = ""
    
    rnd = rand(1000)
    redis_instanceuserid = "ANON-#{CONFIG.freshtokens_instanceid}-#{rnd}" 
    
    # get tokens (initial)
    po_token = REDIS_DB.get("invidious:#{redis_instanceuserid}:po_token")
    visitor_data = REDIS_DB.get("invidious:#{redis_instanceuserid}:visitor_data") 
    
    while ( (po_token.nil? || visitor_data.nil?) || (po_token.empty? || visitor_data.empty?) )
    
      LOGGER.info("get_anon_tokens: #{CONFIG.freshtokens_instanceid}: user: #{redis_instanceuserid} tokens are empty, trying another")   
     
      # sleep
      sleep 1.seconds    
     
      # prepare for next iteration...
      rnd = rand(400)
      redis_instanceuserid = "ANON-#{CONFIG.freshtokens_instanceid}-#{rnd}"
      
      # prepare for next iteration...
      po_token = REDIS_DB.get("invidious:#{redis_instanceuserid}:po_token")
      visitor_data = REDIS_DB.get("invidious:#{redis_instanceuserid}:visitor_data") 
    
    end
    
    LOGGER.info("get_anon_tokens: #{CONFIG.freshtokens_instanceid}: user: #{redis_instanceuserid} pot: #{po_token}")
    LOGGER.info("get_anon_tokens: #{CONFIG.freshtokens_instanceid}: user: #{redis_instanceuserid} vdata: #{visitor_data}")
    
    return {po_token.strip, visitor_data.strip}
  
  end





  def generate_anon_tokens
  
    # generate anon tokens one by one (instead of users generating at the same time)
    # called by Invidious::Jobs::FreshTokensAnonJob  
    
    # define the anon user pool
    rnd = 1000
   
    i = 0    
    while i <= rnd

      # define the instance/user id    
      redis_instanceuserid = "ANON-#{CONFIG.freshtokens_instanceid}-#{i}"

      LOGGER.debug("generate_anon_tokens: #{CONFIG.freshtokens_instanceid}: user: #{redis_instanceuserid}: getting tokens")     
      
      # get tokens (initial)
      po_token = REDIS_DB.get("invidious:#{redis_instanceuserid}:po_token")
      visitor_data = REDIS_DB.get("invidious:#{redis_instanceuserid}:visitor_data")
      
      if ( (po_token.nil? || visitor_data.nil?) || (po_token.empty? || visitor_data.empty?) )
      
        LOGGER.info("generate_anon_tokens: #{CONFIG.freshtokens_instanceid}: user: #{redis_instanceuserid}: GENERATING TOKENS")

        # tokens are nil or empty, generate them
        po_token, visitor_data = generate_tokens
        
        if ( ! (po_token.nil? || visitor_data.nil?) || (po_token.empty? || visitor_data.empty?) )
        
          # if not nil or empty        
        
          # update redis with user's tokens (30min expiry for now)
          REDIS_DB.set("invidious:#{redis_instanceuserid}:po_token", po_token.strip, 3600)
          REDIS_DB.set("invidious:#{redis_instanceuserid}:visitor_data", visitor_data.strip, 3600)
        
        end
        
      else
      
        # sleep
        sleep 250.milliseconds
        LOGGER.debug("generate_anon_tokens: #{CONFIG.freshtokens_instanceid}: user: #{redis_instanceuserid}: TOKENS EXIST ALREADY")
      
      end
        
      # tokens are NOT nil or empty, log & skip them.
      LOGGER.info("generate_anon_tokens: #{CONFIG.freshtokens_instanceid}: user: #{redis_instanceuserid}: pot: #{po_token}")
      LOGGER.info("generate_anon_tokens: #{CONFIG.freshtokens_instanceid}: user: #{redis_instanceuserid}: vdata: #{visitor_data}")
            
      LOGGER.debug("generate_anon_tokens: #{CONFIG.freshtokens_instanceid}: user: #{redis_instanceuserid}: done getting tokens")   

      # increase counter
      i += 1    
    end
  
  end





  def generate_tokens

#    # put together the authentication string
#    if ( !config_proxy.user.empty? && !config_proxy.password.empty? )
#    
#          proxy_str = `echo #{proxy_str} | sed 's,http://,&#{config_proxy.user}:#{config_proxy.password}@,'`
#          proxy_str = `echo #{proxy_str} | sed 's,https://,&#{config_proxy.user}:#{config_proxy.password}@,'`
#          proxy_str = proxy_str.strip
#    
#    end
    
#    http_proxy_str = "export http_proxy=#{proxy_str} https_proxy=#{proxy_str} HTTP_PROXY=#{proxy_str} HTTPS_PROXY=#{proxy_str} ; " 
    
    #LOGGER.info("generate_tokens: proxy_str = \"#{proxy_str}\"")  
    #LOGGER.info("generate_tokens: http_proxy_str = \"#{http_proxy_str}\"")  

    # get the tokens :)
#    tokendata = `#{http_proxy_str} /usr/bin/cpulimit -f -l 50 -- ${HOME}/.nvm/versions/node/v20.18.0/bin/node submodules/youtube-po-token-generator/examples/one-shot.js`
    tokendata = `/usr/bin/cpulimit -f -l 50 -- ${HOME}/.nvm/versions/node/v20.18.0/bin/node submodules/youtube-po-token-generator/examples/one-shot.js`
    
    freshpot = `echo "#{tokendata.strip}" | awk -F"'" '/poToken/{print $2}'`
    freshvdata = `echo "#{tokendata.strip}" | awk -F"'" '/visitorData/{print $2}'`
    
    return {freshpot.strip, freshvdata.strip}

  end

  def generate_tokens_timeout(softkillsecs : Int32 = 10, hardkillsecs : Int32 = 12)
    
#    # put together the authentication string
#    if ( !config_proxy.user.empty? && !config_proxy.password.empty? )
#    
#          proxy_str = `echo #{proxy_str} | sed 's,http://,&#{config_proxy.user}:#{config_proxy.password}@,'`
#          proxy_str = `echo #{proxy_str} | sed 's,https://,&#{config_proxy.user}:#{config_proxy.password}@,'`
#          proxy_str = proxy_str.strip
#    
#    end
    
#    http_proxy_str = "export http_proxy=#{proxy_str} https_proxy=#{proxy_str} HTTP_PROXY=#{proxy_str} HTTPS_PROXY=#{proxy_str} ; " 
    
    #LOGGER.info("generate_tokens_timeout: proxy_str = \"#{proxy_str}\"")
    #LOGGER.info("generate_tokens_timeout: http_proxy_str = \"#{http_proxy_str}\"")  

    # get the tokens :)
    #tokendata = `#{http_proxy_str} /usr/bin/timeout -k #{hardkillsecs} -s KILL #{softkillsecs} /usr/bin/cpulimit -f -l 50 -- ${HOME}/.nvm/versions/node/v20.18.0/bin/node submodules/youtube-po-token-generator/examples/one-shot.js`
    tokendata = `/usr/bin/timeout -k #{hardkillsecs} -s KILL #{softkillsecs} /usr/bin/cpulimit -f -l 50 -- ${HOME}/.nvm/versions/node/v20.18.0/bin/node submodules/youtube-po-token-generator/examples/one-shot.js`
    
    freshpot = `echo "#{tokendata.strip}" | awk -F"'" '/poToken/{print $2}'`
    freshvdata = `echo "#{tokendata.strip}" | awk -F"'" '/visitorData/{print $2}'`
    
    return {freshpot.strip, freshvdata.strip}

  end
  
end