class NotesController < ApplicationController

  before_filter :get_grouping, :build_note

  def create
    @note.save!
    redirect_to :back
  end


  protected

  def get_grouping
    @grouping = Grouping.find(params.permit(:grouping_id)[:grouping_id])
  end

  def build_note
    @note = current_user.notes.build(params.require(:note).permit(:message).merge(grouping: @grouping))
  end
end
