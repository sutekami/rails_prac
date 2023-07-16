require 'csv'

describe CardsController do
  describe 'POST create' do
    subject { post(:create, params:) }

    before do
      # 環境構築終了時と同じデータをtestDBにINSERTしておく
      CSV.foreach('db/cards.csv') do |row|
        card = Card.create(
          person_id: row[0],
          name: row[1],
          email: row[2],
          organization: row[3],
          department: row[4],
          title: row[5],
        )

        Person.find_or_create_by(id: row[0]).cards << card
      end
    end

    # '谷川 貞久'はperson_id: 7のcardとnameとemailが一致しているため、person_id: 7にmergeされる
    context '谷川 貞久の場合' do
      let(:params) do
        {
          name: '谷川 貞久',
          email: 'awakinat1981@example.com',
          organization: 'とまと株式会社',
          department: '開発部',
          title: 'サーバーサイドエンジニア',
        }
      end

      it 'person_id: 7に紐づく名刺が2枚あること' do
        subject
        expect(Card.where(person_id: 7).size).to eq(2)
      end
    end

    # '大平 美里'はmerge条件に一致しないため、新規にpersonが作成される
    context '大平 美里の場合' do
      let(:params) do
        {
          name: '大平 美里',
          email: 'tsm198320010406@example.com',
          organization: 'とうがらし株式会社',
          department: '人事部',
          title: '人事',
        }
      end

      it 'ユーザが新規作成されること' do
        expect { subject }.to change(Person, :count).from(10).to(11)
      end
    end

    # '東 顕太郎'はperson_id: 10のcardとemailが一致しており、
    # 役職スコアが80を超えているため、person_id: 10にmergeされる
    context '東 顕太郎の場合' do
      let(:params) do
        {
          name: '東 顕太郎',
          email: 'nishi@example.com',
          organization: '株式会社ピクルス',
          department: '開発部',
          title: 'サーバーサイドエンジニア',
        }
      end

      it 'person_id: 10に紐づく名刺が2枚あること' do
        subject
        expect(Card.where(person_id: 10).size).to eq(2)
      end
    end
  end
end
