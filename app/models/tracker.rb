class Tracker
  include ActiveModel::Model

  attr_accessor :grouping

  def initialize(api_key)
    @api_key = api_key
  end

  def has_key?
    @api_key.present?
  end

  def projects
    client.projects
  end

  def tracker_project
    ""
  end

  def create_story(project_id, props)
    project = client.project(project_id)

    props[:story_type] = "bug"
    project.create_story(props)
  end

  def client
    @client ||= TrackerApi::Client.new(token: @api_key)
  end
end
