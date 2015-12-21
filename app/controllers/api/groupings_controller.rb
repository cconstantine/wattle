module Api
  class GroupingsController < ApplicationController
   respond_to :json

    def count_by_state
      if params[:app_name] && params[:app_env] && params[:language]
        @groupings = Grouping.where("groupings.updated_at > ?", 7.days.ago).language(params[:language]).app_name(params[:app_name]).app_env(params[:app_env]).group(:state).count

        respond_to do |format|
          format.json  { render :json => @groupings }
        end
      else
        render text: :ko, status: 400 
      end
    end

  end
end