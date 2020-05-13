# required libs
require 'rubygems'
require 'ok_hbase'

# HBase adapter class 
class HBaseHandle
  
  # Constants setting
  # Hbase host
  HBASE_HOST = 'cluster'
  # Hbase port
  HBASE_PORT = '9090'  
  # Hbase user
  HBASE_USER = 'user'
  # Hbase password
  HBASE_PASSWORD = 'password'
  
  # Create new HBase connection using Thrift API with defined constants HBASE_HOST and HBASE_PORT
  def initialize(tablename)
        @connection = OkHbase::Connection.new(auto_connect: true, host: HBASE_HOST, port: HBASE_PORT)
        @table = get_table(tablename, @connection) 
  end
  
  # Destructor/Close connection
  def close_connection
    @connection.close()    
  end
  
  # Get table
  # @param table [String], conn [String]
  # @return table object  
  def get_table(table, conn)
    if table.nil?      
      return nil
    end    
    OkHbase::Table.new(table, conn)
  end
  
  # Add column
  # @param row_key [String], col_family [String], col_name [String], value [String] 
  def add_cell (row_key, col_family, col_name, value)  
    @table.put(row_key, {(col_family+':'+col_name) => value})
  end
  
  # Add multiple cells, each item in cells array is hash['col_family', 'col_name', 'value']
  # @param row_key [String], cells [Array] 
  def add_cells (row_key, cells)
    cells.each{|item|
      @table.put(row_key, {(item["col_family"]+':'+item["col_name"]) => item["value"]})
    }    
  end
  
  # check column exist in row and column family
  # @param row_key [String], col_family [String], col_name [String] 
  def is_column_exist (row_key, col_family, col_name)
    !@table.row(row_key)[col_family+':'+col_name].blank?     
  end

  # Get cell value
  # @param row_key [String], col_family [String], col_name [String]
  def get_cell_value (row_key, col_family, col_name)
    @table.row(row_key)[col_family + ':' + col_name]
  end
  
  # Drop_column
  # @param row_key [String], col_family [String], col_name [String]
  def drop_column(row_key, col_family, col_name)
    columns = [col_family + ':' + col_name]
    @table.delete(row_key,columns)
  end
  
  # Display a row
  # @param row_key [String] 
  def display_row (row_key)  
    @table.row(row_key).each  do |row|
      puts row    
    end 
  end  
end

