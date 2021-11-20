class ReservationAndGuestMigration < ActiveRecord::Migration[6.1]
  def change
    create_table :guests do |t|
      t.string :email, index: { unique: true }
      t.string :first_name
      t.string :last_name
      t.string :phone

      t.timestamps
    end

    create_table :reservations do |t|
      t.column(:reservation_code, 'char(11)', null: false, index: { unique: true })
      t.date :start_date
      t.date :end_date
      t.integer :nights
      t.integer :guests
      t.integer :adults
      t.integer :children
      t.integer :infants
      t.integer :status
      t.column(:currency, 'char(3)', null: false)
      t.decimal :payout_price, precision: 10, scale: 2
      t.decimal :security_price, precision: 10, scale: 2
      t.decimal :total_price, precision: 10, scale: 2
      t.text :localized_description

      t.timestamps

      t.references :guest, index: true, foreign_key: true
    end
  end
end
