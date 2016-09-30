module ActiveRecord

  class QueryTimeout < TimeoutError; end

  class Base
    def self.with_timeout(seconds, &block)
      previous_timeout = ActiveRecord::Base.connection.execute("show statement_timeout").first["statement_timeout"]
      ActiveRecord::Base.connection.execute("set statement_timeout to '#{seconds}s'")
      begin
        block.yield
      rescue ActiveRecord::StatementInvalid => e
        if e.message =~ /QueryCanceled.*? statement timeout/
          raise QueryTimeout.new("Query took longer than #{seconds}s")
        end
        raise
      end
    ensure
      ActiveRecord::Base.connection.execute("set statement_timeout to '#{previous_timeout}'")
    end

    def self.with_timeout_default(seconds, default, &block)
      with_timeout(seconds, &block)
    rescue QueryTimeout
      default
    end
  end
end