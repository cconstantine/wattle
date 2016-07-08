class TrackersController < ApplicationController
  before_filter :load_grouping

  def create
    story_name = @grouping.tracker_story_name
    description = "[View grouping #{@grouping.id} in Wattle](#{grouping_url(@grouping)})"
    story = current_user.tracker.create_story(story_params[:tracker_project],
      name: story_name,
      description: description
    )

    @grouping.update!(pivotal_tracker_story_id: story.id)
    redirect_to :back
  end

  protected

  def story_params
    params.require(:tracker).permit(:tracker_project)
  end

  def load_grouping
    @grouping = Grouping.find(params.require(:tracker).permit(:grouping_id)[:grouping_id])
  end
end
