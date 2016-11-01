module Api
  class GroupingsController < ApplicationController
    respond_to :json

    def count_by_state
      if params[:app_name] && params[:app_env] && params[:language]
        @groupings = Grouping.filtered(params.merge(captured_at: 14.days.ago)).group(:state).count

        respond_to do |format|
          format.json { render json: @groupings }
        end
      else
        render text: :ko, status: 400
      end
    end

    def count
      if params[:app_name] && params[:app_env] && params[:language]
        @groupings = Grouping.filtered_by_params(params)
        response = { state: params[:state], count: @groupings.count}

        respond_to do |format|
          format.json { render json: response }
        end
      else
        render text: :ko, status: 400
      end
    end
  end
end