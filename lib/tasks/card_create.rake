require 'csv'

namespace :card_create do
  task call_card_create_api1: :environment do
    each_curl_request('db/additional_data1.csv')

    puts '全てのリクエストが完了しました。'.green
  end

  task call_card_create_api2: :environment do
    each_curl_request('db/additional_data2.csv')

    puts '全てのリクエストが完了しました。'.green
  end
end

def each_curl_request(csv_file)
  CSV.foreach(csv_file) do |row|
    params = {
      name: row[0],
      email: row[1],
      organization: row[2],
      department: row[3],
      title: row[4],
    }

    uri = URI.parse("http://localhost:3000/cards")
    response = Net::HTTP.post_form(uri, params)

    unless response.code == '201'
      puts 'APIのリクエストに失敗'.red
      puts "response_status: #{response.code}\nrequest_body: #{params.to_json}"
      exit 1
    end
  end
end

class String
  def colorize(color_code)
    "\e[#{color_code}m#{self}\e[0m"
  end

  def red
    colorize(31)
  end

  def green
    colorize(32)
  end
end
