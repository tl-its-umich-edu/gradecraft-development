class CreateEvents < ActiveRecord::Migration
  def change
    create_table :events do |t|
      t.string :name
      t.text :descripton
      t.datetime :open_date
      t.datetime :close_date
      t.text :media
      t.text :thumbnail
      t.text :media_credit
      t.string :media_caption

      t.timestamps
    end
  end
end
