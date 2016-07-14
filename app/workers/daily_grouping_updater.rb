class DailyGroupingUpdater
  include Sidekiq::Worker

  def initialize
    @system_account = Watcher.retrieve_system_account
  end

  def perform(app_name: WatConfig.secret_value('SYSTEM_ACCOUNT_APPS'), time_frame: 15.days.ago)
    groupings = Grouping.app_name(app_name).retrieve_stale_groupings(time_frame)
    groupings.each do |grouping|
      grouping.whodunnit(@system_account) do
        grouping.resolve!
      end
    end
  end
end
