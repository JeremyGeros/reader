class ImportJob < ApplicationJob
  queue_as :default
  
  def perform(import)
    import.import!
  end
end