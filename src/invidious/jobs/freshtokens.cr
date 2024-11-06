class Invidious::Jobs::FreshTokensUserJob < Invidious::Jobs::BaseJob
  # Refreshes users tokens every defined interval
  # Removes the need for a cron job.
  def begin
    loop do
      
      # job start
      LOGGER.info("FreshTokens: jobs: running FreshTokensUser job")
      
      # do user jobs

      # job done
      LOGGER.info("FreshTokens: jobs: FreshTokensUser done.")

      # static sleep is all that is needed for now
      sleep 1000.seconds
      
    end
  end
end

class Invidious::Jobs::FreshTokensAnonJob < Invidious::Jobs::BaseJob
  # Remove items (videos, nonces, etc..) whose cache is outdated every hour.
  # Removes the need for a cron job.
  def begin
    loop do
      
      # job start
      LOGGER.info("FreshTokens: jobs: running FreshTokensAnon job")
      
      # do anon jobs
      FreshTokens.generate_anon_tokens

      # job done
      LOGGER.info("FreshTokens: jobs: FreshTokensAnon done.")
      
      # static sleep is all that is needed for now
      sleep 30.seconds
      
    end
  end
end

class Invidious::Jobs::FreshTokensStatsJob < Invidious::Jobs::BaseJob
  # Remove items (videos, nonces, etc..) whose cache is outdated every hour.
  # Removes the need for a cron job.
  def begin
    loop do
      
      # job start
      LOGGER.info("FreshTokens: jobs: running FreshTokensStats job")
      
      LOGGER.info("FreshTokens: TEST: \"#{CPULIMIT}\"")
      LOGGER.info("FreshTokens: TEST: \"#{NODE}\"")
      LOGGER.info("FreshTokens: TEST: \"#{TIMEOUT}\"")
      LOGGER.info("FreshTokens: TEST: \"#{REDIS_CLI}\"")
      
      FreshTokens.update_stats

      # job done
      LOGGER.info("FreshTokens: jobs: FreshTokensStats done.")
      
    end
  end
end