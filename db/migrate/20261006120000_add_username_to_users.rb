class AddUsernameToUsers < ActiveRecord::Migration[8.1]
  def up
    add_column :users, :username, :string

    # Backfill existing users from the email local-part (before "@"),
    # de-duplicating with a numeric suffix so the unique index can be applied.
    say_with_time "backfilling usernames from email" do
      used = []
      select_rows("SELECT id, email FROM users ORDER BY id").each do |id, email|
        base = email.to_s.split("@").first.to_s.downcase.gsub(/[^a-z0-9._-]/, "")
        base = "user" if base.empty?
        candidate = base
        n = 1
        while used.include?(candidate)
          candidate = "#{base}#{n}"
          n += 1
        end
        used << candidate
        execute("UPDATE users SET username = #{quote(candidate)} WHERE id = #{id}")
      end
    end

    add_index :users, :username, unique: true
    change_column_null :users, :username, false
  end

  def down
    remove_column :users, :username
  end
end
