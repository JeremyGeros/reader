class ReadLaterSaveJob < ApplicationJob
  queue_as :default

  def perform(article)
    article.read_later_save
  end
end