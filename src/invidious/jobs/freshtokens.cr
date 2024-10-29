class Invidious::Jobs::FreshTokensJob < Invidious::Jobs::BaseJob
  include Invidious
  def begin
    loop do
        
      LOGGER.info("jobs: running MonitorCfgTokensJob job")
      
      Invidious::FreshTokens.get_tokens
            
      LOGGER.info("POT: #{Invidious::FreshTokens.pot}")
      LOGGER.info("VDATA: #{Invidious::FreshTokens.vdata}")
    
      sleep CONFIG.freshtokens_interval
    end
  end
end
