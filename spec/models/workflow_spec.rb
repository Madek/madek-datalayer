require 'spec_helper'

describe Workflow do
  it 'is creatable by factory' do
    expect { create :workflow }.not_to raise_error
  end

  context 'when created' do
    it 'has is_active set to true by default' do
      expect(subject.is_active).to be true
    end
  end

  describe 'default common meta data' do
    let(:user) { create :user }

    context 'when value is given as a hash' do
      it 'wraps it in array' do
        allow_any_instance_of(Workflow)
          .to receive(:default_common_meta_data)
          .and_return(
            [
              {
                meta_key_id: 'test:text',
                value: { string: Faker::Lorem.word }
              }
            ]
          )

        workflow = Workflow.create(name: Faker::Educator.course, creator: user)

        expect(
          entry_values(workflow, 'test:text')
        ).to be_instance_of(Array)

        entry_values(workflow, 'test:text').each do |val|
          expect(val).to have_key('string')
        end
      end
    end

    context 'when value is given as nil' do
      it 'transforms it into empty array' do
        allow_any_instance_of(Workflow)
          .to receive(:default_common_meta_data)
          .and_return(
            [
              {
                meta_key_id: 'test:text',
                value: nil
              }
            ]
          )

        workflow = Workflow.create(name: Faker::Educator.course, creator: user)

        expect(
          entry_values(workflow, 'test:text')
        ).to be_instance_of(Array)

        entry_values(workflow, 'test:text').each do |val|
          expect(val).to eq([])
        end
      end
    end

    context 'when value is not given' do
      it 'adds it as an empty array' do
        allow_any_instance_of(Workflow)
          .to receive(:default_common_meta_data)
          .and_return(
            [
              {
                meta_key_id: 'test:text'
              }
            ]
          )

        workflow = Workflow.create(name: Faker::Educator.course, creator: user)

        expect(
          entry_values(workflow, 'test:text')
        ).to be_instance_of(Array)

        entry_values(workflow, 'test:text').each do |val|
          expect(val).to eq([])
        end
      end
    end

    context 'when meta key is of MetaDatum::Keywords type' do
      before do
        create :keyword, term: 'foo'
        create :keyword, term: 'bar'
        create :keyword, term: 'xoxo'
      end

      it 'adds type to values' do
        keywords = Keyword.where(term: %w(foo bar))

        allow_any_instance_of(Workflow)
          .to receive(:default_common_meta_data)
          .and_return(
            [
              {
                meta_key_id: 'test:text',
                value: [{ string: Faker::Lorem.word }]
              },
              {
                meta_key_id: 'test:keywords',
                value: keywords
              },
              {
                meta_key_id: 'test:keyword',
                value: Keyword.find_by(term: 'xoxo')
              }
            ]
          )

        workflow = Workflow.create(name: Faker::Educator.course, creator: user)

        entry_values(workflow, 'test:text').each do |val|
          expect(val.size).to eq(1)
          expect(val).to have_key('string')
        end

        entry_values(workflow, 'test:keywords').each do |val|
          expect(val['type']).to eq('Keyword')
          expect(val).not_to have_key('id')
          expect(val).to have_key('uuid')
          expect(val['term']).to eq('foo').or eq('bar')
        end

        expect(entry_values(workflow, 'test:keyword')).to be_instance_of(Array)
        entry_values(workflow, 'test:keyword').each do |val|
          expect(val['type']).to eq('Keyword')
          expect(val).not_to have_key('id')
          expect(val).to have_key('uuid')
          expect(val['term']).to eq('xoxo')
        end
      end
    end

    context 'when meta key is of MetaDatum::People type' do
      before do
        create :person, first_name: 'Foo'
        create :person, first_name: 'Bar'
      end

      it 'adds type to values' do
        people = Person.where(first_name: %w(Foo Bar))

        allow_any_instance_of(Workflow)
          .to receive(:default_common_meta_data)
          .and_return(
            [
              {
                meta_key_id: 'test:text',
                value: [{ string: Faker::Lorem.word }]
              },
              {
                meta_key_id: 'test:people',
                value: people
              }
            ]
          )

        workflow = Workflow.create(name: Faker::Educator.course, creator: user)

        entry_values(workflow, 'test:text').each do |val|
          expect(val.size).to eq(1)
          expect(val).to have_key('string')
        end

        entry_values(workflow, 'test:people').each do |val|
          expect(val['type']).to eq('Person')
          expect(val).not_to have_key('id')
          expect(val).to have_key('uuid')
          expect(val['first_name']).to eq('Foo').or eq('Bar')
        end
      end
    end
  end
end

def entry_values(workflow, meta_key_id)
  workflow.common_meta_data.detect do |e|
    e['meta_key_id'] == meta_key_id
  end.fetch('value')
end
