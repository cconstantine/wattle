class RenameAcknowledgedToWontfix < ActiveRecord::Migration
  def up
    ActiveRecord::Base.connection.execute %q{
      UPDATE groupings SET state = 'wontfix' WHERE state = 'acknowledged';
    }
  end

  def down
    ActiveRecord::Base.connection.execute %q{
      UPDATE groupings SET state = 'acknowledged' WHERE state = 'wontfix';
    }
  end
end
