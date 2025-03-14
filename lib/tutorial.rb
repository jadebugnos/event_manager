# Read the file contents
# puts "EventManager Initialized!"

# contents = File.read('event_attendees.csv')
# puts contents

# Read the file line by line
# lines = File.readlines('event_attendees.csv')
# lines.each do |line|
#   p line
# end

# display the first names of all attendees

# lines = File.readlines('event_attendees.csv')
# lines.each do |line|
#   columns = line.split(",")
#   name = columns[2]
#   puts name
# end

# Skipping the header row
# first solution
# lines = File.readlines('event_attendees.csv')
# lines.each do |line|
#   next if line == " ,RegDate,first_Name,last_Name,Email_Address,HomePhone,Street,City,State,Zipcode\n"
#   columns = line.split(",")
#   name = columns[2]
#   puts name
# end

# # second solution
# puts 'EventManager initialized.'

# lines = File.readlines('event_attendees.csv')
# row_index = 0
# lines.each do |line|
#   row_index = row_index + 1
#   next if row_index == 1
#   columns = line.split(",")
#   name = columns[2]
#   puts name
# end

# third and best solution using Array#each_with_index
# lines = File.readlines("event_attendees.csv")
# lines.each_with_index do |line, index|
#   next if index == 0

#   columns = line.split(",")
#   name = columns[2]
#   puts name
# end

# Iteration 1: Parsing with CSV
# Switching over to use the CSV library
# require "csv"

# contents = CSV.open("event_attendees.csv", headers: true)
# contents.each do |row|
#   name = row[2]
#   puts name
# end

# Accessing columns by their names
# require "csv"

# contents = CSV.open(
#   "event_attendees.csv",
#   headers: true,
#   header_converters: :symbol
# )

# contents.each do |row|
#   name = row[:first_Name]
#   puts name
# end

# displaying the zip codes of all attendees
# require "csv"

# contents = CSV.open(
#   "event_attendees.csv",
#   headers: true,
#   header_converters: :symbol
# )

# contents.each do |row|
#   name = row[:first_name]
#   zipcode = row[:zipcode]
#   puts "#{name} #{zipcode}"
# end

# Iteration 2: Cleaning up our zip codes
# require "csv"

# contents = CSV.open(
#   "event_attendees.csv",
#   headers: true,
#   header_converters: :symbol
# )

# contents.each do |row|
#   name = row[:first_name]
#   zipcode = row[:zipcode]

#   puts "#{name} #{zipcode}"
# end

# Handling bad and good zip codes
# require "csv"

# contents = CSV.open(
#   "event_attendees.csv",
#   headers: true,
#   header_converters: :symbol
# )

# contents.each do |row|
#   name = row[:first_name]
#   zipcode = row[:zipcode]

#   if zipcode.length < 5
#     zipcode = zipcode.rjust(5, "0") # to pad string with zeros
#   elsif zipcode.length > 5
#     zipcode = zipcode[0..4]
#   end

#   puts "#{name} #{zipcode}"
# end

# Handling missing zip codes
# require "csv"

# contents = CSV.open(
#   "event_attendees.csv",
#   headers: true,
#   header_converters: :symbol
# )

# contents.each do |row|
#   name = row[:first_name]
#   zipcode = row[:zipcode]

#   if zipcode.nil? # added to handle missing values
#     zipcode = "00000"
#   elsif zipcode.length < 5
#     zipcode = zipcode.rjust(5, "0")
#   elsif zipcode.length > 5
#     zipcode = zipcode[0..4]
#   end

#   puts "#{name} #{zipcode}"
# end

# Moving clean zip codes to a method
# require "csv"

# def clean_zipcode(zipcode)
#   # if zipcode.nil?
#   #   "00000"
#   # elsif zipcode.length < 5
#   #   zipcode.rjust(5, "0")
#   # elsif zipcode.length > 5
#   #   zipcode[0..4]
#   # else
#   #   zipcode
#   # end

#   zipcode.to_s.rjust(5, "0")[0..4]
# end

# contents = CSV.open(
#   "event_attendees.csv",
#   headers: true,
#   header_converters: :symbol
# )

# contents.each do |row|
#   name = row[:first_name]

#   zipcode = clean_zipcode(row[:zipcode])

#   puts "#{name} #{zipcode}"
# end

# Refactoring clean zip codes
# def clean_zipcode(zipcode)
#   zipcode.to_s.rjust(5, "0")[0..4]
# end

# Iteration 3: Using Google's Civic Information

require "csv"
require "google/apis/civicinfo_v2"

civic_info = Google::Apis::CivicinfoV2::CivicInfoService.new
civic_info.key = "AIzaSyClRzDqDh5MsXwnCWi0kOiiBivP6JsSyBw"

def clean_zipcode(zipcode)
  zipcode.to_s.rjust(5, "0")[0..4]
end

puts "EventManager initialized."

contents = CSV.open(
  "event_attendees.csv",
  headers: true,
  header_converters: :symbol
)

contents.each do |row|
  name = row[:first_name]

  zipcode = clean_zipcode(row[:zipcode])

  legislators = civic_info.representative_info_by_address(
    address: zipcode,
    levels: "country",
    roles: %w[legislatorUpperBody legislatorLowerBody]
  )
  legislators = legislators.officials

  puts "#{name} #{zipcode} #{legislators}"
end
