require "csv"
require "google/apis/civicinfo_v2"
require "erb"
require "date"
require "time"

def clean_zipcode(zipcode)
  zipcode.to_s.rjust(5, "0")[0..4]
end

def legislators_by_zipcode(zip)
  civic_info = Google::Apis::CivicinfoV2::CivicInfoService.new
  civic_info.key = File.read("secret.key").strip

  begin
    civic_info.representative_info_by_address(
      address: zip,
      levels: "country",
      roles: %w[legislatorUpperBody legislatorLowerBody]
    ).officials
  rescue StandardError
    "You can find your representatives by visiting www.commoncause.org/take-action/find-elected-officials"
  end
end

def clean_phone_numbers(phone_number)
  digits = phone_number.gsub(/\D/, "")
  digits.slice!(0) if digits.size == 11 && digits[0] == "1"

  if digits.size == 10
    format("(%s) %s-%s", digits[0..2], digits[3..5], digits[-4..]) # rubocop:disable Style/FormatStringToken
  else
    "invalid number"
  end
end

# accumulators for the registration hours and days
$registration_hours = [] # rubocop:disable Style/GlobalVars
$registration_days = [] # rubocop:disable Style/GlobalVars

def handle_reg_dates(date)
  reg_date = Time.strptime(date, "%m/%d/%y %H:%M")
  formatted_time = reg_date.strftime("%I %p")
  $registration_hours << formatted_time # rubocop:disable Style/GlobalVars
  $registration_days << reg_date.strftime("%A") # rubocop:disable Style/GlobalVars
end

def tally_and_sort(arr)
  tallied = arr.tally
  sorted = tallied.sort_by { |_key, value| -value }
end

def save_thank_you_letter(id, form_letter)
  Dir.mkdir("output") unless Dir.exist?("output") # rubocop:disable Lint/NonAtomicFileOperation

  filename = "output/thanks_#{id}.html"

  File.open(filename, "w") do |file|
    file.puts form_letter
  end
end

puts "EventManager initialized."

contents = CSV.open(
  "event_attendees.csv",
  headers: true,
  header_converters: :symbol
)

template_letter = File.read("form_letter.erb")
ERB.new template_letter

contents.each do |row|
  row[0]
  row[:first_name]

  zipcode = clean_zipcode(row[:zipcode])

  legislators_by_zipcode(zipcode)

  clean_phone_numbers(row[:homephone])

  handle_reg_dates(row[:regdate])
  # form_letter = erb_template.result(binding)
  # save_thank_you_letter(id, form_letter)
end

puts tally_and_sort($registration_hours) # rubocop:disable Style/GlobalVars
puts tally_and_sort($registration_days) # rubocop:disable Style/GlobalVars
