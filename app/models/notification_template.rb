class NotificationTemplate < ApplicationRecord
  CATEGORIES = [:ui,
                :email_single,
                :email_single_subject,
                :email_summary,
                :email_summary_subject] 

  CATEGORIES.each do |m_name|
    define_method(m_name) do
      read_attribute(m_name).with_indifferent_access
    end
  end

  validate do
    CATEGORIES.each do |tmpl_cat|
      [:de, :en].each do |lang|
        tmpl = self.send(tmpl_cat)[lang]
        lt = Liquid::Template.parse(tmpl, error_mode: :strict)
        vars = self.send("#{tmpl_cat}_vars")
        lt.render!(NotificationTemplate.vars_stub(vars), strict_variables: true)
      end
    end
  end

  def self.vars_stub(vars)
    vars.reduce({}) do |res, var|
      vp1, *vps = var.split(".")
      if vps.empty?
        res.merge(vp1 => nil)
      else
        res.merge(vp1 => vars_stub(vps))
      end
    end
  end
end
