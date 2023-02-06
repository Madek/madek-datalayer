require 'spec_helper'

describe MetaDatum::People do

  context 'existing meta key test:people, collection, some people' do

    before :all do
      PgTasks.truncate_tables
      @meta_key_people = FactoryBot.create :meta_key_people
      @person1 = FactoryBot.create :person
      @person2 = FactoryBot.create :person
      @person3 = FactoryBot.create :person
      @collection = FactoryBot.create :collection
    end

    after :all do
      PgTasks.truncate_tables
    end

    it 'truly exists' do
      expect { MetaKey.find('test:people') }.not_to raise_error
      expect { Collection.find(@collection.id) }.not_to raise_error
    end

    describe ':meta_datum people factory' do

      it "invocation doesn't raise an error" do
        FactoryBot.create :meta_datum_people,
                           collection: @collection,
                           meta_key: @meta_key_people
      end

      context 'a factory created instance' do
        before :each do
          @meta_datum_people = FactoryBot.create :meta_datum_people,
                                                  collection: @collection,
                                                  meta_key: @meta_key_people
        end

        it 'has at least 3 people associated with it' do
          expect(@meta_datum_people.people.count).to be >= 3
        end

        describe 'to_s' do
          it 'includes the stringified people' do
            @meta_datum_people.people.each do |person|
              expect(@meta_datum_people.to_s).to include person.to_s
            end
          end
        end

        describe 'value=' do

          it 'resets the associated people' do
            created_by_user = create(:user)
            expect(@meta_datum_people.people).not_to be == [@person1, @person2]

            expect do
              @meta_datum_people.set_value!([@person1, @person2], created_by_user)
            end.not_to raise_error

            expect(@meta_datum_people.reload.people.to_a.sort_by(&:id)).to \
              be == [@person1, @person2].sort_by(&:id)

            expect(
              @meta_datum_people
                .meta_data_people
                .where(person: [@person1, @person2], created_by: created_by_user)
                .size
            ).to be == 2

            expect(
              @meta_datum_people
                .meta_data_people
                .where(created_by: created_by_user)
                .where.not(person: [@person1, @person2])
                .size
            ).to be == 0
          end

        end

      end

    end

  end

end
