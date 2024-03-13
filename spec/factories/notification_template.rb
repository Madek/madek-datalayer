FactoryBot.define do
  factory :notification_template do
    label { Faker::Lorem.words(number: 100).sample }
    description { Faker::Lorem.sentence }

    ui_vars { ["data.foo", "data.bar.baz"] }
    ui do
      { en: "foo {{ data.foo }} bar baz {{ data.bar.baz }}",
        de: "foo {{ data.foo }} bar baz {{ data.bar.baz }}" }
    end
    email_single_subject_vars { ["site_title"] }
    email_single_subject do
      { en: "{{ site_title }}: email single subject",
        de: "{{ site_title }}: email single subject" }
    end
    email_single_vars { ["data.foo", "data.bar.baz"] }
    email_single do
      { en: "foo {{ data.foo }} bar baz {{ data.bar.baz }}",
        de: "foo {{ data.foo }} bar baz {{ data.bar.baz }}" }
    end
    email_summary_subject_vars { ["site_title"] }
    email_summary_subject do
      { en: "{{ site_title }}: email summary subject",
        de: "{{ site_title }}: email summary subject" }
    end
    email_summary_vars { ["collection", "data.foo", "data.bar.baz"] }
    email_summary do
      en = <<~TXT
        summary: 
        {% for data in collection %}
          * foo {{ data.foo }} bar baz {{ data.bar.baz }} 
        {% endfor %}
      TXT
      de = <<~TXT
        summary: 
        {% for data in collection %}
          * foo {{ data.foo }} bar baz {{ data.bar.baz }} 
        {% endfor %}
      TXT

      { de: de, en: en }
    end
  end
end
