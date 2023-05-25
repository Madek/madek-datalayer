require 'spec_helper_no_tx'

describe [User] do
  context "User with given new user password" do
    before :each do 
      @user = FactoryBot.create :user, {password: 'secret'}
    end

    it "passes authorization with proper password and " \
      "returns the user object" do
        expect(@user.authenticate "secret").to be== @user
      end

    it "fails authorization with a wrong and " \
      "returns false" do
        expect(@user.authenticate "foo").to be== false
      end


  end


  context "User with given legacy bcrypt password" do
    before :each do 
      @user = FactoryBot.create :user
      sql= <<-SQL.strip_heredoc
        DELETE FROM auth_systems_users 
          WHERE user_id = :user_id
            AND auth_system_id = 'password';
        INSERT INTO auth_systems_users (auth_system_id, user_id, data)
          VALUES('password', :user_id, :data); 
      SQL
      ActiveRecord::Base.connection.execute(
        ApplicationRecord.sanitize_sql(
          [sql, user_id: @user.id, 
           data: "$2a$04$ogvMlPxYisDRQFIPfC2IjOpXT76Oin9voAzSTz3iLf.ZS4DXvDHuy"]))
    end

    it "passes authorization with proper password and " \
      "returns the user object" do
        expect(@user.authenticate "secret").to be== @user
      end

    it "fails authorization with a wrong and " \
      "returns false" do
        expect(@user.authenticate "foo").to be== false
      end

  end

end
