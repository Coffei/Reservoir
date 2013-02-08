# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

ActiveRecord::Base.connection.execute("DELETE FROM delayed_jobs")
ActiveRecord::Base.connection.execute("INSERT INTO delayed_jobs (priority, attempts, handler, run_at, created_at, updated_at) VALUES (0,0,'--- !ruby/struct:RemoteCalendar\nroom_id:\nrepeat: true\n...\n', '2013-01-01 10:00:00.000000', '#{Time.now.to_s(:db)}', '#{Time.now.to_s(:db)}') ")
                  
if(File.exists?("import.sql"))
  puts "Found import.sql, executing it."
  file = File.open("import.sql")
  lines = file.readlines
  lines.each do  |line|
    ActiveRecord::Base.connection.execute(line)
  end
end
