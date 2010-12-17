class AddAmountsToAccountingJournal < ActiveRecord::Migration
  def self.up
    add_column :journal_entries, :amount, :decimal, :scale => 30
  end

  def self.down
    remove_column :journal_entries, :amount
  end
end
