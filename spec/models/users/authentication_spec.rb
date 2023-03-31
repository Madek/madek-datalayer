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
      @user = FactoryBot.create :user, 
        {password: nil,
         password_digest: "$2a$04$ogvMlPxYisDRQFIPfC2IjOpXT76Oin9voAzSTz3iLf.ZS4DXvDHuy"}
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
