require_relative 'db_connection'
require 'active_support/inflector'
# NB: the attr_accessor we wrote in phase 0 is NOT used in the rest
# of this project. It was only a warm up.

class SQLObject
  def self.columns
    return @col if @col != nil
    col = DBConnection.execute2(<<-SQL)
      SELECT
       *
      FROM
        #{self.table_name}
      SQL
    cols = col.first
    cols.map!{|ele| ele.to_sym }

    @col = cols
  end

  def self.finalize!
      self.columns.each do |col|
        define_method(col) do
          attributes[col]
        end
  
        define_method("#{col}=") do |value|
          attributes[col] = value 
        end
      end
  
  end

  def self.table_name=(table_name)
    @table_name = table_name
  end

  def self.table_name
    @table_name || self.name.downcase.pluralize
  end

  def self.all
    results = DBConnection.execute(<<-SQL)
    SELECT
      #{self.table_name}.*
    FROM
      #{self.table_name}
    SQL

    self.parse_all(results)
  end

  def self.parse_all(results)
    results.map {|result| self.new(result) }
  end

  def self.find(id)
    # self.all.find { |obj| obj.id == id }
    results = DBConnection.execute(<<-SQL, id)
    SELECT
      #{self.table_name}.*
    FROM
      #{self.table_name}
    WHERE
      #{self.table_name}.id = ?
    SQL

    parse_all(results).first
    
  end

  def initialize(params = {})
    # params.each do |k, v|
    #   k = k.to_sym
    #   raise "unknown attribute '#{k}'" unless self.class.columns.include?(k)
    #   self.send("#{k}=", v) 
    # end

    params.each do |col, val|
      sym_col = col.to_sym
      if self.class.columns.include?(sym_col)
        self.send("#{sym_col}=", val)
      else
        raise "unknown attribute '#{sym_col}'"
      end
    end

  end

  def attributes
    @attributes ||= {}
  end

  def attribute_values
    self.class.columns.each {|col| self.send(col)}
  end

  def insert
    # ...
  end

  def update
    # ...
  end

  def save
    # ...
  end
end
