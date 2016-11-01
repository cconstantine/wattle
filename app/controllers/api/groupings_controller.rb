module Api
  class GroupingsController < ApplicationController
    respond_to :json

    def count_by_state
      render text: :ko, status: 400 and return unless required_params_present?

      @groupings = Grouping.filtered(filter_params.merge(captured_at: 14.days.ago)).group(:state).count

      respond_to do |format|
        format.json { render :json => @groupings }
      end
    end

    def count
      render text: :ko, status: 400 and return unless required_params_present?

      response = { state: filter_params[:state], count: Grouping.filtered_by_params(filter_params).count }

      respond_to do |format|
        format.json { render json: response }
      end
    end

    private

    def filter_params
      params.permit(:app_name, :app_env, :language, :state)
    end

    def required_params_present?
      ["app_name", "app_env", "language"].all? {|p| params.include?(p) }
    end
  end
end
