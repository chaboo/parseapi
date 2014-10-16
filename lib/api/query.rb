require 'json'

module RQuery
  module ClassMethods
    def rquery(cmd=nil)
      begin
        if cmd
          ar_statement = ''
          puts cmd
          puts cmd[:order]
          ar_statement += where_clause(JSON.parse(cmd[:where]), cmd[:class_name]) if cmd[:where]
          ar_statement += order_clause(cmd[:order]) if cmd[:order]
  
          ar_statement += limit_clause(cmd[:limit]) if cmd[:limit]
          ar_statement += skip_clause(cmd[:skip]) if cmd[:skip]

          ar_statement = (ar_statement == '' ? {:results => eval('all').to_a} : {:results => eval(ar_statement[1..-1]).to_a})
          ar_statement = count_clause(cmd[:count], ar_statement) if cmd[:count]
          ar_statement[:results].present? || ar_statement[:count].present? ? ar_statement : {:results => []}
        else
          {:results => []}
        end
      rescue
        # Something went wrong!
        ParseError.new(107, cmd)
      end
    end

    ## WHERE ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    def where_clause(cmd, class_name = nil)
      if cmd.kind_of?(Hash)
        puts cmd
        ar_statement = ""
        clause = build_query(cmd, class_name)
        clause = replace_brackets(clause)
        ar_statement += ".where(\"" + clause + "\")"
        puts "upit #{ar_statement}" 
        return ar_statement
      else
        error
      end
    end
    
    def where_key_value(key, value, class_name = nil)
      action='='
      val = ''
      if key == "$relatedTo"
        related_to(key, value)
      else
        if value["__type"]
          if value["__type"]=="Pointer"
            val = decode_type(value, key, class_name)
          else
            val = decode_type(value, key, class_name)
            where_build_clause(key, val, action, class_name)
          end
        else
          value.each do |k, v|
            action = replace(k) if k.match(/^\$/)
            if v.kind_of?(Hash)
              val = decode_type(v)
            else
              val = v
            end 
          end
          where_build_clause(key, val, action, class_name)
        end
      end
      
    end

    def where_build_clause(key, val, action="=", class_name=nil)
      if val.nil? 
        error
      else
        case action
        when 'IS'
          key_IS_NULL_or_NOT_NULL(key, action, val)
        when "IN", "NOT IN"
          key_IN_or_NOT_IN_value(key, action, val)
        when "LIKE", "ILIKE"
          key_LIKE_or_ILIKE_value(key, action, val)
        when "pluck"
          select(key, action, val)
        when "inQuery"
          inQuery(key, action, val, class_name)
        when "notInQuery"
          notInQuery(key, action, val, class_name)
        else
          adjust_for_string_value(key, action, val)
        end
      end
    end

    ## ORDER ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    def order_clause(cmd)
      ar_statement = ""
      cmd = cmd.split(",")
      cmd.each do |value|
        if value[0] == ("-")
          ar_statement += ".order(\"" + "#{value.sub('-', '')} DESC" + "\")"
        else
          ar_statement += ".order(\"" + "#{value}" + "\")"
        end
      end
      ar_statement
    end

    ## LIMIT ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    def limit_clause(value)
      ar_statement = ""
      ar_statement += ".limit(#{value})"
      ar_statement
    end

    ## COUNT ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    def count_clause(cmd, ar_statement)
      if cmd == "1"
        ar_statement.merge(:count => ar_statement[:results].count)
      else
        ar_statement
      end
    end

    ## SKIP ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    def skip_clause(value)
      ar_statement = ""
      ar_statement += ".offset(#{value})"
      ar_statement
    end

    #TODO
    ## INCLUDES ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    def includes_clause(cmd)
      includes cmd
    end

    #TODO
    ## JOINS ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    def joins_clause(cmd)
      joins cmd
    end

    ## ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    def replace(match_data)
      case match_data
        when '$gt' then '>'
        when '$lt' then '<'
        when '$gte' then '>='
        when '$lte' then '<='
        when '$ne' then '!='
        when '$in' then 'IN'
        when '$nin' then 'NOT IN'
        when '$exists' then 'IS'
        when '$like' then 'LIKE'
        when '$ilike' then 'ILIKE'
        when '$regexp' then 'REGEXP'
        when '$select' then 'pluck'
        when '$eq' then '='
        when '$inQuery' then 'inQuery'
        when '$notInQuery' then 'notInQuery'
      end
    end

    def decode_type(v, key=nil, class_name=nil)
      puts "usao u decode_type"
      if v["__type"]
        case v["__type"]
        when "Date"
          decode_iso(v["iso"])
        when "Byte"
          decode_base64(v["base64"])
        when "Pointer"
          pointer(v, key, class_name)       
        when "Relation"
        else
          v
        end
      else
        v
      end
    end

    def decode_iso(v)
      v.to_time.utc.to_s
    end

    def decode_base64(v)
      Base64.decode64(v).to_s
    end

    def pointer(v, key, class_name=nil)
      val = eval("ParseObject.where(\"class_name = '#{v["className"]}'  and obj_id = '#{v["objectId"]}'\")" + ".first")
      puts "val"
      if val
        if class_name
          "class_name = '#{class_name}' and properties ->> '#{key}' ='#{val.id}'"
        else
          arr = eval("#{val.properties}")
          arr = eval arr["#{key}"]
          "id IN #{arr}"
        end
      else
        if class_name
        "class_name = '#{class_name}' and properties ->> '#{key}'" + "='-1'"
        else
          "id = -1"
        end
      end
    end

    def multi?(cmd)
      return cmd.count > 1
    end

    def error
      "error"
    end

    def key_IS_NULL_or_NOT_NULL(key, action, val)
      "#{key} #{action} #{val == true ? 'NOT NULL' : 'NULL'}"  
    end

    def key_IN_or_NOT_IN_value(key, action, val)
      "#{key} #{action}" + val.to_s
    end

    def key_LIKE_or_ILIKE_value(key, action, val)
      "#{key} #{action} '" + val.to_s + "'"
    end

    def select(key, action, val)
      nested_query = eval("ParseObject.where(class_name: \"#{val["query"]["className"]}\")#{ParseObject.where_clause(val["query"]["where"])}.pluck('#{val["key"]}')")
      nested_query.empty? ? error : "#{key} IN #{replace_brackets(nested_query)}"
    end

    def replace_brackets(nest)
      nest = nest.to_s
      nest.gsub!("[", "(")
      nest.gsub!("]", ")")
      return nest
    end

    def adjust_for_string_value(key, action, val)
      if val.kind_of?(String)
        "#{key} #{action} '" + (val.gsub("'", "\\\\'")).to_s + "'"
      else
        "#{key} #{action}" + val.to_s
      end
    end

    def build_query(cmd, class_name=nil)
      clause = ""
      i = 0
      cmd.each do |key, value|
        i =i + 1
        if value.kind_of?(Hash)
          clause = process_hash_value(cmd, key, value, i, class_name, clause)
        else
          clause = process_simple_value(cmd, key, value, i, class_name, clause)
        end
      end
      clause.gsub!("createdAt", "created_at")
      clause.gsub!("\"", "'")
      return clause
    end

    def process_hash_value(cmd, key, value, i, class_name = nil, clause)
      if multi?(cmd)
        clause = i == 1  ? where_key_value(key, value, class_name) : clause + " and "  + where_key_value(key, value, class_name)
      else
        clause = clause + where_key_value(key, value, class_name)
      end
      return clause
    end

    def process_simple_value(cmd, key, value, i, class_name=nil, clause)
      if key == "$or"
        clause = compound_query_or(cmd, value, i, class_name, clause)
      else
        if multi?(cmd)
          clause = process_multiple_conditions(key, value, i, class_name, clause)
        else
          if value.kind_of?(String)
            clause = value.nil? ? "#{self.table_name}.#{key} IS NULL" : "#{self.table_name}.#{key} = \'" + value.gsub("'", "\\\\'") + "\'"
          else
            clause = value.nil? ? "#{self.table_name}.#{key} IS NULL" : "#{self.table_name}.#{key} = #{value}"
          end
        end
      end
      return clause
    end

    def process_multiple_conditions(key, value, i, class_name=nil, clause)
      if i == 1 
        if value.kind_of?(String)
          clause = value.nil? ? "#{self.table_name}.#{key} IS NULL" : "#{self.table_name}.#{key} = \'" + value.gsub("'", "\\\\'") + "\'"
        else
          clause = value.nil? ? "#{self.table_name}.#{key} IS NULL" : "#{self.table_name}.#{key} = #{value}"
        end
      else
        if value.kind_of?(String)
          clause = value.nil? ? clause + "and #{self.table_name}.#{key} IS NULL" : clause + " and #{self.table_name}.#{key} = \'" + value.gsub("'", "\\\\'") + "\'"
        else
          clause = value.nil? ? clause + "and #{self.table_name}.#{key} IS NULL" : clause + " and #{self.table_name}.#{key} = #{value}"
        end
      end
      return clause
    end

    def compound_query_or(cmd, value, i, class_name=nil, clause)
      value.each do |val|
        puts val
        clause = i == 1 ? build_query(val) : clause + " OR " +  build_query(val)
        i = i + 1
      end
      return clause
    end

    def notInQuery(key, action, val, class_name)
      subquery = "ParseObject.where(\"class_name = '#{val["className"]}' and " + build_query(val["where"].except("className")) + "\").pluck(\"id\")" 
      puts "subquery #{subquery}"
      subquery = eval(subquery)
      puts subquery
      sub = []
      subquery.each do |s|
        sub << s.to_s
      end
      sub.empty? ? "class_name = '#{class_name}'" : "class_name = '#{class_name}' and (properties ->> '#{key}' NOT IN #{sub})"
    end

    def inQuery(key, action, val, class_name)
      subquery = "ParseObject.where(\"class_name = '#{val["className"]}' and " + build_query(val["where"].except("className")) + "\").pluck(\"id\")" 
      puts "subquery #{subquery}"
      subquery = eval(subquery)
      sub = []
      subquery.each do |s|
        sub << s.to_s
      end
      sub.empty? ? "class_name = '#{class_name}'" : "class_name = '#{class_name}' and (properties ->> '#{key}' IN #{sub})"
    end

    def related_to(key, value)
      pointer(value["object"], value["key"])
    end
      
  end

  def self.included(base)
    base.extend(ClassMethods)
  end
end