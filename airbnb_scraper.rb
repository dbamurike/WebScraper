require 'nokogiri'
require 'open-uri'
require 'csv'

# Store URL to be scraped
url = "https://www.airbnb.com/s/Brooklyn--NY--United-States"
#store data in arrays, intialize empty array
name = Array.new()
details = Array.new()
price = Array.new()

# Parse the page with Nokogiri
page = Nokogiri::HTML(open(url))

page_numbers = Array.new()
page.css("div.pagination ul li a[target]").each do |line|
 page_numbers << line.text
end

#for some reason when I parsing for the last available page numbers, I was getting an array and some odd words
#they were always the last ones, so I removed the last item in the original array
#then, convert to an array because nokogiri actually returns an array of strings
max_page = page_numbers[0...-1].map(&:to_i).max
#loop once for every page
max_page.times do |i|
  #this allows us to continue going on to next page until we hit the end
  url = "https://www.airbnb.com/s/Brooklyn--NY--United-States?page=#{i+1}"
  page = Nokogiri::HTML(open(url))

  page.css('h3.h5.listing-name').each do |line|
    name << line.text.strip
  end

  page.css('span.h3.price-amount').each do |line|
    price << line.text
  end

  page.css('div.text-muted.listing-location.text-truncate').each do |line|
    subarray = line.text.strip.split(/ · /)
    if subarray.length == 3
      details << subarray
    else
      details << [subarray[0], "0 reviews", subarray[1]]
    end
  end

end


# Write data to CSV file
CSV.open("airbnb_listings.csv", "w") do |file|
  file << ["Listing Name", "Price", "Room Type", "Reviews", "Location"]

  name.length.times do |i|
    file << [name[i], price[i], details[i][0], details[i][1], details[i][2]]
  end
end
