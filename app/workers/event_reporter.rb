class EventReporter
  @queue= :eventreporter

  def self.perform()
    p "Starting EventReporter"


    # run report for a single course

    # upload report for saving

    # send email notification when report is ready
  end
end
