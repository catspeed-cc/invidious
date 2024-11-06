class Invidious::Jobs::FreshTokensUserJob < Invidious::Jobs::BaseJob
  # Refreshes users tokens every defined interval
  # Removes the need for a cron job.
  def begin
    loop do
      
      # job start
      LOGGER.info("jobs: running FreshTokensUser job")
      
      # do user jobs

      # job done
      LOGGER.info("jobs: FreshTokensUser done.")

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
      LOGGER.info("jobs: running FreshTokensAnon job")
      
      # do anon jobs
      FreshTokens.generate_anon_tokens

      # job done
      LOGGER.info("jobs: FreshTokensAnon done.")
      
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
      LOGGER.info("jobs: running FreshTokensStats job")
      
      FreshTokens.update_stats

      # job done
      LOGGER.info("jobs: FreshTokensStats done.")
      
    end
  end
end