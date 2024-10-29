class Invidious::Jobs::FreshTokensJob < Invidious::Jobs::BaseJob
  include Invidious
  def begin
    loop do
        
      #LOGGER.info("jobs: running FreshTokensJob")
      
      #Invidious::FreshTokens.get_tokens
            
      #LOGGER.info("jobs: FreshTokensJob: FRESH POT: \"#{Invidious::FreshTokens.freshpot}\"")
      #LOGGER.info("jobs: FreshTokensJob: FRESH VDATA: \"#{Invidious::FreshTokens.freshvdata}\"")
    
      sleep 1.seconds
      #sleep CONFIG.freshtokens_interval.seconds
    end
  end
end
