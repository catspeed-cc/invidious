class Invidious::Jobs::FreshTokensJob < Invidious::Jobs::BaseJob
  include Invidious
  def begin
    loop do
        
      LOGGER.info("jobs: running MonitorCfgTokensJob job")
      
      Invidious::FreshTokens.get_tokens
            
      LOGGER.info("YOUR POT: #{Invidious::FreshTokens.pot}")
      LOGGER.info("YOUR VDATA: #{Invidious::FreshTokens.vdata}")
    
      sleep CONFIG.freshtokens_interval.seconds
    end
  end
end
