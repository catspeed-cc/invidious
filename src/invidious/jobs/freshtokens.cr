class Invidious::Jobs::FreshTokensJob < Invidious::Jobs::BaseJob
  include Invidious
  def begin
    loop do
        
      LOGGER.info("jobs: running MonitorCfgTokensJob job")
            
      #LOGGER.info("RESPONSE: #{response}")
    
      sleep 1.minutes
    end
  end
end
