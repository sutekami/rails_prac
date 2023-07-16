# frozen_string_literal: true

class SampleCardImageUploader
  include S3Usable

  CARD_WIDTH  = 600
  CARD_HEIGHT = 381
  BUCKET_NAME = 'cards'

  def self.upload(card)
    new(card).upload
  end

  def initialize(card)
    @card = card
  end

  def upload
    card_image_binary = card_image_bin(
      card.organization,
      card.department,
      card.name,
      card.email,
    )
    s3_bucket.object(card.id.to_s).put(body: card_image_binary)
    puts "[CREATED] #{BUCKET_NAME}/#{card.id}" # rubocop:disable Rails/Output
  end

  private

  attr_reader :card

  def card_image_bin(org, dep, name, email)
    image = Magick::Image.new(CARD_WIDTH, CARD_HEIGHT) do |options|
      color = '#' + Array.new(3) { [*126..255].sample.to_s(16) }.join
      options.background_color = color
      options.format = 'jpeg'
    end
    draw = Magick::Draw.new.tap do |d|
      d.font = 'VL-Gothic-Regular'
      d.pointsize = 40
      d.gravity = Magick::NorthWestGravity
    end
    draw.annotate(image, CARD_WIDTH, CARD_HEIGHT, 0, 0, "#{org}\n#{dep}")
    draw.pointsize = 32
    draw.gravity = Magick::SouthEastGravity
    draw.annotate(image, CARD_WIDTH, CARD_HEIGHT, 0, 0, "#{name}\n#{email}")
    image.to_blob
  end

  def s3_bucket
    s3_bucket_base(BUCKET_NAME)
  end
end
