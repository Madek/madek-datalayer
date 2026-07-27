require 'spec_helper'

describe MediaResources::MetaData, '.preload_for_list!' do
  def count_sql
    queries = []
    callback = lambda do |*args|
      payload = args.last
      next if payload[:name].to_s =~ /SCHEMA|CACHE/
      queries << payload[:sql]
    end
    ActiveSupport::Notifications.subscribed(callback, 'sql.active_record') do
      yield
    end
    queries
  end

  def people_related_sql_count(queries)
    queries.count do |sql|
      sql =~ /meta_data_people|\bFROM ["']?people["']?/i
    end
  end

  let(:authors_meta_key) { MetaKey.find_by!(id: 'madek_core:authors') }

  it 'avoids N+1 Person loads when calling authors after preload (Madek#914)' do
    entry_ids = 5.times.map do
      me = create(:media_entry)
      create(:meta_datum_people, media_entry: me, meta_key: authors_meta_key)
      me.id
    end

    entries = MediaEntry.where(id: entry_ids).to_a
    without_preload = count_sql { entries.each(&:authors) }
    expect(people_related_sql_count(without_preload)).to be >= entry_ids.size

    entries = MediaEntry.where(id: entry_ids).to_a
    MediaResources::MetaData.preload_for_list!(entries)
    with_preload = count_sql { entries.each(&:authors) }
    expect(people_related_sql_count(with_preload)).to eq(0)
  end

  it 'keeps authors string equal to people.map order (incl. tied positions)' do
    # Same position: :people sorts by last_name; join id order would differ.
    person_z = create(:person, last_name: 'Zed', first_name: 'Z')
    person_a = create(:person, last_name: 'Adam', first_name: 'A')
    me = create(:media_entry)
    md = create(:meta_datum_people,
                media_entry: me,
                meta_key: authors_meta_key,
                people: [person_z, person_a])
    md.meta_data_people.update_all(position: 0)

    expected = MediaEntry.find(me.id).authors
    expect(expected).to eq([person_a, person_z].map(&:to_s).join('; '))

    entries = MediaEntry.where(id: me.id).to_a
    MediaResources::MetaData.preload_for_list!(entries)
    expect(entries.first.authors).to eq(expected)
  end
end
