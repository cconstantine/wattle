module ActiveRecord
  class Base
    # See: http://zogovic.com/post/44856908222/optimizing-postgresql-query-for-distinct-values
    def self.recursive_distinct(column)
      sql1 = all.select(column).order(column).limit(1).to_sql
      sql2 = all.select(column).where("#{column} > n").order(column).limit(1).to_sql
      query = <<-SQL
WITH RECURSIVE t(n) AS (    (#{sql1}  )
                          UNION
                            SELECT (#{sql2})       FROM t WHERE n IS NOT NULL
                       ) SELECT n FROM t  WHERE (n is not null)
      SQL

      unscoped.where("#{column} in (#{query})")
    end

    def self.recursive_distinct_count(column)
      sql1 = all.select(column).order(column).limit(1).to_sql
      sql2 = all.select(column).where("#{column} > n").order(column).limit(1).to_sql
      query = <<-SQL
WITH RECURSIVE t(n) AS (    (#{sql1}  )
                          UNION
                            SELECT (#{sql2})       FROM t WHERE n IS NOT NULL
                       ) SELECT n FROM t  WHERE (n is not null)
      SQL

      unscoped.from("(#{query}) as #{table_name}").count
    end
  end
end
