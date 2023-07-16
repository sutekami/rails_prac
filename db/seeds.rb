# frozen_string_literal: true

require 'csv'
require 'aws-sdk-s3'

# reset tables
begin
  ActiveRecord::Base.connection.execute('START TRANSACTION')
  Person.destroy_all
  ActiveRecord::Base.connection.execute('ALTER TABLE cards AUTO_INCREMENT = 1')
  ActiveRecord::Base.connection.execute('ALTER TABLE people AUTO_INCREMENT = 1')
  ActiveRecord::Base.connection.execute('COMMIT')
rescue StandardError => e
  ActiveRecord::Base.connection.execute('ROLLBACK')
  raise e
end

# insert seeds data
ActiveRecord::Base.transaction do
  CSV.foreach('db/cards.csv') do |row|
    card = Card.new(
      person_id: row[0],
      name: row[1],
      email: row[2],
      organization: row[3],
      department: row[4],
      title: row[5],
    )
    Person.find_or_create_by(id: row[0]).cards << card
    SampleCardImageUploader.upload(card)
  end
end
