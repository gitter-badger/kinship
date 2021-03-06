Given(/^there is a marriage between "(.*?)" and "(.*?)"$/) do |name_1, name_2|
  person_1 = Person.with_name(name_1).first
  person_2 = Person.with_name(name_2).first
  @marriage = LifeEvent::Marriage.create(person_1: person_1, person_2: person_2)
end

When(/^I click "(.*?)" for the marriage$/) do |target|
  within("##{ActionView::RecordIdentifier.dom_id(@marriage)}") do
    click_on(target)
  end
end
