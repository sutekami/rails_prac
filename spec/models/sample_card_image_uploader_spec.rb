# frozen_string_literal: true

describe SampleCardImageUploader do
  describe '#upload' do
    let(:s3_resource) { described_class.new(card).send(:s3_resource) }
    let(:s3_bucket) { s3_resource.bucket('cards-test') }
    let(:card) { create(:card) }

    before do
      # spec高速化のため、画像のサイズを小さくしておく
      stub_const("#{described_class}::CARD_WIDTH", 1)
      stub_const("#{described_class}::CARD_HEIGHT", 1)
      stub_const("#{described_class}::BUCKET_NAME", 'cards-test')

      if s3_bucket.exists?
        s3_bucket.objects.batch_delete!
        s3_bucket.delete
      end
    end

    after do
      s3_bucket.objects.batch_delete!
      s3_bucket.delete
    end

    subject { described_class.new(card).upload }

    context '画像作成が成功した場合' do
      it 'card buket内に画像が作成される' do
        expect { subject }
          .to change { s3_bucket.object(card.id.to_s).exists? }.from(false).to(true)
      end

      it 'Terminalに画像作成成功メッセージを出力する' do
        expect { subject }.to output("[CREATED] cards-test/#{card.id}\n").to_stdout
      end
    end

    context 'card bucketが存在していない場合' do
      it 'card bucktetが新規作成される' do
        expect { subject }.to change(s3_bucket, :exists?).from(false).to(true)
      end
    end

    context 'card bucketが既に存在している場合' do
      before { s3_resource.create_bucket(bucket: 'cards-test') }

      it 'card bucktetは新規作成されない' do
        expect { subject }.not_to change(s3_bucket, :exists?).from(true)
      end
    end
  end
end
