class CreatePeople < ActiveRecord::Migration[5.2]
  def change
    # rubocop: disable Style/SymbolProc
    create_table :people do |t|
      t.timestamps
    end
    # rubocop: enable Style/SymbolProc
  end
end
