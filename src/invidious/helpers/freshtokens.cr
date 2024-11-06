module FreshTokens
  extend self

  @@working : Bool = false

  @@tpm : Int32 = 0
  @@tcount : Int32 = 0
  
  @@po_token : String = ""
  @@visitor_data : String = ""
  
  @@node : String = ""
  
  def get_working
    return @@working
  end  
  
  def get_tpm
    return @@tpm
  end
  
  def get_tcount
    return @@tcount
  end
  
  def initialize
    if (!NODE.empty?)
      @@node = NODE
    else    
      @@node = `su - invidious -c "export NVM_DIR=\"$([ -z \"${XDG_CONFIG_HOME-}\" ] && printf %s \"${HOME}/.nvm\" || printf %s \"${XDG_CONFIG_HOME}/nvm\")\" ; [ -s \"$NVM_DIR/nvm.sh\" ] && \. \"$NVM_DIR/nvm.sh\" ; which node ;"`
      @@node = @@node.strip
    end
  end
  
  
  def update_stats
  
    instanceid = CONFIG.freshtokens_instanceid
    
    if ( !REDIS_CLI.nil? && !REDIS_CLI.empty? )

      # get first count
      count1 = `#{REDIS_CLI} eval "return #redis.call('keys', 'invidious:ANON-#{instanceid}*:po_token')" 0 | awk 'IFS=" " {print $1}'`
  
      # set the count
      @@tcount = (count1.to_i - 1)
      
      # next get the tpm    
      sleep 15.seconds
      
      # get second count
      count2 = `#{REDIS_CLI} eval "return #redis.call('keys', 'invidious:ANON-#{instanceid}*:po_token')" 0 | awk 'IFS=" " {print $1}'`
      
      # get the difference between first and second count
      difference = count2.to_i - count1.to_i
      
      # Multiply by 4 to get minutely number
      @@tpm = (difference * 4)
      
      # may as well update count again
      @@tcount = (count2.to_i - 1)
      
    else
    
      LOGGER.warn("FreshTokens: update_stats: #{CONFIG.freshtokens_instanceid}: user: INST-#{instanceid} waiting on redis key lock")
    
    end
  
  end
  
  
  
  
  def get_instance_tokens
  
    po_token = ""
    visitor_data = ""
    instance_id = CONFIG.freshtokens_instanceid
  
    po_token = REDIS_DB.get("invidious:INST-#{instance_id}:po_token")
    visitor_data = REDIS_DB.get("invidious:INST-#{instance_id}:visitor_data")
    
    # first we check if redis is locked and wait
  
    while ( (po_token == "LOCK" || visitor_data == "LOCK") )
    
      LOGGER.info("FreshTokens: get_instance_tokens: #{CONFIG.freshtokens_instanceid}: user: INST-#{instance_id} waiting on redis key lock")    
    
      # wait. we want to return tokens when they are generated by other process
      sleep 1.seconds
      
      # refresh tokens from redis
      po_token = REDIS_DB.get("invidious:INST-#{instance_id}:po_token")
      visitor_data = REDIS_DB.get("invidious:INST-#{instance_id}:visitor_data")
    
    end

    LOGGER.info("FreshTokens: get_instance_tokens: #{CONFIG.freshtokens_instanceid}: user: INST-#{instance_id} redis key unlocked")  
    
    # get tokens (initial)
    po_token = REDIS_DB.get("invidious:INST-#{instance_id}:po_token")
    visitor_data = REDIS_DB.get("invidious:INST-#{instance_id}:visitor_data") 
  
    if ( (po_token != "LOCK" && visitor_data != "LOCK") && ((po_token.nil? || visitor_data.nil?) || (po_token.empty? || visitor_data.empty?)) )
      
      # lock redis key for 60 seconds (wait for processes to finish and do not open another process)
      REDIS_DB.set("invidious:INST-#{instance_id}:po_token", "LOCK", 60)
      REDIS_DB.set("invidious:INST-#{instance_id}:visitor_data", "LOCK", 60)        
    
      LOGGER.info("FreshTokens: get_instance_tokens: #{CONFIG.freshtokens_instanceid}: needs new tokens")
      po_token, visitor_data = generate_tokens
      
      # update redis with instance's tokens (1 minute expiry for now)
      REDIS_DB.set("invidious:INST-#{instance_id}:po_token", po_token.strip, 900)
      REDIS_DB.set("invidious:INST-#{instance_id}:visitor_data", visitor_data.strip, 900)
      
      LOGGER.info("FreshTokens: get_instance_tokens: #{CONFIG.freshtokens_instanceid}: user: INST-#{instance_id} unlocking user key")
      LOGGER.info("FreshTokens: get_instance_tokens: #{CONFIG.freshtokens_instanceid}: user: INST-#{instance_id} stored instance's tokens")

    else    
      LOGGER.info("FreshTokens: get_instance_tokens: #{CONFIG.freshtokens_instanceid}: user: INST-#{instance_id} already has tokens")
    end
    
    LOGGER.info("FreshTokens: get_instance_tokens: #{CONFIG.freshtokens_instanceid}: user: INST-#{instance_id} pot: #{po_token}")
    LOGGER.info("FreshTokens: get_instance_tokens: #{CONFIG.freshtokens_instanceid}: user: INST-#{instance_id} vdata: #{visitor_data}")
    
    return {po_token.strip, visitor_data.strip}
  
  end
  
  
  
  
  def get_user_tokens(useremail : String)
  
    po_token = ""
    visitor_data = ""
  
    po_token = REDIS_DB.get("invidious:#{useremail}:po_token")
    visitor_data = REDIS_DB.get("invidious:#{useremail}:visitor_data")
    
    # first we check if redis is locked and wait
  
    while ( (po_token == "LOCK" || visitor_data == "LOCK") )
    
      LOGGER.info("FreshTokens: get_user_tokens: #{CONFIG.freshtokens_instanceid}: user: #{useremail} waiting on redis key lock")    
    
      # wait. we want to return tokens when they are generated by other process
      sleep 1.seconds
      
      # refresh tokens from redis
      po_token = REDIS_DB.get("invidious:#{useremail}:po_token")
      visitor_data = REDIS_DB.get("invidious:#{useremail}:visitor_data")
    
    end

    LOGGER.info("FreshTokens: get_user_tokens: #{CONFIG.freshtokens_instanceid}: user: #{useremail} redis key unlocked")     
    
    # check if tokens empty, generate new ones, store in redis
    if ((po_token.nil? || visitor_data.nil?) || (po_token.empty? || visitor_data.empty?))
    
      LOGGER.info("FreshTokens: get_user_tokens: #{CONFIG.freshtokens_instanceid}: user: #{useremail} needs new tokens")    
      LOGGER.info("FreshTokens: get_user_tokens: #{CONFIG.freshtokens_instanceid}: user: #{useremail} locking user key")    
    
      # lock redis key for 60 seconds (wait for processes to finish and do not open another process)
      REDIS_DB.set("invidious:#{useremail}:po_token", "LOCK", 60)
      REDIS_DB.set("invidious:#{useremail}:visitor_data", "LOCK", 60) 
      
      po_token, visitor_data = generate_tokens
      
      # update redis with user's tokens (1 hour expiry for now)
      REDIS_DB.set("invidious:#{useremail}:po_token", po_token.strip, 3600)
      REDIS_DB.set("invidious:#{useremail}:visitor_data", visitor_data.strip, 3600)
      
      LOGGER.info("FreshTokens: get_user_tokens: #{CONFIG.freshtokens_instanceid}: user: #{useremail} stored user's tokens")

    else    
      LOGGER.info("FreshTokens: get_user_tokens: #{CONFIG.freshtokens_instanceid}: user: #{useremail} already has tokens")
    end
    
    LOGGER.info("FreshTokens: get_user_tokens: #{CONFIG.freshtokens_instanceid}: user: #{useremail} pot: #{po_token}")
    LOGGER.info("FreshTokens: get_user_tokens: #{CONFIG.freshtokens_instanceid}: user: #{useremail} vdata: #{visitor_data}")
    
    return {po_token.strip, visitor_data.strip}
  
  end
  
  
  
  
  def get_anon_tokens
  
    po_token = ""
    visitor_data = ""
    
    rnd = rand(CONFIG.freshtokens_anonpool_size)
    
    redis_instanceuserid = "ANON-#{CONFIG.freshtokens_instanceid}-#{rnd}" 
    
    # get tokens (initial)
    po_token = REDIS_DB.get("invidious:#{redis_instanceuserid}:po_token")
    visitor_data = REDIS_DB.get("invidious:#{redis_instanceuserid}:visitor_data") 
    
    while ( (po_token.nil? || visitor_data.nil?) || (po_token.empty? || visitor_data.empty?) )
    
      if (po_token.nil? || visitor_data.nil?) || (po_token.empty? || visitor_data.empty?)
        REDIS_DB.del("invidious:#{redis_instanceuserid}:po_token")
        REDIS_DB.del("invidious:#{redis_instanceuserid}:visitor_data")
      end    
    
      LOGGER.info("FreshTokens: get_anon_tokens: #{CONFIG.freshtokens_instanceid}: user: #{redis_instanceuserid} tokens are empty, deleting & trying another")   
     
      # sleep
      sleep 500.milliseconds
     
      # prepare for next iteration...
      rnd = rand(CONFIG.freshtokens_anonpool_size)
      redis_instanceuserid = "ANON-#{CONFIG.freshtokens_instanceid}-#{rnd}"
      
      # prepare for next iteration...
      po_token = REDIS_DB.get("invidious:#{redis_instanceuserid}:po_token")
      visitor_data = REDIS_DB.get("invidious:#{redis_instanceuserid}:visitor_data") 
    
    end
    
    LOGGER.info("FreshTokens: get_anon_tokens: #{CONFIG.freshtokens_instanceid}: user: #{redis_instanceuserid} pot: #{po_token}")
    LOGGER.info("FreshTokens: get_anon_tokens: #{CONFIG.freshtokens_instanceid}: user: #{redis_instanceuserid} vdata: #{visitor_data}")
    
    return {po_token.strip, visitor_data.strip}
  
  end





  def generate_anon_tokens
  
    # generate anon tokens one by one (instead of users generating at the same time)
    # called by Invidious::Jobs::FreshTokensAnonJob  
    
    # define the anon user pool
    rnd = CONFIG.freshtokens_anonpool_size
   
    @@working = true
   
    i = 0    
    while i <= rnd

      # define the instance/user id    
      redis_instanceuserid = "ANON-#{CONFIG.freshtokens_instanceid}-#{i}"

      LOGGER.debug("FreshTokens: generate_anon_tokens: #{CONFIG.freshtokens_instanceid}: user: #{redis_instanceuserid}: getting tokens")     
      
      # get tokens (initial)
      po_token = REDIS_DB.get("invidious:#{redis_instanceuserid}:po_token")
      visitor_data = REDIS_DB.get("invidious:#{redis_instanceuserid}:visitor_data")
      
      if ( (po_token.nil? || visitor_data.nil?) || (po_token.empty? || visitor_data.empty?) )
      
        LOGGER.info("FreshTokens: generate_anon_tokens: #{CONFIG.freshtokens_instanceid}: user: #{redis_instanceuserid}: GENERATING TOKENS")

        # tokens are nil or empty, generate them
        po_token, visitor_data = generate_tokens
        
        if ( ! (po_token.nil? || visitor_data.nil?) && ! (po_token.empty? || visitor_data.empty?) )
        
          # if not nil or empty        
        
          # update redis with user's tokens (30min expiry for now)
          REDIS_DB.set("invidious:#{redis_instanceuserid}:po_token", po_token.strip, 10800)
          REDIS_DB.set("invidious:#{redis_instanceuserid}:visitor_data", visitor_data.strip, 10800)
        
        end
        
      else
      
        # sleep
        sleep 100.milliseconds
        LOGGER.debug("FreshTokens: generate_anon_tokens: #{CONFIG.freshtokens_instanceid}: user: #{redis_instanceuserid}: TOKENS EXIST ALREADY")
      
      end
        
      # tokens are NOT nil or empty, log & skip them.
      LOGGER.info("FreshTokens: generate_anon_tokens: #{CONFIG.freshtokens_instanceid}: user: #{redis_instanceuserid}: pot: #{po_token}")
      LOGGER.info("FreshTokens: generate_anon_tokens: #{CONFIG.freshtokens_instanceid}: user: #{redis_instanceuserid}: vdata: #{visitor_data}")
            
      LOGGER.debug("FreshTokens: generate_anon_tokens: #{CONFIG.freshtokens_instanceid}: user: #{redis_instanceuserid}: done getting tokens")   

      # increase counter
      i += 1    
    end
    
    @@working = false
  
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
    
    LOGGER.info("FreshTokens: NODE = \"#{@@node}\"")
    
    #LOGGER.info("FreshTokens: generate_tokens: proxy_str = \"#{proxy_str}\"")
    #LOGGER.info("FreshTokens: generate_tokens: http_proxy_str = \"#{http_proxy_str}\"")

    # get the tokens :)
