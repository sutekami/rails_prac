RSpec.configure do |config|
  # specファイルでtestデータを生成する際、Class名の指定を省略できるようにする
  # ex: person = FactoryBot.create(:person) -> person = create(:person)
  config.include FactoryBot::Syntax::Methods

  # config.before do |config|
  #   springを使用した場合、FactoryBotで作成したデータが正しく読み込まれない場合があるため、reloadする
  #   FactoryBot.reload
  # end
end
