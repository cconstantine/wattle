class SearchesController < ApplicationController

  def show
    @active_tab = "search"
    search_query = params[:q].blank? ? "*" : params[:q]

    wheres = { }
    wheres[:app_env]  = filters[:app_env] if filters[:app_env]
    wheres[:app_name] = filters[:app_name] if filters[:app_name]
    wheres[:language] = filters[:language] if filters[:language]
    wheres[:hostname] = filters[:hostname] if filters[:hostname]
    wheres[:user_ids] = filters[:app_user] if filters[:app_user]

    @search_results = Grouping.search(search_query, fields: [:hostname, :user_ids, {key_line: :text_middle}, :error_class, :message, :user_emails], where: wheres, page: params[:page], per_page: 20, order: {latest_wat_at: :desc})
  end

end
