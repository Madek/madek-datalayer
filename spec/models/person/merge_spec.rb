require 'spec_helper'

describe Person do

  context 'merge' do
    it 'both receiver and originator are attached to different meta datums' do
      p1 = FactoryBot.create(:person)
      p2 = FactoryBot.create(:person)
      p3 = FactoryBot.create(:person)
      p4 = FactoryBot.create(:person)
      r1 = FactoryBot.create(:role)
      r2 = FactoryBot.create(:role)

      md1 = FactoryBot.create(:meta_datum_people, people: [p1, p2])
      md2 = FactoryBot.create(:meta_datum_people, people: [p3, p4])
      md3 = FactoryBot.create(:meta_datum_roles,
                              people_with_roles: [{ person: p1, role: r1 },
                                                  { person: p2, role: r2 }])
      md4 = FactoryBot.create(:meta_datum_roles,
                              people_with_roles: [{ person: p3, role: r1 },
                                                  { person: p4, role: r2 }])

      p2.merge_to(p3)

      expect(Person.find_by_id(p2.id)).not_to be
      expect(md1.reload.people.to_set).to eq [p1, p3].to_set
      expect(md2.reload.people.to_set).to eq [p3, p4].to_set
      expect(md3.reload.meta_data_roles.map { |mdr| { person_id: mdr.person_id,
                                                      role_id: mdr.role_id } }.to_set)
        .to eq [{ person_id: p1.id, role_id: r1.id },
                { person_id: p3.id, role_id: r2.id }].to_set
      expect(md4.reload.meta_data_roles.map { |mdr| { person_id: mdr.person_id,
                                                      role_id: mdr.role_id } }.to_set)
        .to eq [{ person_id: p3.id, role_id: r1.id },
                { person_id: p4.id, role_id: r2.id }].to_set
      expect(p3.previous.map(&:previous_id)).to eq [p2.id]
    end

    it 'both receiver and originator are attached to the same meta datum' do
      p1 = FactoryBot.create(:person)
      p2 = FactoryBot.create(:person)
      r1 = FactoryBot.create(:role)

      md1 = FactoryBot.create(:meta_datum_people, people: [p1, p2])
      md2 = FactoryBot.create(:meta_datum_roles,
                              people_with_roles: [{ person: p1, role: r1 },
                                                  { person: p2, role: r1 }])

      p1.merge_to(p2)

      expect(Person.find_by_id(p1.id)).not_to be
      expect(md1.reload.people).to eq [p2]
      expect(md2.reload.meta_data_roles.map { |mdr| { person_id: mdr.person_id,
                                                      role_id: mdr.role_id } }.to_set)
        .to eq [{ person_id: p2.id, role_id: r1.id }].to_set
      expect(p2.previous.map(&:previous_id)).to eq [p1.id]
    end

    it 'elaborate merge including recursion: A -> B, B -> D, C -> D' do
      p1 = FactoryBot.create(:person)
      p2 = FactoryBot.create(:person)
      p3 = FactoryBot.create(:person)
      p4 = FactoryBot.create(:person)

      p1.merge_to(p2)
      p2.merge_to(p4)
      p3.merge_to(p4)

      expect(p4.previous.map(&:previous_id).to_set).to eq [p1.id, p2.id, p3.id].to_set
      expect(Person.find_by_id(p1.id)).not_to be
      expect(Person.find_by_id(p2.id)).not_to be
      expect(Person.find_by_id(p3.id)).not_to be
    end
  end
end

