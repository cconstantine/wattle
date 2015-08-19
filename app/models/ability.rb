class Ability
  include CanCan::Ability

  def initialize(user)
    can :destroy, Note do |note|
      note.watcher == user
    end
    can :create, Note
  end
end
