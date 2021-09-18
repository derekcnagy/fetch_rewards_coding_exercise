Given(/^Find the Fake Gold Bar$/) do
  @browser = Watir::Browser.new
  on_page(ScalesPage) do |scales|
    scales.visit

    fake_bar = scales.find_fake_gold_bar

    scales.select_bar(fake_bar)

    expect(@browser.alert.text).to eql 'Yay! You find it!'
  end
  sleep 5
  @browser.close
end