#    tokendata = `#{http_proxy_str} #{CPULIMIT} -f -l 50 -- #{@@node} submodules/youtube-po-token-generator/examples/one-shot.js`
    tokendata = `#{CPULIMIT} -f -l 50 -- ${HOME}/.nvm/versions/node/v20.18.0/bin/node submodules/youtube-po-token-generator/examples/one-shot.js`
    
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
    
    #LOGGER.info("FreshTokens: generate_tokens_timeout: proxy_str = \"#{proxy_str}\"")
    #LOGGER.info("FreshTokens: generate_tokens_timeout: http_proxy_str = \"#{http_proxy_str}\"")

    # get the tokens :)
    #tokendata = `#{http_proxy_str} #{TIMEOUT} -k #{hardkillsecs} -s KILL #{softkillsecs} #{CPULIMIT} -f -l 50 -- #{@@node} submodules/youtube-po-token-generator/examples/one-shot.js`
    tokendata = `#{TIMEOUT} -k #{hardkillsecs} -s KILL #{softkillsecs} /usr/bin/cpulimit -f -l 50 -- #{@@node} submodules/youtube-po-token-generator/examples/one-shot.js`
    
    freshpot = `echo "#{tokendata.strip}" | awk -F"'" '/poToken/{print $2}'`
    freshvdata = `echo "#{tokendata.strip}" | awk -F"'" '/visitorData/{print $2}'`
    
    return {freshpot.strip, freshvdata.strip}

  end
  
end