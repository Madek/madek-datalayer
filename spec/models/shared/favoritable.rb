RSpec.shared_examples 'a favoritable' do

  before :example do
    @user = FactoryGirl.create :user
  end

  it 'favor' do

    resource.favor_by @user
    expect(resource.users_who_favored).to include @user

  end

  it 'disfavor' do

    resource.favor_by @user
    resource.disfavor_by @user
    expect(resource.users_who_favored).not_to include @user

  end

  it 'toggle' do

    resource.toggle_by @user
    expect(resource.users_who_favored).to include @user
    resource.toggle_by @user
    expect(resource.users_who_favored).not_to include @user

  end

  it 'favored with user nil raises error' do
    expect { resource.favored?(nil) }.to raise_error(
      ArgumentError, 'Missing user!')
  end

  it 'favor results in favored' do
    resource.favor_by @user
    expect(resource.favored?(@user)).to eq true
    resource.disfavor_by @user
    expect(resource.favored?(@user)).to eq false
  end

end
