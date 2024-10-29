class Invidious::Jobs::FreshTokensJob < Invidious::Jobs::BaseJob
  include Invidious
  def begin
    loop do
        
      LOGGER.info("jobs: running MonitorCfgTokensJob job")
      
      Invidious::FreshTokens.get_tokens
            
      LOGGER.info("FRESH POT: #{Invidious::FreshTokens.freshpot}")
      LOGGER.info("FRESH VDATA: #{Invidious::FreshTokens.freshvdata}")
    
      sleep CONFIG.freshtokens_interval.seconds
    end
  end
end
